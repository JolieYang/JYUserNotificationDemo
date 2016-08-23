//
//  LocUserNotification.m
//  JYUserNotificationDemo
//
//  Created by Jolie_Yang on 16/8/22.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import "LocUserNotification.h"
#import "ViewController.h"

#define REGIST_UN_SETTINGS @"registUNSettigns"

@interface LocUserNotification ()

@end

@implementation LocUserNotification
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self.window makeKeyAndVisible];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey: REGIST_UN_SETTINGS]) {
        [self initLocalNotification];// 注册本地推送消息
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:REGIST_UN_SETTINGS];
    }
    
    if (launchOptions) {//  应用退出后再进入调用，点击提示信息(横幅，通知中心，提示框)进入应用。ps:通知中心有推送消息，但如果直接点击应用图标进入则无法获取到储存的通知信息
        NSDictionary *localUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (localUserInfo) {
            // 收到本地通知
            ViewController *vc = (ViewController *)self.window.rootViewController;
            vc.localNotificationLB.text = @"didFinishLaunchingWithOpitions";
        }
    }
    
    return YES;
}

#pragma mark Local Notification
// 初始化通知信息配置，包括远程和本地通知信息的设置
- (void)initLocalNotification {
#ifdef __IPHONE_10_0
    
#endif
#ifdef __IPHONE_8_0
    // // 判断用户是否已授权应用发送通知信息
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
