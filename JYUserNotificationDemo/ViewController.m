//
//  ViewController.m
//  JYUserNotificationDemo
//
//  Created by Jolie_Yang on 16/8/17.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)scheduleLocalNotification:(id)sender {
    [self addLocalNotification];
}


#pragma mark 本地通知
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
    
    localNotification.category = @"INVITE_CATEGORY";
    // 2.3 设置用户信息
    localNotification.userInfo = @{@"id":@1, @"alert":@"rose"};
    
    // 3. 发起通知
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
