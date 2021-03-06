//
//  FYPickerView.m
//  FYIntelligence
//
//  Created by changxicao on 15/10/14.
//  Copyright © 2015年 changxicao. All rights reserved.
//

#import "FYPickerView.h"

@interface FYPickerView ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSString *selectString;

@end

@implementation FYPickerView

- (instancetype)initWithFrame:(CGRect)frame unit:(NSString *)unit
{
    self = [super initWithFrame:frame];
    if(self){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f * XFACTOR, 200.0f * YFACTOR)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(150.0f * XFACTOR, 0.0f, 40.0f * XFACTOR, 150.0f * YFACTOR)];
        label.text = unit;
        label.textColor = [UIColor whiteColor];
        [view addSubview:label];
        [view addSubview:self.pickerView];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor colorWithHexString:@"FFD700"];
        [button addTarget:self action:@selector(didSelectString:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"确认" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        CGRect frame = button.frame;
        frame.size.width = 60.0f * XFACTOR;
        frame.size.height = 30.0f * XFACTOR;
        frame.origin.x = (200.0f * XFACTOR - CGRectGetWidth(frame)) / 2.0f;
        frame.origin.y = 160.0f * XFACTOR;
        button.frame = frame;
        [view addSubview:button];

        view.backgroundColor = [UIColor colorWithHexString:@"345654" alpha:0.9f];
        view.center = self.center;
        [self addSubview:view];
        self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    }
    return self;
}

- (void)loadDataArray:(NSArray *)array
{
    self.dataArray = array;
    [self.pickerView reloadAllComponents];
    [self.pickerView selectRow:self.dataArray.count / 2 inComponent:0 animated:NO];
    self.selectString = [self.dataArray objectAtIndex: self.dataArray.count / 2];
}

- (UIPickerView *)pickerView
{
    if(!_pickerView){
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(50.0f *XFACTOR, 0.0f, 100.0f * XFACTOR, 150.0f * YFACTOR)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.dataArray.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:28.0f];
    label.textColor = [UIColor whiteColor];
    label.text = [self.dataArray objectAtIndex:row];
    [label sizeToFit];
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0f * XFACTOR;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectString = [self.dataArray objectAtIndex:row]; 
}

- (void)didSelectString:(UIButton *)button
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(object:didSelectItem:)]){
        [self.delegate object:self.responseObject didSelectItem:self.selectString];
        [self removeFromSuperview];
    }
}

- (void)selectIndex:(NSInteger)index
{
    if(index != NSNotFound){
        [self.pickerView selectRow:index inComponent:0 animated:NO];
        self.selectString = [self.dataArray objectAtIndex:index];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self removeFromSuperview];
}


@end
