//
//  SimpleAppDelegate.m
//  JYUserNotificationDemo
//
//  Created by Jolie_Yang on 16/8/18.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

// https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW26

// http/2  实现强制使用HTTPS

// 消息 远程推送的有效负载数据， 使用HTTP/2支持的最大负载量为4096比特，即512字节，传统的则为256个字节。
//{ "aps" :{
//     "alert" : "You're invited",
//     "category" : "INVITE_CATEGORY",
//     "sound" : "default",
//     "content-availabel" : 1 // 静默推送，当收到静默推送消息的时候，应用会在后台从服务器获取数据或者在后台执行一会操作。
// }
//}

// alert
//{ "aps" :{
//    "alert" : {
//        "action-loc-key" : "Open",
//        "body" : "Hello, rose"
//    },
//     "category" : "INVITE_CATEGORY",
//     "sound" : "default",
//     "content-availabel" : 1
// }
//}

#import "SimpleAppDelegate.h"
#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

#define LOC_COORDINATE CLLocationCoordinate2DMake(123,123) // CLLocationCoordinate2D 
#define LOC_RADIUS 17.0 //CLLocationDistance
#define LOC_IDENTIFIER @"identifier"

@interface SimpleAppDelegate()<CLLocationManagerDelegate> {
}

@property (nonatomic, assign) BOOL registered;// 注册通知配置

@end

@implementation SimpleAppDelegate

// 每台设备会建立一个与APNs认证且加密过的长连接，并通过长连接接收推送信息。
// 注册， 发起， 接收展示

// devicetoken 可以识别到是哪台设备的哪个应用 是基于UDID通过算法生成的标志符（算法苹果没有公开）
// 推送信息是JSON格式
// 远程推送是无法确保一定会送达用户设备，所以不要将一些敏感重要数据通过远程推送传送，且推送的数据是无法通过任何手段恢复的，丢失就丢失了。当APNs尝试推送信息给设备，如果设备不在线则会在有限的时间保存，等连接上设备推送给设备。但只会保存最近的一条信息，如果有多条信息发给离线的设备，新的推送信息会取代旧的信息，旧的信息也就会被丢弃。并且离线时间比较久的话，连最近的一条推送信息也会被丢弃。
// 基于地理位置的本地推送 当用户进入或离开指定的地理范围内，会接收到推送信息。首先，应用需要支持Core Location
// 静默通知(Silent Remote Notifications) 收到通知后，没有通知提醒，后台执行程序（更新内容操作等），用户无需点通知，打开应用，就会进入didReceiveRemoteNotification:fetchCompletionHandler回调,文档中提及如果是静默推送确保aps字典中没有alert,sound,badge等信息。在设置content-available为1的前提下， 测试了下添加alert，通知中心就会显示这条推送消息，这还叫静默通知吗,点击该信息就又进入回调中了 ！sound就是会听到声音； badge就是会看到图标，通知中心没有显示信息，但也很不友好啊。苹果设计时为什么不进行短路处理，有content-available属性值为1时就是静默通知 －－22rd,August,2016

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self.window makeKeyAndVisible];
    
    [self registUserNotification];// 注册远程推送消息，即默认也注册了本地推送消息
    
    // 如果使用didReceiveRemoteNotification:fetchCompletionHandler回调则会处理程序终结的推送信息，则无需在didFinishLaunchingWithOptions中再重复获取该信息，但本地通知还是要在这里接收。
    if (launchOptions) {//  应用退出后再进入调用，点击提示信息(横幅，通知中心，提示框)进入应用。ps:通知中心有推送消息，但如果直接点击应用图标进入则无法获取到储存的通知信息
        UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (localNotification) {
            // 收到本地通知
            ViewController *vc = (ViewController *)self.window.rootViewController;
            NSString *alertMsg = [localNotification.userInfo objectForKey:@"alert"];
            vc.localNotificationLB.text = alertMsg;
            application.applicationIconBadgeNumber = localNotification.applicationIconBadgeNumber - 1;
        }
    }
    
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
        // devicetoken的获取不会造成性能问题，苹果已经做过优化
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
        // Categories 用于标识通知的目的 通过categories标志符决定如何处理通知。 从iOS8开始，还可以在通知处添加按钮等，主要是提供入口让用户可以快速的响应该推送信息。UIMutableUserNotificationAction
        // 可交互的通知以及可以处理用户输入的通知(通知中心直接回复内容)
        UIMutableUserNotificationCategory *category = [self createUNCategoryObject];
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert categories: [NSSet setWithObject: category]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        
        
        self.registered = YES;
        self.userNotificationType = UserNotificationRemote;
    }
