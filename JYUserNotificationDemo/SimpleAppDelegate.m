//
//  SimpleAppDelegate.m
//  JYUserNotificationDemo
//
//  Created by Jolie_Yang on 16/8/18.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import "SimpleAppDelegate.h"
#import "ViewController.h"

@interface SimpleAppDelegate() {
    BOOL _isLaunched;
}

@end

@implementation SimpleAppDelegate

// 每台设备会建立一个与APNs认证且加密过的长连接，并通过长连接接收推送信息。
// 注册， 发起， 接收展示

// devicetoken 可以识别到是哪台设备的哪个应用
// 推送信息是JSON格式

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self.window makeKeyAndVisible];
    
    self.userNotificationType = UserNotificationRemote;
    [self registUserNotification];// 注册远程推送消息，即默认也注册了本地推送消息
    
    return YES;
}

#pragma mark Push Notification
// 注册远程推送
// 注册分为两部分： 注册（配置）应用支持的用户交互形式(三种：alert提示信息,badge,sound)，注册通知获取devicetoken(APNs通过devicetoken识别到具体设备的具体应用中发送推送信息)[ps: 本地通知无需进行该部分]
- (void)registUserNotification {
    [self registNotificationType];
#ifdef __IPHONE_10_0
    // 使用UserNotificationC.framwork
#endif
#ifdef __IPHONE_8_0
    if (self.userNotificationType) {
        //  注册远程推送信息
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
#endif
}
#pragma mark Local Notification
// 初始化通知信息配置，包括远程和本地通知信息的设置
- (void)registNotificationType {
#ifdef __IPHONE_10_0
    
#endif
#ifdef __IPHONE_8_0
    // // 判断用户是否已授权应用发送通知信息
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
       // 获取用户通知信息配置信息
        NSLog(@"UIUserNotificationTypeNone");
    }
    if (!_isLaunched) {
        // 请求授权本地通知
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert categories:nil]; // Categories 用于标识通知的目的 通过categories标志符决定如何处理通知。
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        _isLaunched = YES;
    }
#endif
}

// 移除本地通知
- (void)removeLocalNotification {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
// 本地通知 -- 应用在后台，点击通知中心/点击横幅/点击弹窗进入 ｜ 应用在前台收到本地通知进入该回调
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification  {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        // 应用在前台
        NSLog(@"UIApplicationStateactive");
    } else if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        // 应用从后台进入前台
        NSLog(@"UIApplicationStateInactive");
    } else {
        NSLog(@"UIApplicationStateBackground");
    }
    NSDictionary *userInfo = notification.userInfo;
    ViewController *vc = [self showNotificationMsgOnViewController];
    vc.localNotificationLB.text = [userInfo valueForKey:@"alert"];
}

// 远程推送
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        // 应用在前台
        NSLog(@"UIApplicationStateactive");
    } else if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        // 应用从后台进入前台
        NSLog(@"UIApplicationStateInactive");
    } else {
        NSLog(@"UIApplicationStateBackground");
    }
    userInfo = [userInfo valueForKey:@"aps"];
    ViewController *vc = [self showNotificationMsgOnViewController];
    vc.remoteNotificationLB.text = [NSString stringWithFormat:@"静默通知：%@", [userInfo valueForKey:@"alert"]];
    
    if ([userInfo valueForKey:@"content-available"]) {
        // 静默通知
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURL *url = [[NSURL alloc] initWithString:@"http://blog.csdn.net/jolie_yang"];
        NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                completionHandler(UIBackgroundFetchResultFailed);
            }
            if (data) {
                completionHandler(UIBackgroundFetchResultNewData);
            }
        }];
        [task resume];
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
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

// 特殊情况： 应用在弹窗显示是否允许发送通知信息时，如果手机没有联网，那么即不会进入didRegisterForRemoteNotificationsWithDeviceToken回调，也不会进入didFailToRegisterForRemoteNotificationsWithError回调。而如果应用曾经获取过devicetoken，即使在没有联网的情况下也会返回上一次的devicetoken。(ps: 猜测是APNs端生成devicetoken后存储到本地，因而可以从本地获取)
// 调用registerForRemoteNotifications后会触发进入该回调。
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // deviceToken除了在重新安装应用时会修改，还有些特殊情况(比如升级系统)系统可能也会修改
    // 网上看到资料，[todo]iOS9.0以后的版本卸载重装才会改变,iOS7与iOS8是不会改变的
    // 考虑到同一个帐号可能会在多台设备上登陆，因而同一个帐号会有多个devicetoken，通过设备UUID+deviceToken确保一个设备只有一个deviceToken。
    NSLog(@"devicetoken:%@", deviceToken);
}
// 获取deviceToken失败,查看错误信息吧
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"devicetoken error: %@", error.localizedDescription);
}
@end
