//
//  DomainClient.h
//  DomainTest
//
//  Created by Jonathan Diehl on 06.10.12.
//  Copyright (c) 2012 Jonathan Diehl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@protocol DomainClientDelegate <NSObject>

@required
-(void)didSend:(NSString*)text;

@end

@interface DomainClient : NSObject <GCDAsyncSocketDelegate>

@property (readonly) GCDAsyncSocket *socket;

-(instancetype)initWithDelegate:(id<DomainClientDelegate>)delegate;

-(void)connectToUrl:(NSURL*)url;
-(void)send:(NSString*)text;

@end
