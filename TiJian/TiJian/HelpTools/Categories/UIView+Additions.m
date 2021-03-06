//
//  UIView+Additions.m
//  YiYiProject
//
//  Created by lichaowei on 15/5/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

- (void)addTaget:(id)target action:(SEL)selector tag:(NSInteger)tag
{
    self.userInteractionEnabled = YES;
    UIButton *personalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [personalButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    personalButton.frame = self.bounds;
    personalButton.tag = tag;
    [self addSubview:personalButton];
}

- (void)addTapGestureTaget:(id)target action:(SEL)selector imageViewTag:(NSInteger)imageViewTag
{
    self.userInteractionEnabled = YES;
    self.tag = imageViewTag;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:target action:selector];
    [self addGestureRecognizer:tap];
}

- (void)addCornerRadius:(CGFloat)radius
{
    self.layer.cornerRadius = radius;
    self.clipsToBounds = YES;
}

- (void)addRoundCorner
{
    [self addCornerRadius:self.width/2.f];
}

/**
 *  加边框
 *
 *  @param borderWidth  边框宽度
 *  @param _borderColor 边框颜色
 */
- (void)setBorderWidth:(CGFloat)borderWidth
           borderColor:(UIColor *)_borderColor
{
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = _borderColor.CGColor;
}

@end
