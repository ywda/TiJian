//
//  RefreshHeaderView.h
//  TiJian
//
//  Created by lichaowei on 15/9/29.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    L_EGOOPullRefreshPulling = 0,
    L_EGOOPullRefreshNormal,
    L_EGOOPullRefreshLoading,
} L_EGOPullRefreshState;

typedef enum{
    EGORefreshHeader = 0,
    EGORefreshFooter
} EGORefreshPos;

@protocol L_EGORefreshTableDelegate<NSObject>

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos;
- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view;

@optional

- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view;

@end

@interface RefreshHeaderView : UIView
{
    L_EGOPullRefreshState _state;
    
    UILabel *_lastUpdatedLabel;
    UILabel *_statusLabel;
    CALayer *_arrowImage;
    UIActivityIndicatorView *_activityView;
}

@property(nonatomic,weak)id<L_EGORefreshTableDelegate>delegate;

- (id)initWithFrame:(CGRect)frame
     arrowImageName:(NSString *)arrow
          textColor:(UIColor *)textColor;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
- (void)setState:(L_EGOPullRefreshState)aState;

@end
