//
//  LPickerView.m
//  TiJian
//
//  Created by lichaowei on 16/5/16.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "LPickerView.h"

@interface LPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIView *_pickerBgView;
    UIPickerView *_pickerView;
}

@end

@implementation LPickerView

-(instancetype)initWithDelegate:(id<UIPickerViewDataSource>)dataSource
                       delegate:(id<UIPickerViewDelegate>)delegate
                    pickerBlock:(LPickerBlock)pickerBlock
{
    self = [super initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    if (self) {
        self.alpha = 0.f;//默认初始
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToCancel:)];
        [self addGestureRecognizer:tap];
        
        _pickerBlock = pickerBlock;
        
        //初始为
        _pickerBgView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 216 + 40)];
        _pickerBgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_pickerBgView];
        
        //上线
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [_pickerBgView addSubview:line];
        
        //下线
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 40, DEVICE_WIDTH, 0.5f)];
        line2.backgroundColor = DEFAULT_LINECOLOR;
        [_pickerBgView addSubview:line2];
        
        //地区pickview
        _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, DEVICE_WIDTH, 216)];
        _pickerView.delegate = delegate ? : self;
        _pickerView.dataSource = dataSource ? : self;
        [_pickerBgView addSubview:_pickerView];
        
        //    //    - (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated
        //    NSString *age = [self textFieldWithTag:104].text;
        //    if (![LTools isEmpty:age]) {
        //        [_pickeView selectRow:[age intValue] - 1 inComponent:0 animated:NO];
        //    }else
        //    {
        //        [_pickeView selectRow:26 - 1 inComponent:0 animated:NO];
        //    }
        
        //取消按钮
        UIButton *quxiaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        quxiaoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [quxiaoBtn setTitle:@"取消" forState:UIControlStateNormal];
        [quxiaoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        quxiaoBtn.frame = CGRectMake(10, 5, 60, 30);
        [quxiaoBtn addTarget:self action:@selector(clickToCancel:) forControlEvents:UIControlEventTouchUpInside];
//        [quxiaoBtn setBorderWidth:1 borderColor:DEFAULT_TEXTCOLOR];
//        [quxiaoBtn addCornerRadius:3.f];
        
        //确定按钮
        UIButton *quedingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        quedingBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [quedingBtn setTitle:@"确定" forState:UIControlStateNormal];
        [quedingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        quedingBtn.frame = CGRectMake(DEVICE_WIDTH - 70, 5, 60, 30);
//        [quedingBtn setBorderWidth:1 borderColor:DEFAULT_TEXTCOLOR];
//        [quedingBtn addCornerRadius:3.f];
        [quedingBtn addTarget:self action:@selector(clickToSure:) forControlEvents:UIControlEventTouchUpInside];
        
        [_pickerBgView addSubview:quedingBtn];
        [_pickerBgView addSubview:quxiaoBtn];
    }
    return self;
}

#pragma mark -  事件处理

/**
 *  刷新数据
 */
- (void)reloadAllComponents
{
    [_pickerView reloadAllComponents];
}

/**
 *  设置显示row component
 */
- (void)selectrow:(int)row component:(int)component animated:(BOOL)animated
{
    [_pickerView selectRow:row inComponent:component animated:animated];
}

-(void)pickerViewShow:(BOOL)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    __weak typeof (self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        
        weakSelf.alpha = show ? 1 : 0;
        _pickerBgView.top = show ? (DEVICE_HEIGHT - _pickerBgView.height) : DEVICE_HEIGHT;
        
    }];
}

- (void)clickToCancel:(UIButton *)sender
{
    [self pickerViewShow:NO];
    
    if (_pickerBlock) {
        _pickerBlock(ACTIONTYPE_CANCEL,  (int)[_pickerView selectedRowInComponent:0],0);
    }
}

- (void)clickToSure:(UIButton *)sender
{
    [self pickerViewShow:NO];
    if (_pickerBlock) {
        _pickerBlock(ACTIONTYPE_SURE,  (int)[_pickerView selectedRowInComponent:0],0);
    }}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return 150;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    UIView *pickerCell = view;
    if (!pickerCell) {
        pickerCell = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, [UIScreen mainScreen].bounds.size.width, 45.0f}];
    }
    return pickerCell;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)componen{
    
    return [NSString stringWithFormat:@"%d",(int)row + 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSLog(@"年龄%d",(int)row + 1);
}

@end