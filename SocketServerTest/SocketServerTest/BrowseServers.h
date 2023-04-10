//
//  BrowseServers.h
//  SocketServerTest
//
//  Created by Genrih Korenujenko on 17.09.17.
//  Copyright © 2017 Koreniuzhenko Henrikh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BrowseServersInterface <NSObject>

@required
-(void)foundService:(NSArray<NSNetService*>*)foundServices;

@end

@interface BrowseServers : NSObject

-(instancetype)initWithInterface:(id<BrowseServersInterface>)interface;

-(void)setType:(NSString*)serviceType;
-(void)setDomain:(NSString*)serviceDomain;
-(void)searchByType:(NSString*)serviceType inDomain:(NSString*)serviceDomain;
-(void)start;
-(void)stop;
-(void)clear;

@end