#endif
}


// 移除本地通知
- (void)removeLocalNotification {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
// 本地通知 -- 应用在后台，点击通知中心/点击横幅/点击弹窗进入 ｜ 应用在前台收到本地通知进入该回调
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification  {
    if (application.applicationState == UIApplicationStateActive) {
        // 应用在前台
        NSLog(@"UIApplicationStateactive");
    } else if (application.applicationState == UIApplicationStateInactive) {
        // 应用从后台进入前台
        NSLog(@"UIApplicationStateInactive");
    } else {
        NSLog(@"UIApplicationStateBackground");
    }
    // 基于地理位置的本地通知
    // #pragma mark 基于地理位置的本地通知
    CLRegion *region = notification.region;
    if (region) {
        // 进入了指定区域(地理位置)
    }
    NSDictionary *userInfo = notification.userInfo;
    ViewController *vc = [self showNotificationMsgOnViewController];
    vc.localNotificationLB.text = [userInfo valueForKey:@"alert"];
}

// 远程推送
// [solved]Question: 静默推送， 推送信息到达设备后会调用该回调，点击通知信息进入应用后又会再一次进入该回调。那岂不是执行了两次该回调，也就是相同的操作执行两次吗？ 还是说通过当前应用在前后台 分离处理 。 Answer: 我所说的这种情况是设置了静默通知，还设置了alert,sound,badge属性，导致通知中心显示了推送信息，提供了第二次进入该回调的入口。
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    if (application.applicationState == UIApplicationStateActive) {
        // 应用在前台
        NSLog(@"UIApplicationStateactive");
    } else if (application.applicationState == UIApplicationStateInactive) {
        // 应用从后台进入前台
        NSLog(@"UIApplicationStateInactive");
    } else {
        NSLog(@"UIApplicationStateBackground");
    }
    userInfo = [userInfo valueForKey:@"aps"];
    ViewController *vc = [self showNotificationMsgOnViewController];
    vc.remoteNotificationLB.text = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"alert"]];
    
    // [todo]Question: content-available 设为1 代表静默推送，1)但我测试的时候只要aps中添加了content-available属性不伦值为0还是1都会进入该回调，且获取 contentAvailabel值时都是返回true 。2)静默推送 不懂  文档里也是说值设为1的时候代表静默推送，不知道是哪里出了问题 22rd,August,2016 3) 当1，2问题解决的时候，又出现了一个新的问题，什么时候需要将content-availabel设为0呢，也就是非静默通知。 设为1的情况就是需要在不显示提醒用户的情况执行数据更新等后台工作。又比如设置了 content-available又设置了badge,sound,alert信息，那已经不是静默通知了，为什么设计成这样。 4) 发送静默推送的时候如果应用在前台的时候应该怎么处理呢
    // Answer: 1)对于这个问题，文档中有提及，确实在只要包含该属性则会进入该回调。2)对于第二个问题，文档中有声明该属性的类型为number类型。3)问题提问在这里https://segmentfault.com/q/1010000006679726
    // Think: 3) content-available 这个是内容可用的意思， 后台静默通知 内容可用 设为0则代表内容不可用吗，那推送给用户干嘛，
    // 使用场景： 1) 通过静默通知获取用户当前位置发送给服务器端;2) 后台下载(获取内容更新)下次进入应用时可直接读取，比如Email更新,订阅内容同步;
    NSNumber *contentNumber= [userInfo valueForKey:@"content-available"];
    BOOL contentAvailable = contentNumber.boolValue;
    if (contentAvailable) {
        // 静默通知
        NSLog(@"静默推送");
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURL *url = [[NSURL alloc] initWithString:@"http://blog.csdn.net/jolie_yang"];
        NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                completionHandler(UIBackgroundFetchResultFailed);
            }
            if (data) {
                completionHandler(UIBackgroundFetchResultNewData);
                NSLog(@"show data:%@", data);
            }
        }];
        [task resume];
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}
// 本地通知-接收用户点击通知提示信息自定义按钮事件
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    // identifier为CategoryAction的唯一标识符
    if ([identifier isEqualToString:@"Accept_identifier"]) {
        NSLog(@"rose show invite");
    }
    completionHandler();
}
// 远程推送-接收用户点击通知提示信息自定义按钮事件
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler {
    // identifier为CategoryAction的唯一标识符
    
    completionHandler();
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
    // 网上看到资料，[todo]iOS9.0以后的版本卸载重装才会改变,iOS7与iOS8是不会改变的,不知是否是这样
    [self addDeviceToken:deviceToken];
    NSLog(@"devicetoken:%@", deviceToken);
}
// 获取deviceToken失败,查看错误信息吧
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // todo 获取错误日志
    NSLog(@"Error in Regist devicetoken: %@", error.localizedDescription);
}
- (void)addDeviceToken:(NSData *)deviceToken {
    // 判断deviceToken 是否更改
     NSString *deviceTokenKey = @"devicetoken";
     NSData *existToken = [[NSUserDefaults standardUserDefaults] valueForKey:deviceTokenKey];
     if (![existToken isEqualToData:deviceToken]) {// 原先并没有上传过devicetoken与devicetoken更改都会上传到服务器上
         [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:deviceTokenKey];
         // todo 考虑到同一个帐号可能会在多台设备上登陆，因而同一个帐号会有多个devicetoken，通过设备UUID+deviceToken确保一个设备只有一个deviceToken。
         [self sendProviderDeviceToken:deviceToken];
     }
    
}
// 发送deviceToken给网关，也就是上传到服务器上
- (void)sendProviderDeviceToken:(NSData *)deviceToken {
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
- (UIMutableUserNotificationAction *)createUNActionObjectWithTitle:(NSString *)title {
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = [NSString stringWithFormat:@"%@_identifier", title];
    acceptAction.title = title;// button上面的字
    acceptAction.activationMode = UIUserNotificationActivationModeBackground;// 激活后台应用程序，除非已在前台 ...?没懂
    acceptAction.destructive = NO;// ...?
    acceptAction.authenticationRequired = NO;// 执行该操作是否需要用户的认证(指是否需要用户解锁设备才可执行该操作)
    
    return acceptAction;
}
- (UIMutableUserNotificationCategory *)createUNCategoryObject {
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    inviteCategory.identifier = @"INVITE_CATEGORY";
    [inviteCategory setActions:@[[self createUNActionObject],[self createUNActionObjectWithTitle:@"Reject"],[self createUNActionObjectWithTitle:@"other"]] forContext:UIUserNotificationActionContextDefault];
    [inviteCategory setActions:@[[self createUNActionObject],[self createUNActionObjectWithTitle:@"Reject"]] forContext:UIUserNotificationActionContextMinimal];// [todo]我的手机测试显示的是ContentxMinimal，所以是跟内存有关嘛?
    
    return inviteCategory;
}


#pragma mark 基于地理位置的本地通知
- (void)registLocationBasedLocalNotification {
}
// 第一次发起授权地理服务请求时，应用会询问用户是否允许该请求。Info.plist中NSLocationWhenInUseUsageDescription可以配置发起请求时显示的文本,该属性是必须配置的，如果未配置则无法开启该服务
- (void)authorizeLocation {
    CLLocationManager *locManager = [[CLLocationManager alloc] init];
    locManager.delegate = self;
    // 发起授权跟踪用户的地理位置并启用基于地理位置的本地通知
    [locManager requestWhenInUseAuthorization];
}
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    BOOL canUseLocationNotifications = (status == kCLAuthorizationStatusAuthorizedWhenInUse);
    
    if (canUseLocationNotifications) {
        [self startShowingNotifications];
    }
    
}
// LOC_COORDINATE LOC_RADIUS LOC_IDENTIFIER
- (void)startShowingNotifications {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"You have arrived";
    localNotification.regionTriggersOnce = YES;
    
    localNotification.region = [[CLCircularRegion alloc] initWithCenter:LOC_COORDINATE radius:LOC_RADIUS identifier:LOC_IDENTIFIER];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}
@end
