//
//  SocketServer.h
//  SocketServerTest
//
//  Created by Genrih Korenujenko on 17.09.17.
//  Copyright © 2017 Koreniuzhenko Henrikh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketServer : NSObject

-(BOOL)publishWithDomain:(NSString*)domain type:(NSString*)type name:(NSString*)name port:(NSInteger)port;

@end
