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
    
    [self.window makeKeyAndVisible];
    
    [self initUserNotification];// 注册远程推送消息，即默认也注册了本地推送消息
//    [self initLocalNotification];// 只注册本地推送消息
    
    // deprecated 如果使用didReceiveRemoteNotification:fetchCompletionHandler回调则会处理程序终结的推送信息，则无需在didFinishLaunchingWithOptions中再重复获取该信息
    if (launchOptions) {//  应用退出后再进入调用，点击提示信息(横幅，通知中心，提示框)进入应用。ps:通知中心有推送消息，但如果直接点击应用图标进入则无法获取到储存的通知信息
        NSDictionary *localUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        NSDictionary *remoteUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (localUserInfo) {
           // 收到本地通知
            ViewController *vc = (ViewController *)self.window.rootViewController;
            vc.localNotificationLB.text = @"didFinishLaunchingWithOpitions";
        }
        if (remoteUserInfo) {
            // 收到远程推送消息
            ViewController *vc = (ViewController *)self.window.rootViewController;
            vc.remoteNotificationLB.text = @"didFinishLaunchingWithOpitions-remote";
        }
    }
    
    return YES;
}

#pragma mark Push Notification
// 注册远程推送
- (void)initUserNotification {
    [self initLocalNotification];
#ifdef __IPHONE_10_0
    // 使用UserNotificationC.framwork
#endif
#ifdef __IPHONE_8_0
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}
#pragma mark Local Notification
// 初始化通知信息配置，包括远程和本地通知信息的设置
- (void)initLocalNotification {
#ifdef __IPHONE_10_0
   
#endif
#ifdef __IPHONE_8_0
    // 是否已经授权接收本地通知
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
        // 请求授权本地通知
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
#endif
}

// 移除本地通知
- (void)removeLocalNotification {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
// 应用在后台，点击通知中心/点击横幅/点击弹窗进入 ｜ 应用在前台收到本地通知进入该回调
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
// 应用在后台，点击通知中心/点击横幅/点击弹窗进入 ｜ 应用在前台收到本地通知进入该回调
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
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
    vc.remoteNotificationLB.text = [userInfo valueForKey:@"alert"];
}
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

// 查看用户是否允许应用向其推送本地通知消息
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        NSLog(@"User allow registerUserNotificationSettiongs");
    } else {
        NSLog(@"User deny registerUserNotificationSettiongs");
    }
}

// 弹窗询问用户是否允许接收远程推送消息会进入该回调 ｜ 用户允许应用向其推送远程通知消息 | 拒绝之后就不会进入该回调
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"devicetoken:%@", deviceToken);
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
