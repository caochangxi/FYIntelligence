//
//  FYHeatCycleViewController.m
//  FYIntelligence
//
//  Created by changxicao on 16/1/6.
//  Copyright © 2016年 changxicao. All rights reserved.
//

#import "FYHeatCycleViewController.h"
#import "FYEnterPINViewController.h"
#import "FYHeatCycleSettingViewController.h"
#import "FYAboutViewController.h"

@interface FYHeatCycleViewController ()<FYEnterPINDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;

@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIImageView *fanBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fanImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgzImageView;
@property (weak, nonatomic) IBOutlet UIImageView *hswdImageView;
@property (weak, nonatomic) IBOutlet UIImageView *jxImageView;
@property (weak, nonatomic) IBOutlet UILabel *bgzLabel;
@property (weak, nonatomic) IBOutlet UILabel *hswdLabel;
@property (weak, nonatomic) IBOutlet UILabel *jxLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;
@property (weak, nonatomic) IBOutlet UILabel *fourthLabel;
@property (weak, nonatomic) IBOutlet UIButton *powerButton;
@property (strong, nonatomic) NSString *runState;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger currentTime;
@property (strong, nonatomic) NSString *responseString;
@property (assign, nonatomic) NSInteger time;
@end

@implementation FYHeatCycleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.bgImageView.image = [UIImage imageNamed:@"rsxh_bj"];
    CGRect frame = self.topView.frame;
    frame.origin.y *= XFACTOR;
    frame.size.height *= XFACTOR;
    self.topView.frame = frame;

    frame = self.fanBgImageView.frame;
    frame.origin.x *= XFACTOR;
    frame.size.width *= XFACTOR;
    frame.size.height *= XFACTOR;
    self.fanBgImageView.frame = frame;

    frame = self.fanImageView.frame;
    frame.origin.x *= XFACTOR;
    frame.size.width *= XFACTOR;
    frame.size.height *= XFACTOR;
    self.fanImageView.frame = frame;

    frame = self.bgzImageView.frame;
    frame.origin.y *= XFACTOR;
    self.bgzImageView.frame = frame;

    frame = self.hswdImageView.frame;
    frame.origin.y *= XFACTOR;
    self.hswdImageView.frame = frame;

    frame = self.jxImageView.frame;
    frame.origin.y *= XFACTOR;
    self.jxImageView.frame = frame;

    frame = self.bgzLabel.frame;
    frame.origin.y *= XFACTOR;
    self.bgzLabel.frame = frame;

    frame = self.jxLabel.frame;
    frame.origin.y *= XFACTOR;
    self.jxLabel.frame = frame;

    frame = self.hswdLabel.frame;
    frame.origin.y *= XFACTOR;
    self.hswdLabel.frame = frame;

    frame = self.middleView.frame;
    frame.origin.y *= YFACTOR;
    self.middleView.frame = frame;

    frame = self.bottomView.frame;
    frame.origin.y = CGRectGetMaxY(self.middleView.frame) * YFACTOR;
    self.bottomView.frame = frame;

    self.currentTime = 0;

    [self addObserver:self forKeyPath:@"currentTime" options:NSKeyValueObservingOptionNew context:nil];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    [self getInfo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.time = 25;
    [[FYUDPNetWork shareNetEngine] resumeMainData];
}

- (void)backButtonClick:(UIButton *)button
{
    [self.timer invalidate];
    [super backButtonClick:button];
}

- (void)getInfo
{
    __weak typeof(self) weakSelf = self;
    [[FYUDPNetWork shareNetEngine] udpMainType:FYMainTypeHot startRequestMainData:^(BOOL success, NSString *responseString) {
        weakSelf.responseString = responseString;
    }];
}

- (void)startAnimation
{
    self.fanImageView.image = [UIImage animatedImageWithImages:
  @[[UIImage imageNamed:@"yelun"], [UIImage imageNamed:@"yelun_1"], [UIImage imageNamed:@"yelun_2"], [UIImage imageNamed:@"yelun_3"], [UIImage imageNamed:@"yelun_4"], [UIImage imageNamed:@"yelun_5"], [UIImage imageNamed:@"yelun_6"], ] duration:0.7f];
}

- (void)stopAnimation
{
    self.fanImageView.image = [UIImage imageNamed:@"yelun"];
}

