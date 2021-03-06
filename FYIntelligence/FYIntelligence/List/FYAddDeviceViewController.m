//
//  FYAddDeviceViewController.m
//  FYIntelligence
//
//  Created by changxicao on 15/10/11.
//  Copyright © 2015年 changxicao. All rights reserved.
//

#import "FYAddDeviceViewController.h"

@interface FYAddDeviceViewController ()

@property (weak, nonatomic) IBOutlet UIView *inputBgView;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *rememberPwdButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (assign, nonatomic) BOOL isRemember;

@end

@implementation FYAddDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加设备";
    self.userNameLabel.text = [self.userNameLabel.text stringByAppendingString:kAppDelegate.userName];
    [self.userNameLabel sizeToFit];

    self.inputBgView.layer.masksToBounds = YES;
    self.inputBgView.layer.cornerRadius = 2.0f;

    [self.userField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwdField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];

    CGRect frame = self.lineView.frame;
    frame.size.height = 0.5f;
    self.lineView.frame = frame;

    self.loginButton.layer.masksToBounds = YES;
    self.loginButton.layer.cornerRadius = 2.0f;

    self.rememberPwdButton.layer.masksToBounds = YES;
    self.rememberPwdButton.layer.cornerRadius = 3.0f;
    self.rememberPwdButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.rememberPwdButton.layer.borderWidth = 1.0f;

    UIImage *normalImage = [UIImage imageNamed:@"btn_login_normal"];
    UIImage *pressImage = [UIImage imageNamed:@"btn_login_press"];
    [self.loginButton setBackgroundImage:[normalImage resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 15.0f, 15.0f, 15.0f) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[pressImage resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 15.0f, 15.0f, 15.0f) resizingMode:UIImageResizingModeStretch] forState:UIControlStateHighlighted];
    if (kAppDelegate.ESPDescription && kAppDelegate.ESPDescription.length > 0) {
        [[FYTCPSpecialNetWork shareNetEngine] createClientTcpSocket];
    }
}

- (IBAction)clickRememberButton:(UIButton *)sender {
    self.isRemember = !self.isRemember;
    __weak typeof(self) weakSelf = self;
    NSString *request = [NSString stringWithFormat:@"%@",kAddDeviceCmd];
    [[FYTCPSpecialNetWork shareNetEngine] sendRequest:request complete:^(NSDictionary *dic) {
        NSString *string = [dic objectForKey:kResponseString];
        NSLog(@"%@",string);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = string;
            if (str.length >= 7) {
                str = [string substringToIndex:7];
            }
            weakSelf.userField.text = str;
        });
    }];
}

- (IBAction)nextClick:(id)sender
{
    if (self.userField.text.length == 0) {
        return;
    }
    if (self.pwdField.text.length == 0) {
        return;
    }
    NSString *request = [NSString stringWithFormat:kAddedDeviceCmd,self.userField.text, self.pwdField.text, kAppDelegate.userName, kAppDelegate.userPWD];
    __weak typeof(self) weakSelf = self;
    [[FYTCPNetWork shareNetEngine] sendRequest:request complete:^(NSDictionary *dic) {
        if ([[dic objectForKey:kResponseString] rangeOfString:@"SUC"].location != NSNotFound) {
            [FYProgressHUD showMessageWithText:@"添加设备成功"];
            UIViewController *controller = [weakSelf.navigationController.viewControllers objectAtIndex:1];
            [weakSelf.navigationController popToViewController:controller animated:YES];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
