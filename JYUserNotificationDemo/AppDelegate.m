//
//  AppDelegate.m
//  JYUserNotificationDemo
//
//  Created by Jolie_Yang on 16/8/17.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ViewController *vc = [[ViewController alloc] init];
    _window.rootViewController = vc;
    
    [_window makeKeyAndVisible];
    
    [self initUserNotification];
    [self initLocalNotification];
    
    // 接收通知信息
    if (!launchOptions) {
        NSDictionary *localUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        NSDictionary *remoteUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (!localUserInfo) {
           // 收到本地通知
        }
        if (!remoteUserInfo) {
            // 收到远程推送消息
        }
    }
    
    return YES;
}

#pragma mark Push Notification
- (void)initUserNotification {
#ifdef __IPHONE_10_0
    // 使用UserNotificationC.framwork
#endif
#ifdef __IPHONE_8_0
    
#endif
}
#pragma mark Local Notification
// 默认初始化本地通知
- (void)initLocalNotification {
    // 是否已经授权接收本地通知
#ifdef __IPHONE_10_0
#endif
#ifdef __IPHONE_8_0
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone) {
        [self addLocalNotification];
    } else {
        // 请求授权本地通知
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    }
#endif
}
// 发起本地通知
- (void)addLocalNotification {
    // 1. 初始化LocalNotification
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    // 2. 设置
    // 2.1 设置时间
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5.0];
    localNotification.repeatInterval = 2; //通知重复次数
    // 2.2 设置通知属性
    localNotification.alertTitle = @"JolieYang";
    localNotification.alertBody = @"test localNotification";
    localNotification.alertAction = @"打开应用";// 待机界面滑动动作显示文本
    localNotification.applicationIconBadgeNumber = 1;
    localNotification.alertLaunchImage = @"Default";
    localNotification.soundName = UILocalNotificationDefaultSoundName;// 默认消息提醒
    // 2.3 设置用户信息
    localNotification.userInfo = @{@"id":@1, @"user":@"rose"};
    
    // 3. 发起通知
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}
// 移除本地通知
- (void)removeLocalNotification {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification  {
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"rose show userInfo:%@", userInfo);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // 进入程序后去除图标数字
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [self addLocalNotification];
    }
}








- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}



- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