- (void)countDown
{
    if (self.currentTime <= 0) {
        if (self.time == 0) {
            self.time = 25;
            [[FYUDPNetWork shareNetEngine] fastResumeMainData];
            return;
        }
        self.time--;
        [self AnalyticalData:self.responseString];
        return;
    }
    self.time = 25;
    self.bgzLabel.text = [self secondsToMinutes:self.currentTime];
    self.jxLabel.text = [self secondsToMinutes:self.currentTime];
    self.currentTime--;
}

- (NSString *)secondsToMinutes:(NSInteger)seconds
{
    if (seconds <= 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"%ld秒",(long)seconds];
}

- (void)AnalyticalData:(NSString *)responseString
{
    if (responseString.length == 0) {
        return;
    }
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern: @"\\w+" options:0 error:nil];
    NSMutableArray *results = [NSMutableArray array];
    [regularExpression enumerateMatchesInString:responseString options:0 range:NSMakeRange(0, responseString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        [results addObject:result];
    }];
    NSComparator cmptr = ^(NSTextCheckingResult *obj1, NSTextCheckingResult *obj2){
        if (obj1.range.location > obj2.range.location) {
            return (NSComparisonResult)NSOrderedDescending;
        } else if (obj1.range.location < obj2.range.location) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    NSArray *MResult = [results sortedArrayUsingComparator:cmptr];
    NSString *value = [responseString substringWithRange:((NSTextCheckingResult *)[MResult objectAtIndex:0]).range];

    //状态
    NSString *state = value;
    self.runState = state;
    self.bgzImageView.image = [UIImage imageNamed:@"bgz"];
    [self.powerButton setImage:[UIImage imageNamed:@"rsxhpower"] forState:UIControlStateNormal];
    [self stopAnimation];
    if ([state isEqualToString:@"00"]) {
        self.stateImageView.image = [UIImage imageNamed:@"rsxhshutdown"];
        self.stateImageView.hidden = NO;
        [self.powerButton setImage:[UIImage imageNamed:@"rsxhpoweroff"] forState:UIControlStateNormal];
        self.bgzImageView.hidden = YES;
        self.bgzLabel.hidden = YES;

        self.jxImageView.hidden = YES;
        self.jxLabel.hidden = YES;
    } else if ([state isEqualToString:@"01"]){
        self.stateImageView.image = [UIImage imageNamed:@"djz"];
        self.stateImageView.hidden = NO;
        self.bgzImageView.hidden = YES;
        self.bgzLabel.hidden = YES;

        self.jxImageView.hidden = YES;
        self.jxLabel.hidden = YES;
    } else if ([state isEqualToString:@"02"]){
        self.stateImageView.image = [UIImage imageNamed:@"bgz"];
        self.stateImageView.hidden = YES;
        self.bgzImageView.hidden = NO;
        self.bgzLabel.hidden = NO;

        self.jxImageView.hidden = YES;
        self.jxLabel.hidden = YES;
        [self startAnimation];
    } else if ([state isEqualToString:@"03"]){
        self.stateImageView.image = [UIImage imageNamed:@"jx"];
        self.stateImageView.hidden = YES;
        self.bgzImageView.image = [UIImage imageNamed:@"jx"];
        self.bgzImageView.hidden = YES;
        self.bgzLabel.hidden = YES;

        self.jxImageView.hidden = NO;
        self.jxLabel.hidden = NO;
    }
    //分
    value = [responseString substringWithRange:((NSTextCheckingResult *)[MResult objectAtIndex:1]).range];
    NSString *minute = value;
    //秒
    value = [responseString substringWithRange:((NSTextCheckingResult *)[MResult objectAtIndex:2]).range];
    NSString *second = value;
    //显示时间
    NSInteger time = [minute integerValue] * 60.0f + [second integerValue];
    self.currentTime = time;
    //温度
    value = [responseString substringWithRange:((NSTextCheckingResult *)[MResult objectAtIndex:3]).range];
    if ([value isEqualToString:@"111"]) {
        value = @"未连接";
    } else if ([value isEqualToString:@"112"]){
        value = @"短路";
    } else{
        value = [value stringByAppendingString:@"°C"];
    }
    self.hswdLabel.text = value;

    //运行模式
    value = [responseString substringWithRange:((NSTextCheckingResult *)[MResult objectAtIndex:4]).range];
    NSInteger mode = [value integerValue];

    self.firstLabel.textColor = [UIColor colorWithHexString:@"bebebe"];
    self.secondLabel.textColor = [UIColor colorWithHexString:@"bebebe"];
    self.thirdLabel.textColor = [UIColor colorWithHexString:@"bebebe"];
    self.fourthLabel.textColor = [UIColor colorWithHexString:@"bebebe"];

    if ((mode & 0x01) != 0){
        self.fourthLabel.textColor = [UIColor whiteColor];
    }
    if ((mode & 0x02) != 0){
        self.thirdLabel.textColor = [UIColor whiteColor];
    }
    if ((mode & 0x04) != 0){
        self.secondLabel.textColor = [UIColor whiteColor];
    }
    if ((mode & 0x08) != 0){
        self.firstLabel.textColor = [UIColor whiteColor];
    }
    self.responseString = @"";
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentTime"]) {
        NSInteger time = [[change objectForKey:@"new"] integerValue];
        if (time <= 0 && ([self.runState isEqualToString:@"02"] || [self.runState isEqualToString:@"03"])) {
            [[FYUDPNetWork shareNetEngine] fastResumeMainData];
        }
    }
}

