//
//  SimpleAppDelegate.m
//  JYUserNotificationDemo
//
//  Created by Jolie_Yang on 16/8/18.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

// https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW26

#import "SimpleAppDelegate.h"
#import "ViewController.h"

@interface SimpleAppDelegate() {
}

@property (nonatomic, assign) BOOL registered;// 注册远程推送并获取到deviceToken

@end

@implementation SimpleAppDelegate

// 每台设备会建立一个与APNs认证且加密过的长连接，并通过长连接接收推送信息。
// 注册， 发起， 接收展示

// devicetoken 可以识别到是哪台设备的哪个应用
// 推送信息是JSON格式

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self.window makeKeyAndVisible];
    
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
        //  注册远程推送信息 devicetoken可能会改变，所以每次进入应用都要注册一次，并将devicetoken备份到服务器。
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
    if (!self.registered) {
        // 请求授权本地通知
        // Categories 用于标识通知的目的 通过categories标志符决定如何处理通知。 从iOS8开始，还可以在通知处添加按钮等，主要是提供入口让用户可以快速的相应该推送信息。UIMutableUserNotificationAction
//        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert categories: nil];
        UIMutableUserNotificationCategory *category = [self createUNCategoryObject];
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert categories: [NSSet setWithObject: category]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        
        
        self.userNotificationType = UserNotificationRemote;
    }
#endif
}

#pragma mark ActionableNotifications
- (UIMutableUserNotificationAction *)createUNActionObject {
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"Accept_identifier";
    acceptAction.title = @"Accept";// button上面的字
    acceptAction.activationMode = UIUserNotificationActivationModeBackground;// 激活后台应用程序，除非已在前台 ...?没懂
    acceptAction.destructive = NO;// ...?
    acceptAction.authenticationRequired = NO;// 执行该操作是否需要用户的认证(指是否需要用户解锁设备才可执行该操作)
    
    return acceptAction;
}
- (UIMutableUserNotificationCategory *)createUNCategoryObject {
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    inviteCategory.identifier = @"INVITE_CATEGORY";
    [inviteCategory setActions:@[[self createUNActionObject]] forContext:UIUserNotificationActionContextDefault];
    [inviteCategory setActions:@[[self createUNActionObject]] forContext:UIUserNotificationActionContextMinimal];
    
    return inviteCategory;
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    if ([identifier isEqualToString:@"Accept_identifier"]) {
        NSLog(@"rose show invite");
    }
    completionHandler();
    
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler {
    
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
    // Device tokens always change when the user restores backup data to a new device or computer or reinstalls the operating system.
    // deviceToken除了在重新安装应用时会修改，还有些特殊情况(比如升级系统,重装系统，恢复备份数据到新设备)devicetoken也会修改
    // 网上看到资料，[todo]iOS9.0以后的版本卸载重装才会改变,iOS7与iOS8是不会改变的
    // 考虑到同一个帐号可能会在多台设备上登陆，因而同一个帐号会有多个devicetoken，通过设备UUID+deviceToken确保一个设备只有一个deviceToken。
    if (!self.registered) {
        self.registered = YES;
        [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:@"devicetoken"];
    }
    const void *deviceTokenBytes = [deviceToken bytes];
    [self sendProviderDeviceToken:deviceTokenBytes];
    NSLog(@"devicetoken:%@", deviceToken);
}
// 获取deviceToken失败,查看错误信息吧
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error in Regist devicetoken: %@", error.localizedDescription);
}
// 发送deviceToken给网关
- (void)sendProviderDeviceToken:(const void *)deviceToken {
    // 判断deviceToken 是否更改
}
@end
