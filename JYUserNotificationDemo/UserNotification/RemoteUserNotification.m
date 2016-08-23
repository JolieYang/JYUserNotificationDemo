//
//  RemoteUserNotification.m
//  JYUserNotificationDemo
//
//  Created by Jolie_Yang on 16/8/22.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import "RemoteUserNotification.h"
#import "ViewController.h"

@interface RemoteUserNotification()

@end

@implementation RemoteUserNotification
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

// 移除本地通知
- (void)removeLocalNotification {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
// 应用在后台，点击通知中心/点击横幅/点击弹窗进入 ｜ 应用在前台收到本地通知进入该回调
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification  {
    
}
// 应用在后台，点击通知中心/点击横幅/点击弹窗进入 ｜ 应用在前台收到本地通知进入该回调
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}

#pragma mark Tools
- (ViewController *)showNotificationMsgOnViewController {
    ViewController *vc = (ViewController *)self.window.rootViewController;
    
    return vc;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // 进入程序后去除图标数字
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

// 系统弹框询问是否允许应用推送消息。 用户选择后会进入该回调，显示用户选择结果
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        NSLog(@"User allow registerUserNotificationSettiongs");
    } else {
        NSLog(@"User deny registerUserNotificationSettiongs");
    }
}

// 调用registerForRemoteNotifications后会触发进入该回调。
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"devicetoken:%@", deviceToken);
}


@end
