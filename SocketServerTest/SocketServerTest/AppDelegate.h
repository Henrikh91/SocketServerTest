//
//  AppDelegate.h
//  SocketServerTest
//
//  Created by Genrih Korenujenko on 17.09.17.
//  Copyright © 2017 Koreniuzhenko Henrikh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

