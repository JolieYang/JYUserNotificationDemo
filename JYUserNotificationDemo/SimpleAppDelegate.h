//
//  SimpleAppDelegate.h
//  JYUserNotificationDemo
//
//  Created by Jolie_Yang on 16/8/18.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UserNotificationType) {
    UserNotificationLocal = 0,
    UserNotificationRemote = 1
};

@interface SimpleAppDelegate : UIResponder<UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, assign) UserNotificationType userNotificationType;

@end
