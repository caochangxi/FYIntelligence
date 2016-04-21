//
//  FYFDBHViewController.m
//  FYIntelligence
//
//  Created by changxicao on 15/10/15.
//  Copyright © 2015年 changxicao. All rights reserved.
//

#import "FYFDBHViewController.h"

@interface FYFDBHViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *postionPickView;
@property (weak, nonatomic) IBOutlet UIPickerView *temPickView;
@property (strong, nonatomic) NSArray *positionArray;
@property (strong, nonatomic) NSArray *temArray;
@property (strong, nonatomic) NSString *startValue;
@property (strong, nonatomic) NSString *endValue;

@end

@implementation FYFDBHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.positionArray = @[@"01", @"02", @"03", @"04", @"05"];
    self.temArray = @[@"06", @"07", @"08", @"09", @"10"];
    self.startValue = [self.positionArray firstObject];
    self.endValue = [self.temArray firstObject];
    self.title = @"防冻保护";
    [self getInfo];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if([pickerView isEqual:self.temPickView]){
        return self.temArray.count;
    } else{
        return self.positionArray.count;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0f * XFACTOR;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if([pickerView isEqual:self.temPickView]){
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:28.0f];
        label.textColor = [UIColor whiteColor];
        label.text = [self.temArray objectAtIndex:row];
        [label sizeToFit];
        return label;
    } else{
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:28.0f];
        label.textColor = [UIColor whiteColor];
        label.text = [self.positionArray objectAtIndex:row];
        [label sizeToFit];
        return label;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if([pickerView isEqual:self.temPickView]){
        self.endValue = [self.temArray objectAtIndex:row];
    } else{
        self.startValue = [self.positionArray objectAtIndex:row];
    }
}

- (void)getInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *responseString = [[FYUDPNetWork sharedNetWork] sendMessage:kGETFDBHCmd type:1];
        if ([responseString containsString:@"OFF"]||[responseString containsString:@"ERROR"]) {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{

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

            NSString *value1 = [responseString substringWithRange:((NSTextCheckingResult *)[MResult objectAtIndex:0]).range];
            if ([self.positionArray indexOfObject:value1] != NSNotFound) {
                [self.postionPickView selectRow:[self.positionArray indexOfObject:value1] inComponent:0 animated:NO];
                self.startValue = value1;
            }
            NSString *value2 = [responseString substringWithRange:((NSTextCheckingResult *)[MResult objectAtIndex:1]).range];
            if ([self.temArray indexOfObject:value2] != NSNotFound) {
                [self.temPickView selectRow:[self.temArray indexOfObject:value2] inComponent:0 animated:NO];
                self.endValue = value2;
            }
        });
    });
}

- (IBAction)sendMessage:(id)sender
{
    NSString *string = [NSString stringWithFormat:kFDBHCmd, self.startValue, self.endValue];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[FYUDPNetWork sharedNetWork] sendMessage:string type:1];
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end

