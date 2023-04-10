//
//  SocketClient.m
//  SocketServerTest
//
//  Created by Genrih Korenujenko on 17.09.17.
//  Copyright © 2017 Koreniuzhenko Henrikh. All rights reserved.
//

#import "SocketClient.h"
#import "GCDAsyncSocket.h"

@interface SocketClient () <GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *socket;
}
@end

@implementation SocketClient

@synthesize interface;

-(instancetype)initWithInterface:(id<SocketClientInterface>)socketClientInterface;
{
    self = [self init];
    
    if (self)
        interface = socketClientInterface;
    
    return self;
}

-(BOOL)connectToService:(NSNetService*)service
{
    return [self connectToHost:service.hostName onPort:service.port];
}

-(BOOL)connectToHost:(NSString*)host onPort:(NSInteger)port
{
    BOOL result = NO;
    
    if (!socket.isConnected)
    {
        socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *error = nil;
        result = [socket connectToHost:host onPort:port error:&error];
//    @"192.168.0.101"
//    if (![self.socket connectToUrl:[NSURL URLWithString:@"1704220846.members.btmm.icloud.com:8080"] withTimeout:-1 error:&error])
        if (!result)
            NSLog(@"Unable To Create Socket, error: %@", error.localizedDescription);
    }
    
    return result;
}

-(void)send:(NSString*)text
{
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    [socket writeData:data withTimeout:-1 tag:0];
}

-(void)socket:(GCDAsyncSocket*)sock didConnectToHost:(NSString*)host port:(uint16_t)port
{
    NSLog(@"[Client] Connected to HOST:%@ port: %tu", host, port);
    [sock readDataWithTimeout:-1 tag:0];
}

-(void)socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError *)error;
{
    NSLog(@"[Client] Closed connection: %@", error);
    socket.delegate = nil;
    socket = nil;
}

-(void)socket:(GCDAsyncSocket*)sock didReadData:(NSData*)data withTag:(long)tag;
{
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"[Client] Received: %@", text);
    
    [interface didSend:text];
    [sock readDataWithTimeout:-1 tag:0];
}

@end
