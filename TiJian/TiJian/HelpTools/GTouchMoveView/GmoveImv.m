//
//  GmoveImv.m
//  testTouchMove
//
//  Created by gaomeng on 15/4/1.
//  Copyright (c) 2015年 gaomeng. All rights reserved.
//

#import "GmoveImv.h"


@implementation GmoveImv

- (id)initWithFrame:(CGRect)frame imageName:(NSString*)imvName
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //允许用户交互
        self.userInteractionEnabled = YES;
        
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width*0.5-7.5, frame.size.height - 22 + 2, 15, 22)];
        [imv setImage:[UIImage imageNamed:imvName]];
        
        [self addSubview:imv];
    }
    return self;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //保存触摸起始点位置
    CGPoint point = [[touches anyObject] locationInView:self];
    _startPoint = point;
    
    //该view置于最前
    [[self superview] bringSubviewToFront:self];
    
    [self becomeFirstResponder];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //计算位移=当前位置-起始位置
    CGPoint point = [[touches anyObject] locationInView:self];
    float dx = point.x - _startPoint.x;
    float dy = point.y - _startPoint.y;
    
    //计算移动后的view中心点
    CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
    
    
    /* 限制用户不可将视图托出屏幕 */
    float halfx = CGRectGetMidX(self.bounds);
    //x坐标左边界
    newcenter.x = MAX(halfx, newcenter.x);
    //x坐标右边界
    newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);
    
    //y坐标同理
    float halfy = CGRectGetMidY(self.bounds);
    newcenter.y = MAX(halfy, newcenter.y);
    newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);
    
    //移动view
    self.center = newcenter;
    
//    NSLog(@"GmoveImv x = %f  y = %f",self.center.x,self.center.y);
    
    if (self && [self.delegate respondsToSelector:@selector(theValue:)]) {
        [self.delegate theValue:self.center.x];
    }
    
}

#pragma mark - setter
//update by lcw
/**
 *  外部控制滑块
 *
 *  @param targetX x坐标值
 */
-(void)setTargetX:(CGFloat)targetX
{
    self.left = targetX;
    
    if (self && [self.delegate respondsToSelector:@selector(theValue:)]) {
        [self.delegate theValue:self.center.x];
    }
}


@end