- (IBAction)userClick:(UIButton *)button
{
    [[FYUDPNetWork shareNetEngine] stopMainData];
    [button setImage:[UIImage imageNamed:@"rsxhsdxhp"] forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    NSString *globleString = [NSString stringWithFormat:@"%ld",(long)kAppDelegate.globleNumber];
    NSString *request = [NSString stringWithFormat:kNoPINString,kAppDelegate.deviceID,kAppDelegate.userName,globleString,kHotSDXHCmd];
    [[FYUDPNetWork shareNetEngine] sendRequest:request complete:^(BOOL finish, NSString *responseString) {
        [button setImage:[UIImage imageNamed:@"rsxhsdxh"] forState:UIControlStateNormal];
        [[FYUDPNetWork shareNetEngine] resumeMainData];
        if(finish){
            [weakSelf AnalyticalData:responseString];
        } else{
            
        }
    }];
}

- (IBAction)powerClick:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认此操作？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    [alert show];

}

- (IBAction)paramClick:(id)sender
{
    //    NSString *number = [kAppDelegate.pinDictionary objectForKey:kAppDelegate.deviceID];
    //    if(!number || number.length == 0){
    FYEnterPINViewController *controller = [[FYEnterPINViewController alloc] initWithNibName:@"FYEnterPINViewController" bundle:nil];
    controller.delegate = self;
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    //        return;
    //    }
    //    kAppDelegate.pinNumber = number;
    //    FYHeatCycleSettingViewController *controller = [[FYHeatCycleSettingViewController alloc] init];
    //    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)aboutClick:(id)sender
{
    FYAboutViewController *controller = [[FYAboutViewController alloc] initWithNibName:@"FYAboutViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didEnterAllPIN:(NSString *)pinNumber index:(NSInteger)index
{
    kAppDelegate.pinNumber = pinNumber;
    [kAppDelegate.pinDictionary setObject:pinNumber forKey:kAppDelegate.deviceID];
    FYHeatCycleSettingViewController *controller = [[FYHeatCycleSettingViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[FYUDPNetWork shareNetEngine] stopMainData];
    [FYProgressHUD hideHud];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        [[FYUDPNetWork shareNetEngine] stopMainData];
        __weak typeof(self) weakSelf = self;
        NSString *request = @"";
        NSString *globleString = [NSString stringWithFormat:@"%ld",(long)kAppDelegate.globleNumber];
        if ([self.runState isEqualToString:@"00"]) {
            request = [NSString stringWithFormat:kNoPINString,kAppDelegate.deviceID,kAppDelegate.userName,globleString,@"power$1"];
        } else{
            request = [NSString stringWithFormat:kNoPINString,kAppDelegate.deviceID,kAppDelegate.userName,globleString,@"power$0"];
        }
        [[FYUDPNetWork shareNetEngine] sendRequest:request complete:^(BOOL finish, NSString *responseString) {
            [[FYUDPNetWork shareNetEngine] resumeMainData];
            if(finish){
                [weakSelf AnalyticalData:responseString];
            } else{
                
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.timer = nil;
    [self removeObserver:self forKeyPath:@"currentTime"];
}


@end
