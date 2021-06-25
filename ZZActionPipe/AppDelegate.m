//
//  AppDelegate.m
//  ZZActionPipeDemo
//
//  Created by 曾智 on 2020/6/17.
//  Copyright © 2020 曾智. All rights reserved.
//

#import "AppDelegate.h"
#import "Testmodule.h"
#import "TestDemoModule.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    UIViewController *vc = [Testmodule viewController];
    UIViewController *vc = [TestDemoModule viewController];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)test {
}
@end
