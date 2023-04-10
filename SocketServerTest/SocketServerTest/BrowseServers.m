//
//  BrowseServers.m
//  SocketServerTest
//
//  Created by Genrih Korenujenko on 17.09.17.
//  Copyright © 2017 Koreniuzhenko Henrikh. All rights reserved.
//

#import "BrowseServers.h"

@interface BrowseServers () <NSNetServiceDelegate, NSNetServiceBrowserDelegate>
{
    NSNetServiceBrowser *browser;
    NSMutableArray *services;
    
    NSString *type;
    NSString *domain;
    
    __weak id <BrowseServersInterface> interface;
    
    BOOL isStarted;
    BOOL moreComing;
}
@end

@implementation BrowseServers

#pragma mark - Init
-(instancetype)initWithInterface:(id<BrowseServersInterface>)browseServersInterface
{
    self = [super init];
    
    if (self)
    {
        services = [NSMutableArray new];
        browser = [NSNetServiceBrowser new];
        browser.delegate = self;
        interface = browseServersInterface;
        isStarted = NO;
    }
    
    return self;
}

#pragma mark - Public Methods
-(void)setType:(NSString*)serviceType
{
    type = serviceType;
}

-(void)setDomain:(NSString*)serviceDomain
{
    domain = serviceDomain;
}

-(void)searchByType:(NSString*)serviceType inDomain:(NSString*)serviceDomain
{
    [self setType:serviceType];
    [self setDomain:serviceDomain];
    [self start];
}

-(void)start
{
    if (!isStarted)
    {
        isStarted = YES;
        [browser searchForServicesOfType:type inDomain:domain];
    }
}

-(void)stop
{
    if (isStarted)
    {
        [browser stop];
        isStarted = NO;
    }
}

-(void)clear
{
    [self stop];
    [services removeAllObjects];
}

#pragma mark - NSNetServiceBrowserDelegate
-(void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)netService moreComing:(BOOL)coming
{
    [netService setDelegate:self];
    [netService resolveWithTimeout:30.0];
    [services addObject:netService];
    moreComing = coming;
}

-(void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)netService moreComing:(BOOL)coming
{
    netService.delegate = nil;
    [services removeObject:netService];
    moreComing = coming;
}

-(void)netServiceBrowser:(NSNetServiceBrowser*)browser didFindDomain:(NSString*)domainString moreComing:(BOOL)moreComing
{
    NSLog(@"Find Domain...");

}

-(void)netServiceBrowser:(NSNetServiceBrowser*)browser didRemoveDomain:(NSString*)domainString moreComing:(BOOL)moreComing
{
    NSLog(@"Remove Domain...");
}

-(void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didNotSearch:(NSDictionary*)errorDict
{
    NSLog(@"Search browser Did not search..");
    [self stop];
}

-(void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser*)netServiceBrowser
{
    NSLog(@"Search browser Did STOP search..");
    [self stop];
}

#pragma mark - NSNetServiceDelegate
-(void)netServiceDidResolveAddress:(NSNetService*)service
{
    if (!moreComing)
        [interface foundService:services];

    NSLog(@"Unable to Connect with Service: domain(%@) type(%@) name(%@) port(%tu)", service.domain, service.type, service.name, service.port);
}

@end
