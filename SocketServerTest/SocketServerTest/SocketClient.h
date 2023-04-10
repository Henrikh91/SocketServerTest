//
//  SocketClient.h
//  SocketServerTest
//
//  Created by Genrih Korenujenko on 17.09.17.
//  Copyright © 2017 Koreniuzhenko Henrikh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SocketClientInterface <NSObject>

@required
-(void)didSend:(NSString*)text;

@end

@interface SocketClient : NSObject

@property (nonatomic, readwrite, weak) NSObject <SocketClientInterface> *interface;

-(instancetype)initWithInterface:(id<SocketClientInterface>)interface;
-(BOOL)connectToService:(NSNetService*)service;
-(BOOL)connectToHost:(NSString*)host onPort:(NSInteger)port;
-(void)send:(NSString*)text;

@end
