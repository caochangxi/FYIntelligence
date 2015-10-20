//
//  FYProgressHUD.h
//  FYIntelligence
//
//  Created by changxicao on 15/10/20.
//  Copyright © 2015年 changxicao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYProgressHUD : NSObject

+ (void)showLoadingWithMessage:(NSString *)message;
+ (void)showMessageWithText:(NSString *)text;
+ (void)showMessageWithLongText:(NSString *)text;

+ (void)hideHud;

@end

