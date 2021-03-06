//
//  UIView+Additions.h
//  YiYiProject
//
//  Created by lichaowei on 15/5/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Additions)

/**
 *  view 封装一个button,支持点击(建议使用 addTapGestureTaget:(id)target)
 *
 *  @param target   target
 *  @param selector slector
 *  @param tag      包含button tag值
 */
- (void)addTaget:(id)target action:(SEL)selector tag:(NSInteger)tag;

/**
 *  给view添加手势
 *
 *  @param target
 *  @param selector
 *  @param imageViewTag
 */
- (void)addTapGestureTaget:(id)target action:(SEL)selector imageViewTag:(NSInteger)imageViewTag;

/**
 *  给view加圆角
 *
 *  @param radius 角度
 */
- (void)addCornerRadius:(CGFloat)radius;

/**
 *  加圆角==>圆形
 */
- (void)addRoundCorner;

/**
 *  加边框
 *
 *  @param borderWidth  边框宽度
 *  @param _borderColor 边框颜色
 */
- (void)setBorderWidth:(CGFloat)borderWidth
           borderColor:(UIColor *)_borderColor;

@end
