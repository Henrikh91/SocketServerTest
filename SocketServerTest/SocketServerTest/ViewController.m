//
//  ViewController.m
//  SocketServerTest
//
//  Created by Genrih Korenujenko on 17.09.17.
//  Copyright © 2017 Koreniuzhenko Henrikh. All rights reserved.
//

#import "ViewController.h"
#import "BrowseServers.h"
#import "SocketServer.h"
#import "SocketClient.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, BrowseServersInterface, SocketClientInterface>
{
    IBOutlet UITextField *inputNameField;
    IBOutlet UITableView *table;
    
    NSMutableArray *services;
    
    BrowseServers *browseServers;
    SocketServer *socketServer;
    SocketClient *socketClient;
    
    BOOL isServer;
}
@end

@implementation ViewController

#pragma mark - Override Methods
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    isServer = NO;
    NSString *type = @"_mrug._tcp";
    
    if (isServer)
    {
        services = [NSMutableArray new];
        socketServer = [SocketServer new];
        [socketServer publishWithDomain:@"" type:type name:@"Name" port:8080];
    }
    else
    {
        services = [NSMutableArray new];
        socketClient = [[SocketClient alloc] initWithInterface:self];
        browseServers = [[BrowseServers alloc] initWithInterface:self];
        [browseServers searchByType:type inDomain:@""];
    }
}

#pragma mark - Private Methods
-(void)reloadToNewMessage
{
    [table reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:services.count - 1 inSection:0];
    [table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return services.count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];

    NSNetService *service = services[indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat:@"Domain: %@ Type: %@ PORT: %@", service.domain, service.type, service.port > 0 ? @(service.port).stringValue : @""];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Name: %@", service.name];
    
    return cell;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 60;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSNetService *service = services[indexPath.row];
    [socketClient connectToService:service];
}

#pragma mark - Action Methods
-(IBAction)send
{
    [socketClient send:inputNameField.text];
}

#pragma mark - SocketClientInterface
-(void)didSend:(NSString*)text
{
    inputNameField.text = nil;
}

#pragma mark - BrowseServersInterface
-(void)foundService:(NSArray<NSNetService*>*)foundServices
{
    [services addObjectsFromArray:foundServices];
    [self reloadToNewMessage];
}

@end

