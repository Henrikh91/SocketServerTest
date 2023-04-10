//
//  DomainServer.h
//  DomainTest
//
//  Created by Jonathan Diehl on 06.10.12.
//  Copyright (c) 2012 Jonathan Diehl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@protocol DomainServerDelegate <NSObject>

@required
-(void)newMessage:(NSString*)text;

@end

@interface DomainServer : NSObject

-(instancetype)initWithDelegate:(id<DomainServerDelegate>)delegate;

-(void)startPublishing;
-(void)startBrowsing;

@end
