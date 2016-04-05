//
//  AppDelegate.m
//  MM
//
//  Created by Monica Mollica on 2016-04-04.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Event.h"
#import "Request.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"Lq25p1eLSLdnBa0APu5KGIHQ49Z5oh9WgFt1OlRj";
        configuration.clientKey = @"1m76Gbfii3QE0fJwRnEVLBHI8y3e0qq4IFP0ssYo";
        //configuration.server = @"http://YOUR_PARSE_SERVER:1337/parse";
    }]];
    
    [Event registerSubclass];
    [User registerSubclass];
    [Request registerSubclass];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
