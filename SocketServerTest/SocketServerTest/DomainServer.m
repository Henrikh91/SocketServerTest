//
//  DomainServer.m
//  DomainTest
//
//  Created by Jonathan Diehl on 06.10.12.
//  Copyright (c) 2012 Jonathan Diehl. All rights reserved.
//

#import "DomainServer.h"

@interface DomainServer () <GCDAsyncSocketDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate>
{
    id<DomainServerDelegate> delegate;
    
    NSNetService *netServiceToPublish;
    GCDAsyncSocket *socketPub;
    
    NSNetServiceBrowser *netServiceToBrowse;
    NSMutableArray *mutArrServices;
    
    
    GCDAsyncSocket *socketConnected;
}
@end

@implementation DomainServer

-(instancetype)initWithDelegate:(id<DomainServerDelegate>)aDelegate
{
    self = [self init];
    
    if (self)
        delegate = aDelegate;
    
    return self;
}

#pragma mark - Browsing
-(void)startBrowsing{
    
    if(mutArrServices)
        [mutArrServices removeAllObjects];
    else
        mutArrServices = [NSMutableArray array];
    
    netServiceToBrowse = [[NSNetServiceBrowser alloc]init];
    netServiceToBrowse.delegate= self;
    [netServiceToBrowse searchForServicesOfType:@"_mrug._tcp" inDomain:@""];
    
}
-(void)stopBrowsing
{
    
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    [mutArrServices addObject:aNetService];
    
    if(!moreComing)
    {
        // Sort Services
        [mutArrServices sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];

        for (NSNetService *service in mutArrServices)
        {
            [service setDelegate:self];
            [service resolveWithTimeout:30.0];
        }
        // Update Table View
//        [[NSNotificationCenter defaultCenter]postNotificationName:kNotifyReloadList object:mutArrServices];
    }
}
-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    [mutArrServices removeObject:aNetService];
    
    if(!moreComing)
    {
        // Sort Services
        [mutArrServices sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        
        // Update Table View
//        [[NSNotificationCenter defaultCenter]postNotificationName:kNotifyReloadList object:mutArrServices];
    }
    
}
-(void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    NSLog(@"Search browser Did STOP search..");
    [self stopBrowsing];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict
{
    NSLog(@"Search browser Did not search..");
    [self stopBrowsing];
}

#pragma mark - NetService Delegate
-(void)startPublishing
{
    socketPub = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *aError;
    if ([socketPub acceptOnPort:8080 error:&aError])
    {
        netServiceToPublish = [[NSNetService alloc]initWithDomain:@"" type:@"_mrug._tcp" name:@"" port:socketPub.localPort];
        netServiceToPublish.delegate =self;
        [netServiceToPublish publish];
        
    }
    else
        NSLog(@"Unable To Create Socket..");
}

//NetService Delegates
-(void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
    NSLog(@"Failed To Publish : Domain=%@ type=%@ name=%@ info=%@",sender.domain,sender.type,sender.name,errorDict);
}

-(void)netServiceDidPublish:(NSNetService *)sender
{
    NSLog(@"Service Published : Domain=%@ type=%@ name=%@ port=%li",sender.domain,sender.type,sender.name,(long)sender.port);
}

//Resolving Address
- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict
{
    [service setDelegate:nil];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service
{
    // Connect With Service
    if ([self connectWithService:service])
        NSLog(@"Did Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
    else
        NSLog(@"Unable to Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
}


#pragma mark - GCDSocket delegates
-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"Accepted new Socket: HOST : %@ , CONNECTION PORT :%li",newSocket.connectedHost,(long)newSocket.connectedPort);
    socketConnected = newSocket;
    [newSocket readDataWithTimeout:-1 tag:0];

    NSData *data = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    [socketConnected writeData:data withTimeout:-1 tag:0];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"Socket DisConnected %s,%@,%@",__PRETTY_FUNCTION__, sock,err);
    if(socketPub == sock)
    {
        socketPub.delegate = nil;
        socketPub = nil;
    }
    else if (socketConnected == sock)
    {
        socketConnected.delegate=nil;
        socketConnected = nil;
    }
}
- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Socket Did Connect to Host: %@ Port: %hu", host, port);
    [socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"[Server] Received: %@", text);
    
    [delegate newMessage:text];
    [sock writeData:data withTimeout:-1 tag:0];
    [sock readDataWithTimeout:-1 tag:0];
}

#pragma mark - Connection Methods
- (BOOL)connectWithService:(NSNetService *)service
{
    BOOL _isConnected = NO;
    
    // Copy Service Addresses
    NSArray *addresses = [[service addresses] mutableCopy];
    
    if (!socketConnected || ![socketConnected isConnected])
    {
        // Initialize Socket
        socketConnected = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // Connect
        while (!_isConnected && [addresses count])
        {
            NSData *address = [addresses objectAtIndex:0];
            NSError *error = nil;
            
            if ([socketConnected connectToAddress:address error:&error])
                _isConnected = YES;
            else if (error)
                NSLog(@"Unable to connect to address. Error %@ with user info %@.", error, [error userInfo]);
        }
    }
    else
        _isConnected = [socketConnected isConnected];

    return _isConnected;
}

@end
