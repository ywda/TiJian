//
//  RecommendCell.h
//  TiJian
//
//  Created by lichaowei on 16/1/27.
//  Copyright © 2016年 lcw. All rights reserved.
/**
 *  个性化结果cell
 */

#import <UIKit/UIKit.h>

@interface RecommendCell : UITableViewCell

@property(nonatomic,retain)UIView *backView;
@property(nonatomic,retain)UIImageView *bgImageView;//背景图片


+ (CGFloat)heightForCellWithModel:(id)amodel;

- (void)setCellWithModel:(id)model;

@end
