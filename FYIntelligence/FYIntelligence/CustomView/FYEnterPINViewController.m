//
//  FYEnterPINViewController.m
//  FYIntelligence
//
//  Created by changxicao on 15/10/11.
//  Copyright © 2015年 changxicao. All rights reserved.
//

#import "FYEnterPINViewController.h"

@interface FYEnterPINViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UITextField *textField2;
@property (weak, nonatomic) IBOutlet UITextField *textField3;
@property (weak, nonatomic) IBOutlet UITextField *textField4;
@property (weak, nonatomic) IBOutlet UIView *lineView1;
@property (weak, nonatomic) IBOutlet UIView *lineView2;
@property (weak, nonatomic) IBOutlet UIView *lineView3;
@property (strong, nonatomic) UITextField *nextField;

@end

@implementation FYEnterPINViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(0.0f, 0.0f, kScreenWidth, kScreenHeight);
    self.view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    self.bgView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:0.5f];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGFloat width = CGRectGetWidth(self.bgView.frame);
    CGFloat fieldWidth = CGRectGetWidth(self.textField1.frame);
    CGFloat margin = (width - 4.0f * fieldWidth) / 5.0f;

    CGRect frame = self.textField1.frame;
    frame.origin.x = margin;
    self.textField1.frame = frame;

    frame = self.textField2.frame;
    frame.origin.x = CGRectGetMaxX(self.textField1.frame) + margin;
    self.textField2.frame = frame;

    frame = self.textField3.frame;
    frame.origin.x = CGRectGetMaxX(self.textField2.frame) + margin;;
    self.textField3.frame = frame;

    frame = self.textField4.frame;
    frame.origin.x = CGRectGetMaxX(self.textField3.frame) + margin;;
    self.textField4.frame = frame;

    frame = self.lineView1.frame;
    frame.origin.x = CGRectGetMaxX(self.textField1.frame) + 4.0f;
    frame.size.width = margin - 8.0f;
    self.lineView1.frame = frame;

    frame = self.lineView2.frame;
    frame.origin.x = CGRectGetMaxX(self.textField2.frame) + 4.0f;
    frame.size.width = margin - 8.0f;
    self.lineView2.frame = frame;

    frame = self.lineView3.frame;
    frame.origin.x = CGRectGetMaxX(self.textField3.frame) + 4.0f;
    frame.size.width = margin - 8.0f;
    self.lineView3.frame = frame;

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([textField isEqual:self.textField1]){
        self.nextField = self.textField2;
    } else if([textField isEqual:self.textField2]){
        self.nextField = self.textField3;
    } else if([textField isEqual:self.textField3]){
        self.nextField = self.textField4;
    } else if([textField isEqual:self.textField4]){
        self.nextField = self.textField1;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(weakSelf.textField1.text.length > 0 && weakSelf.textField2.text.length > 0 && weakSelf.textField3.text.length > 0 && weakSelf.textField4.text.length > 0){
            [weakSelf enterAllPIN];
        } else{
            [weakSelf.nextField becomeFirstResponder];
        }
    });
    if(textField.text.length > 0){
        return NO;
    }
    return YES;
}

- (void)enterAllPIN
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didEnterAllPIN:)]){
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        NSString *pin = [NSString stringWithFormat:@"%@%@%@%@",self.textField1.text,self.textField2.text,self.textField3.text,self.textField4.text];
        [self.delegate didEnterAllPIN:pin];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end