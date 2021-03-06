//
//  ResultView.m
//  TiJian
//
//  Created by lichaowei on 15/12/4.
//  Copyright © 2015年 lcw. All rights reserved.
// 图片 两行文字 或者一行
// 按钮

#import "ResultView.h"
#define kDisOne 20
#define kDisTwo 5

@interface ResultView ()

@property(nonatomic,retain)UIImageView *imageView;
@property(nonatomic,retain)UILabel *titleLabel;
@property(nonatomic,retain)UILabel *contentLabel;

@end

@implementation ResultView

-(instancetype)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}

/**
 *  页面结果view
 *
 *  @param image   显示图标(可不填)
 *  @param title   标题(可不填)
 *  @param content 正文(可不填)
 *
 *  @return
 */
-(instancetype)initWithImage:(UIImage *)image
                       title:(NSString *)title
                     content:(NSString *)content
{
    self = [super initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0)];
    if (self) {
        
        self.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
        
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _imageView.image = image;
        [self addSubview:_imageView];
        
        if (image) {
            CGFloat imageWith = image.size.width;
            CGFloat imageHeight = image.size.height;
            
            imageWith = FitScreen(imageWith);
            imageWith = iPhone4 ? imageWith : imageWith * 0.8;
            
            imageHeight = FitScreen(imageHeight);
            imageHeight = iPhone4 ? imageHeight : imageHeight * 0.8;
            
            _imageView.size = CGSizeMake(imageWith, imageHeight);
            _imageView.centerX = self.width / 2;
        }
        
        CGFloat top = _imageView.bottom + kDisOne;
        
        if (title) {
            self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, top, DEVICE_WIDTH, 15) title:title font:14 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE];
            [self addSubview:_titleLabel];
            top = _titleLabel.bottom + kDisTwo;
        }
        
        if (content) {
            
            self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, top, DEVICE_WIDTH, 15) title:content font:12 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
            [self addSubview:_contentLabel];
            
            top = _contentLabel.bottom;
        }
        
        self.height = top;
    }
    
    return self;
}

/**
 *  拓展底部view
 *
 *  @param bottomView
 */
-(void)setBottomView:(UIView *)bottomView
{
    _bottomView = bottomView;
    
    if (bottomView) {
        bottomView.top = self.height + kDisOne;
        bottomView.centerX = self.width / 2.f;
        [self addSubview:bottomView];
        self.height = bottomView.bottom;
    }
}

-(void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

-(void)setContent:(NSString *)content
{
    _content = content;
    self.contentLabel.text = content;
}




-(instancetype)initWithNoBrandImage:(UIImage *)image
                              title:(NSString *)title
                            content:(NSString *)content
                              width:(CGFloat)theWidth{
    self = [super initWithFrame:CGRectMake(0, 0, theWidth, 0)];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _imageView.image = image;
        [self addSubview:_imageView];
        
        if (image) {
            CGFloat imageWith = image.size.width;
            CGFloat imageHeight = image.size.height;
            
            imageWith = FitScreen(imageWith);
            imageWith = iPhone4 ? imageWith : imageWith * 0.8;
            
            imageHeight = FitScreen(imageHeight);
            imageHeight = iPhone4 ? imageHeight : imageHeight * 0.8;
            
            _imageView.size = CGSizeMake(imageWith, imageHeight);
            _imageView.centerX = self.width / 2;
        }
        
        CGFloat top = _imageView.bottom + kDisOne;
        
        if (title) {
            self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, top, theWidth, 15) title:title font:14 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE];
            [self addSubview:_titleLabel];
            top = _titleLabel.bottom + kDisTwo;
        }
        
        if (!self.activityIndicationVeiw) {
            self.activityIndicationVeiw = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        }
        CGPoint center = self.titleLabel.center;
        center.y += 20;
        self.activityIndicationVeiw.color = [UIColor grayColor];
        [self addSubview:self.activityIndicationVeiw];
        self.activityIndicationVeiw.center = center;
        
        if (content) {
            
            self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, top, theWidth, 15) title:content font:12 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
            [self addSubview:_contentLabel];
            
            top = _contentLabel.bottom;
        }
        
        self.height = top;
    }
    
    return self;
}


-(instancetype)initWithNoHospitalImage:(UIImage *)image
                                 title:(NSString *)title
                               content:(NSString *)content
                                 width:(CGFloat)theWidth{
    
    self = [super initWithFrame:CGRectMake(0, 0, theWidth, DEVICE_HEIGHT - HMFitIphoneX_navcBarHeight)];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _imageView.image = image;
        [self addSubview:_imageView];
        
        if (image) {
            CGFloat imageWith = image.size.width;
            CGFloat imageHeight = image.size.height;
            
            imageWith = FitScreen(imageWith);
            imageWith = iPhone4 ? imageWith : imageWith * 0.8;
            
            imageHeight = FitScreen(imageHeight);
            imageHeight = iPhone4 ? imageHeight : imageHeight * 0.8;
            
            _imageView.size = CGSizeMake(imageWith, imageHeight);
            _imageView.centerX = self.width / 2;
            _imageView.centerY = self.height *0.4;
            
        }
        
        CGFloat top = _imageView.bottom + kDisOne;
        
        if (title) {
            self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, top, theWidth, 15) title:title font:14 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE];
            [self addSubview:_titleLabel];
            top = _titleLabel.bottom + kDisTwo;
        }
        
        if (!self.activityIndicationVeiw) {
            self.activityIndicationVeiw = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        }
        CGPoint center = self.titleLabel.center;
        center.y += 20;
        self.activityIndicationVeiw.color = [UIColor grayColor];
        [self addSubview:self.activityIndicationVeiw];
        self.activityIndicationVeiw.center = center;
        
        if (content) {
            
            self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, top, theWidth, 15) title:content font:12 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
            [self addSubview:_contentLabel];
            
            top = _contentLabel.bottom;
        }
        
    }
    
    return self;
    
}



@end
