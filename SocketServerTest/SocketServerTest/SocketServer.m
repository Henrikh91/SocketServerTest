//
//  SocketServer.m
//  SocketServerTest
//
//  Created by Genrih Korenujenko on 17.09.17.
//  Copyright © 2017 Koreniuzhenko Henrikh. All rights reserved.
//

#import "SocketServer.h"
#import "GCDAsyncSocket.h"
#import <NetworkExtension/NetworkExtension.h>
@interface SocketServer () <GCDAsyncSocketDelegate, NSNetServiceDelegate>
{
    GCDAsyncSocket *publishedSocket;
    NSNetService *publishedService;
    NSMutableArray *sockets;
}
@end

@implementation SocketServer

#pragma mark - Init
-(instancetype)init
{
    self = [super init];
    
    if (self)
    {
        sockets = [NSMutableArray new];
    }
        
    return self;
}

#pragma mark - Public Methods
-(BOOL)publishWithDomain:(NSString*)domain type:(NSString*)type name:(NSString*)name port:(NSInteger)port
{
    publishedSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error;
    BOOL result = [publishedSocket acceptOnPort:port error:&error];
    
    if (result)
    {
        publishedService = [[NSNetService alloc] initWithDomain:domain type:type name:name port:publishedSocket.localPort];
        publishedService.delegate = self;
        [publishedService publish];
    }
    else
        NSLog(@"Unable To Create Socket, error: %@", error.localizedDescription);
    
    return result;
}

#pragma mark - Private Methods
//-(BOOL)connectWithService:(NSNetService*)service
//{
//    BOOL isConnected = NO;
//    NSArray *addresses = service.addresses.mutableCopy;
//    
//    for (GCDAsyncSocket *socket in sockets)
//    {
//        NSError *error = nil;
//        
//        if (socket.isConnected && [addresses containsObject:socket.connectedAddress])
//        {
//            isConnected = YES;
//            break;
//        }
//        else if (error)
//            NSLog(@"Unable to connect to address. Error %@ with user info %@.", error, error.userInfo);
//    }
//    
//    return isConnected;
//}

#pragma mark - GCDAsyncSocketDelegate
-(void)socket:(GCDAsyncSocket*)socket didAcceptNewSocket:(GCDAsyncSocket*)newSocket
{
    NSLog(@"Accepted new Socket: HOST : %@ , CONNECTION PORT :%li",newSocket.connectedHost, (long)newSocket.connectedPort);
    [sockets addObject:newSocket];
    [newSocket readDataWithTimeout:-1 tag:0];
    
    NSData *data = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    [newSocket writeData:data withTimeout:-1 tag:0];
}

-(void)socketDidDisconnect:(GCDAsyncSocket*)socket withError:(NSError *)err
{
    NSLog(@"Socket DisConnected %s,%@,%@",__PRETTY_FUNCTION__, socket, err);
    
    if (publishedSocket == socket)
    {
        publishedSocket.delegate = nil;
        publishedSocket = nil;
    }
    else
    {
        [sockets removeObject:socket];
        socket.delegate=nil;
        socket = nil;
    }
}
-(void)socket:(GCDAsyncSocket*)socket didConnectToHost:(NSString*)host port:(UInt16)port
{
    NSLog(@"Socket Did Connect to Host: %@ Port: %hu", host, port);
    [socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
}

-(void)socket:(GCDAsyncSocket*)socket didReadData:(NSData*)data withTag:(long)tag;
{
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"[Server] Received: %@", text);
    
//    [delegate newMessage:text];
    [socket writeData:data withTimeout:-1 tag:0];
    [socket readDataWithTimeout:-1 tag:0];
}

#pragma mark - NSNetServiceDelegate
-(void)netService:(NSNetService*)service didNotPublish:(NSDictionary*)errorDict
{
    NSLog(@"Failed To Publish : Domain=%@ type=%@ name=%@ info=%@", service.domain, service.type, service.name,errorDict);
}

-(void)netServiceDidPublish:(NSNetService*)service
{
    publishedService = service;
    NSLog(@"Service Published : Domain=%@ type=%@ name=%@ port=%tu", service.domain, service.type, service.name, service.port);
}

-(void)netService:(NSNetService*)service didNotResolve:(NSDictionary*)errorDict
{
    [service setDelegate:nil];
}

-(void)netServiceDidResolveAddress:(NSNetService*)service
{
//    if ([self connectWithService:service])
//        NSLog(@"Did Connect with Service: domain(%@) type(%@) name(%@) port(%tu)", service.domain, service.type, service.name, service.port);
    
    NSLog(@"Unable to Connect with Service: domain(%@) type(%@) name(%@) port(%tu)", service.domain, service.type, service.name, service.port);
}

@end
