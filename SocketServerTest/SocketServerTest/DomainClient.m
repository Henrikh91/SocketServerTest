//
//  DomainClient.m
//  DomainTest
//
//  Created by Jonathan Diehl on 06.10.12.
//  Copyright (c) 2012 Jonathan Diehl. All rights reserved.
//

#import "DomainClient.h"

@interface DomainClient () <GCDAsyncSocketDelegate>
{
    id<DomainClientDelegate> delegate;
}
@end

@implementation DomainClient

@synthesize socket = _socket;

-(instancetype)initWithDelegate:(id<DomainClientDelegate>)aDelegate
{
    self = [self init];
    
    if (self)
        delegate = aDelegate;
    
    return self;
}

- (void)connectToUrl:(NSURL *)url;
{
	NSError *error = nil;
	_socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//    if (![self.socket connectToUrl:[NSURL URLWithString:@"1704220846.members.btmm.icloud.com:8080"] withTimeout:-1 error:&error])
    if (![self.socket connectToHost:@"192.168.0.101" onPort:8080 error:&error])
	{
        NSLog(@"%@", error.localizedDescription);
	}
}

-(void)send:(NSString*)text
{
	NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
	[self.socket writeData:data withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(nonnull NSString *)host port:(uint16_t)port
{
	NSLog(@"[Client] Connected to HOST:%@ port: %tu", host, port);
	[sock readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error;
{
	NSLog(@"[Client] Closed connection: %@", error);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
	NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"[Client] Received: %@", text);
    
    [delegate didSend:text];
//    [sock writeData:data withTimeout:-1 tag:0];
	[sock readDataWithTimeout:-1 tag:0];
}

@end
