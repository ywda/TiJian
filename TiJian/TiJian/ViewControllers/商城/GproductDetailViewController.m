//
//  GproductDetailViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/2.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GproductDetailViewController.h"
#import "GproductDetailTableViewCell.h"
#import "GproductDirectoryTableViewCell.h"
#import "GShopCarViewController.h"
#import "ProductCommentModel.h"
#import "GcommentViewController.h"
#import "ConfirmOrderViewController.h"
#import "ProductModel.h"
#import "CouponModel.h"
#import "GoneClassListViewController.h"
#import "GmyFootViewController.h"
#import "GCustomSearchViewController.h"
#import "GUpToolView.h"
#import "GBrandHomeViewController.h"
#import "ChooseHopitalController.h"//选择分院


@interface GproductDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,CAAnimationDelegate>
{
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_productDetail;
    AFHTTPRequestOperation *_request_GetShopCarNum;
    AFHTTPRequestOperation *_request_ProductProjectList;
    AFHTTPRequestOperation *_request_GetProductComment;
    AFHTTPRequestOperation *_request_LookAgain;
    NSDictionary *_shopCarDic;
    UITableView *_tab;//单品详情tableview
    GproductDetailTableViewCell *_tmpCell;
    GproductDirectoryTableViewCell *_tmpCell1;
    GCustomDownOfProductView *_downView;//下方工具栏
    UITableView *_hiddenView;//项目详情tableview
    NSArray *_productProjectListDataArray;//项目列表
    NSArray *_productCommentArray;//商品评论
    NSMutableArray *_LookAgainProductListArray;//看了又看
    
    int _gouwucheNum;//购物车里商品数量
    //动画相关
    CALayer     *layer;
    UIImageView *_imageView;
    UIButton    *_btn;
    UIBezierPath *_path;
    GUpToolView *_upToolView;//顶部工具栏
    UIView *_downToolBlackView;//顶部工具栏出现后的下面透明黑色view
    BOOL _toolShow;
    
    UILabel *_xiangmutLabel;//项目详情的套餐名称
    NSString *_phone;//联系电话
}

@property (nonatomic,retain)NSString *centerId;//update by lcw
@property (nonatomic,retain)NSString *centerName;//update by lcw

@end

@implementation GproductDetailViewController


- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
    _tab.delegate = nil;
    _tab.dataSource = nil;
    _tab = nil;
    [_request removeOperation:_request_GetShopCarNum];
    [_request removeOperation:_request_productDetail];
    [_request removeOperation:_request_ProductProjectList];
    [_request removeOperation:_request_GetProductComment];
    [_request removeOperation:_request_LookAgain];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_UPDATE_TO_CART object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_LOGIN object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    self.rightImage = [UIImage imageNamed:@"dian_three.png"];
    
    self.myTitle = @"产品详情";
    _gouwucheNum = 0;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateShopCarNum) name:NOTIFICATION_UPDATE_TO_CART object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateIsFavorAndShopCarNum) name:NOTIFICATION_LOGIN object:nil];
    
    //代金券购买
    if (self.VoucherId) {
        self.theDownType = TheDownViewType_vourcher;
    }
    
    _phone = @"4006279589";
    //视图创建
    [self creatTabOfProductDetail];
    [self creatHiddenView];
    [self creatUpToolView];
    [self creatDownView];
    
    //网络请求
    [self prepareNetData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 参数设置

/**
 *  跳转至详情页 参数设置
 *
 *  @param productId  产品id
 *  @param centerId   对应分院id
 *  @param centerName 对应分院name
 */
-(void)setDownViewOfYueyu:(NSString *)productId
                 centerId:(NSString *)centerId
               centerName:(NSString *)centerName
{
    self.productId = productId;
    self.theDownType = TheDownViewType_yuyue;
    self.centerId = centerId;
    self.centerName = centerName;
}

#pragma mark - 视图创建

//创建上放工具栏
-(void)creatUpToolView{
    
    NSArray *titles = @[@"足迹",@"分享",@"首页"];
    NSArray *images = @[[UIImage imageNamed:@"uptool_zuji"],
                        [UIImage imageNamed:@"share3"],
                        [UIImage imageNamed:@"homepage_g"]];
     @WeakObj(self);
    _upToolView = [[GUpToolView alloc]initWithTitles:titles images:images toolViewBlock:^(NSInteger index) {
        [Weakself upToolBtnClicked:index];
    }];
    [self.view addSubview:_upToolView];
}


//创建单品详情tableview
-(void)creatTabOfProductDetail{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - HMFitIphoneX_navcBarHeight - HMFitIphoneX_tabBarHeight) style:UITableViewStylePlain];
    _tab.tag = 1000;
    _tab.delegate = self;
    _tab.dataSource = self;
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tab];
}


//创建下方工具栏
-(void)creatDownView{
    
    _downView =  [[GCustomDownOfProductView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - HMFitIphoneX_navcBarHeight - HMFitIphoneX_tabBarHeight, DEVICE_WIDTH, HMFitIphoneX_tabBarHeight) customType:self.theDownType];
    
    __weak typeof (self)bself = self;
    [_downView setDownViewClickedBlock:^(NSInteger theTag) {
        [bself downBtnClickedWithType:bself.theDownType tag:theTag];
    }];
    [self.view addSubview:_downView];

}



-(void)creatHiddenView{
    _hiddenView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_tab.frame), DEVICE_WIDTH, DEVICE_HEIGHT - HMFitIphoneX_navcBarHeight - HMFitIphoneX_tabBarHeight) style:UITableViewStyleGrouped];
    _hiddenView.delegate = self;
    _hiddenView.dataSource = self;
    _hiddenView.backgroundColor = [UIColor whiteColor];
    _hiddenView.tag = 1001;
    [self.view addSubview:_hiddenView];
    
}



#pragma mark - 网络请求
-(void)prepareNetData{
    
    _request = [YJYRequstManager shareInstance];
    
    [self getProductDetail];//单品详情和看了又看
    [self getProductConmment];//产品评论
    [self prepareProductProjectList];//具体项目
    [self getshopcarNum];//购物车数量
    //浏览量加1
    [self productLiulanNum];
    //足迹
    [self addProductFoot];
    
    
}

//添加足迹
-(void)addProductFoot{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSDictionary *dic;
    if ([LoginViewController isLogin]) {
        dic = @{
                @"authcode":[UserInfo getAuthkey],
                @"product_id":self.productId
                };
        
        [_request requestWithMethod:YJYRequstMethodPost api:AddMyProductFoot parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
            
        } failBlock:^(NSDictionary *result) {
            
        }];
    }
    
    
}


//商品浏览+1
-(void)productLiulanNum{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSDictionary *dic;
    if ([LoginViewController isLogin]) {
        dic = @{
                @"product_id":self.productId,
                @"authcode":[UserInfo getAuthkey]
                };
    }else{
        dic = @{
                @"product_id":self.productId,
                };
    }
    
    [_request requestWithMethod:YJYRequstMethodGet api:StoreProductLiulanNumAdd parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}



//套餐项目列表
-(void)prepareProductProjectList{
    NSDictionary *dic = @{
                          @"product_id":self.productId
                          };
    
    _request_ProductProjectList = [_request requestWithMethod:YJYRequstMethodGet api:StoreProdectProjectList parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        _productProjectListDataArray = [result arrayValueForKey:@"data"];
        [_hiddenView reloadData];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
    
    
}


//套餐详情和看了又看
-(void)getProductDetail{
    
    NSDictionary *parameters;
    
    if ([LoginViewController isLogin]) {
        parameters = @{
                       @"product_id":self.productId,
                       @"authcode":[UserInfo getAuthkey]
                       };
    }else{
        parameters = @{
                       @"product_id":self.productId
                       };
    }
    
    __weak typeof (self)bself = self;
    
    _request_productDetail = [_request requestWithMethod:YJYRequstMethodGet api:StoreProductDetail parameters:parameters constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSDictionary *dic = [result dictionaryValueForKey:@"data"];
        
        self.theProductModel = [[ProductModel alloc]initWithDictionary:dic];
        
        if (_xiangmutLabel){
            _xiangmutLabel.text = self.theProductModel.setmeal_name;
        }
        
        if (self.VoucherId) {
            if (self.user_voucher) {
                self.theProductModel.isLimitUserInfo = YES;
            }
        }
        
        if ([self.theProductModel.is_favor intValue] == 1) {//已收藏
            _downView.shoucang_btn.selected = YES;
        }else{
            _downView.shoucang_btn.selected = NO;
        }
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in self.theProductModel.coupon_list) {
            CouponModel *model = [[CouponModel alloc]initWithDictionary:dic];
            [arr addObject:model];
        }
        
        self.theProductModel.coupon_list = (NSArray*)arr;
        
        [_tab reloadData];
        
        [bself prepareLookAgainNetData];
        
        
    } failBlock:^(NSDictionary *result) {
    }];
}


//看了又看
-(void)prepareLookAgainNetData{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSString *theP_id;
    NSString *theC_id;
    
    if (self.userChooseLocationDic) {
        
        NSString *a_p = [self.userChooseLocationDic stringValueForKey:@"province_id"];
        NSString *a_c = [self.userChooseLocationDic stringValueForKey:@"city_id"];
        if ([LTools isEmpty:a_p] || [LTools isEmpty:a_c]) {
            theP_id = [GMAPI getCurrentProvinceId];
            theC_id = [GMAPI getCurrentCityId];
        }else{
            theP_id = a_p;
            theC_id = a_c;
        }
        
    }else{
        theP_id = [GMAPI getCurrentProvinceId];
        theC_id = [GMAPI getCurrentCityId];
    }
    
    NSDictionary *dic = @{
                          @"brand_id":self.theProductModel.brand_id,
                          @"province_id":theP_id,
                          @"city_id":theC_id,
                          @"page":@"1",
                          @"per_page":@"3"
                          };
    
    
    _request_LookAgain = [_request requestWithMethod:YJYRequstMethodGet api:StoreProductList parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        _LookAgainProductListArray = [NSMutableArray arrayWithCapacity:1];
        NSArray *arr = [result arrayValueForKey:@"data"];
        for (NSDictionary *dic in arr) {
            ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
            [_LookAgainProductListArray addObject:model];
        }
        
        [_tab reloadData];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}



//获取购物车数量
-(void)getshopcarNum{
    
    if ([LoginViewController isLogin]) {
        [self getShopcarNumWithLoginSuccess];
    }else{
        
    }
}

//获取购物车数量
-(void)getShopcarNumWithLoginSuccess{
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey]
                          };
    _request_GetShopCarNum = [_request requestWithMethod:YJYRequstMethodGet api:GET_SHOPPINGCAR_NUM parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _shopCarDic = result;
        _gouwucheNum = [_shopCarDic intValueForKey:@"num"];
        
        if (_downView.shopCarNumLabel) {
            
            int num = [[NSString stringWithFormat:@"%d",[_shopCarDic intValueForKey:@"num"]]intValue];
            NSString *num_str;
            if (num >= 100) {
                num_str = @"99+";
            }else{
                num_str = [NSString stringWithFormat:@"%d",num];
            }
            _downView.shopCarNumLabel.text = num_str;
            [self updateShopCarNumAndFrame];
        }
        
        
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}


//套餐评论
-(void)getProductConmment{
    NSDictionary *dic = @{
                          @"product_id":self.productId,
                          @"page":@"1",
                          @"per_page":@"3"
                          };
    _request_GetProductComment = [_request requestWithMethod:YJYRequstMethodGet api:GET_PRODUCT_COMMENT parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSArray *arr = [result arrayValueForKey:@"list"];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in arr) {
            ProductCommentModel *model = [[ProductCommentModel alloc]initWithDictionary:dic];
            [array addObject:model];
        }
        _productCommentArray = array;
        [_tab reloadData];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
    
}



#pragma mark - 界面数据更新

//更新购物车数量和frame
-(void)updateShopCarNumAndFrame{
    
    if ([_downView.shopCarNumLabel.text intValue] == 0) {
        _downView.shopCarNumLabel.hidden = YES;
    }else{
        _downView.shopCarNumLabel.hidden = NO;
        UIButton *oneBtn = (UIButton*)[_downView viewWithTag:103];
        if (![LTools isEmpty:_downView.shopCarNumLabel.text]) {
            if ([_downView.shopCarNumLabel.text intValue]<10) {
                [_downView.shopCarNumLabel setFrame:CGRectMake(oneBtn.bounds.size.width - 35, 5, 10, 10)];
            }else{
                [_downView.shopCarNumLabel setFrame:CGRectMake(oneBtn.bounds.size.width - 38, 5, 18, 10)];
            }
        }
        
    }
    
    
    
    
}

//登录成功更新购物车数量
-(void)updateShopCarNum{
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey]
                          };
    _request_GetShopCarNum = _request_GetShopCarNum = [_request requestWithMethod:YJYRequstMethodGet api:GET_SHOPPINGCAR_NUM parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _shopCarDic = result;
        
        if (_downView.shopCarNumLabel) {
            
            int num = [[NSString stringWithFormat:@"%d",[_shopCarDic intValueForKey:@"num"]]intValue];
            NSString *num_str;
            if (num >= 100) {
                num_str = @"99+";
            }else{
                num_str = [NSString stringWithFormat:@"%d",num];
            }
            _downView.shopCarNumLabel.text = num_str;
            [self updateShopCarNumAndFrame];
        }
        
        
        
    } failBlock:^(NSDictionary *result) {
    }];
    
}

//登录成功更新商品收藏和购物车数量
-(void)updateIsFavorAndShopCarNum{
    NSDictionary *parameters;
    
    if ([LoginViewController isLogin]) {
        parameters = @{
                       @"product_id":self.productId,
                       @"authcode":[UserInfo getAuthkey]
                       };
    }else{
        parameters = @{
                       @"product_id":self.productId
                       };
    }
    
    _request_productDetail = [_request requestWithMethod:YJYRequstMethodGet api:StoreProductDetail parameters:parameters constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSDictionary *dic = [result dictionaryValueForKey:@"data"];
        
        self.theProductModel = [[ProductModel alloc]initWithDictionary:dic];
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in self.theProductModel.coupon_list) {
            CouponModel *model = [[CouponModel alloc]initWithDictionary:dic];
            [arr addObject:model];
        }
        
        self.theProductModel.coupon_list = (NSArray*)arr;
        
        if ([self.theProductModel.is_favor intValue] == 1) {//已收藏
            _downView.shoucang_btn.selected = YES;
        }else{
            _downView.shoucang_btn.selected = NO;
        }
        
    } failBlock:^(NSDictionary *result) {
    }];
    
    [self updateShopCarNum];
    
}

#pragma mark - 点击相关

-(void)rightButtonTap:(UIButton *)sender{
    
    _toolShow = !_toolShow;
    
    if (_toolShow) {
        
        if (!_downToolBlackView) {
            _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
            _downToolBlackView.backgroundColor = [UIColor blackColor];
            _downToolBlackView.alpha = 0;
            [self.view insertSubview:_downToolBlackView belowSubview:_upToolView];
            [_downToolBlackView addTapGestureTaget:self action:@selector(upToolShou) imageViewTag:0];
        }
        _downToolBlackView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
            _downToolBlackView.alpha = 0.6;
        } completion:^(BOOL finished) {
            
        }];
        
        
    }else{
        if (!_downToolBlackView) {
            _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
            _downToolBlackView.backgroundColor = [UIColor blackColor];
            _downToolBlackView.alpha = 0.6;
            [self.view insertSubview:_downToolBlackView belowSubview:_upToolView];
        }
        _downToolBlackView.hidden = YES;
        
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, -50, DEVICE_WIDTH, 50)];
        }];
    }
    
    
}

-(void)upToolShou{
    
    if (_toolShow) {
        if (!_downToolBlackView) {
            _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
            _downToolBlackView.backgroundColor = [UIColor blackColor];
            _downToolBlackView.alpha = 0.6;
            [self.view addSubview:_downToolBlackView];
        }
        _downToolBlackView.hidden = YES;
        
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, -50, DEVICE_WIDTH, 50)];
        }];
        
        _toolShow = !_toolShow;
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
        } completion:^(BOOL finished) {
            if (!_downToolBlackView) {
                _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
                _downToolBlackView.backgroundColor = [UIColor blackColor];
                _downToolBlackView.alpha = 0.6;
                [self.view addSubview:_downToolBlackView];
                
                [_downToolBlackView addTapGestureTaget:self action:@selector(upToolShou) imageViewTag:0];
            }
            _downToolBlackView.hidden = NO;
        }];
        _toolShow = !_toolShow;
    }
}

//工具栏按钮点击
-(void)upToolBtnClicked:(NSInteger)index{
    if (index == 0) {//足迹
        if ([LoginViewController isLogin]) {
            GmyFootViewController *cc = [[GmyFootViewController alloc]init];
            [self.navigationController pushViewController:cc animated:YES];
        }else{
            [LoginViewController isLogin:self loginBlock:^(BOOL success) {
                if (success) {
                    GmyFootViewController *cc = [[GmyFootViewController alloc]init];
                    [self.navigationController pushViewController:cc animated:YES];
                }
            }];
        }
        
    }else if (index == 1){//搜索 改为 分享
//        GCustomSearchViewController *cc = [[GCustomSearchViewController alloc]init];
//        [self.navigationController pushViewController:cc animated:YES];
        
        NSString *title = [NSString stringWithFormat:@"%@ %@",[LTools isEmpty:self.theProductModel.brand_name]?@"":self.theProductModel.brand_name,[LTools isEmpty:self.theProductModel.setmeal_name]?@"":self.theProductModel.setmeal_name];
        NSString *imageUrl = _theProductModel.cover_pic;
        NSString *content = @"我在海马医生发现了一件不错的体检套餐,赶快来看看吧。";
        NSString *linkUrl = _theProductModel.share_url;
        [[MiddleTools shareInstance]shareFromViewController:self withImageUrl:imageUrl  shareTitle:title shareContent:content linkUrl:linkUrl];
        
    }else if (index == 2){//首页
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - 下方按钮点击
-(void)downBtnClickedWithType:(TheDownViewType)type tag:(NSInteger)theTag{
    
    if (type == TheDownViewType_gouwuche || type == TheDownViewType_vourcher) {
        if (theTag == 100) {//客服
            
            [LoginViewController isLogin:self loginBlock:^(BOOL success) {
                if (success) {//登录成功
                    
                    [self clickToChat];
                    
                }else{
                    
                }
            }];
            
        }else if (theTag == 101){//收藏
            
            if ([LoginViewController isLogin]) {//已登录
                [self shoucangProductWithState:_downView.shoucang_btn.selected];
            }else{
                [LoginViewController isLogin:self loginBlock:^(BOOL success) {
                    if (success) {//登录成功
                        
                    }else{
                        
                    }
                }];
            }
            
            
        }else if (theTag == 102){//预约
            
            if (self.VoucherId) {//企业代金券
                
                if ([LoginManager isLogin:self]) {//已登录
                    ChooseHopitalController *choose = [[ChooseHopitalController alloc]init];
                    [choose appointWithVoucherId:self.VoucherId userInfo:self.user_voucher productModel:self.theProductModel];
                    choose.lastViewController = self;
                    [self.navigationController pushViewController:choose animated:YES];
                }
                
            }else{
                //update by lcw 2期 直接预约
                if ([LoginManager isLogin:self]) {//已登录
                    
                    ChooseHopitalController *choose = [[ChooseHopitalController alloc]init];
                    [choose apppointNoPayWithProductModel:self.theProductModel
                                                   gender:[_theProductModel.gender_id intValue]
                                             noAppointNum:1000 centerId:self.centerId centerName:self.centerName];
                    choose.lastViewController = self;
                    [self.navigationController pushViewController:choose animated:YES];
                }
            }
                        
        }else if (theTag == 103){//购物车
            
            if (self.isShopCarPush) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                if ([LoginViewController isLogin]) {//已登录
                    GShopCarViewController *cc = [[GShopCarViewController alloc]init];
                    [self.navigationController pushViewController:cc animated:YES];
                }else{
                    [LoginViewController isLogin:self loginBlock:^(BOOL success) {
                        if (success) {
                            GShopCarViewController *cc = [[GShopCarViewController alloc]init];
                            [self.navigationController pushViewController:cc animated:YES];
                        }else{
                            
                        }
                    }];
                }
            }
            
        }else if (theTag == 104){//加入购物车
            
            [LoginViewController isLogin:self loginBlock:^(BOOL success) {
                if (success) {
                    //代金券过来 直接去确认订单
                    if (self.VoucherId) {
                        
                        [self pushToConfirmOrder];
                        
                    }else
                    {
                        [self addProductToShopCar];
                    }
                }
            }];
        }
    }else if (type == TheDownViewType_yuyue){
        
        if (theTag == 100) {//联系客服
            [LoginViewController isLogin:self loginBlock:^(BOOL success) {
                if (success) {//登录成功
                    
                    [self clickToChat];
                    
                }else{
                    
                }
            }];
        }else if (theTag == 101){//电话咨询
            [self clickToPhone];
        }else if (theTag == 102){//收藏
            if ([LoginViewController isLogin]) {//已登录
                [self shoucangProductWithState:_downView.shoucang_btn.selected];
            }else{
                [LoginViewController isLogin:self loginBlock:^(BOOL success) {
                    if (success) {//登录成功
                        
                    }else{
                        
                    }
                }];
            }
        }else if (theTag == 104){//立即预约
            if ([LoginManager isLogin:self]) {//已登录
                ChooseHopitalController *choose = [[ChooseHopitalController alloc]init];
                [choose apppointNoPayWithProductModel:self.theProductModel
                                               gender:[_theProductModel.gender_id intValue]
                                         noAppointNum:1000 centerId:self.centerId centerName:self.centerName];
                choose.lastViewController = self;
                [self.navigationController pushViewController:choose animated:YES];
            }
        }
    }
}

/**
 *  拨打电话
 *
 *  @param sender
 */
- (void)clickToPhone
{
    NSString *msg = [NSString stringWithFormat:@"拨打:%@",_phone];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        NSString *phone = _phone;
        
        if (phone) {
            
            NSString *phoneNum = phone;
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]]];
        }
    }
}


//添加商品到购物车
-(void)addProductToShopCar{
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          @"product_id":self.productId,
                          @"product_num":@"1"
                          };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof (self)bself = self;
    [_request requestWithMethod:YJYRequstMethodPost api:ORDER_ADD_TO_CART parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        _gouwucheNum += 1;
        
        [bself startShopCarAnimation];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}



//立即购买
- (void)pushToConfirmOrder
{
    ConfirmOrderViewController *cc = [[ConfirmOrderViewController alloc]init];
    cc.lastViewController = self;
    cc.voucherId = self.VoucherId;
    cc.user_voucher = self.user_voucher;
    self.theProductModel.product_num = @"1";
    self.theProductModel.current_price = _theProductModel.setmeal_price;
    self.theProductModel.product_name = _theProductModel.setmeal_name;
    cc.dataArray = [NSArray arrayWithObject:self.theProductModel];
    [self.navigationController pushViewController:cc animated:YES];
}


//收藏 取消收藏商品
-(void)shoucangProductWithState:(BOOL)type{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic safeSetValue:self.theProductModel.product_id forKey:@"product_id"];
    [dic safeSetValue:[UserInfo getAuthkey] forKey:@"authcode"];
    
    NSString *api;
    if (type) {//已收藏
        api = QUXIAOSHOUCANG;
    }else{
        api = SHOUCANGRODUCT;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [_request requestWithMethod:YJYRequstMethodGet api:api parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (type) {//已收藏变未收藏
            _downView.shoucang_btn.selected = NO;
        }else{
            _downView.shoucang_btn.selected = YES;
        }
        
        [GMAPI showAutoHiddenMBProgressWithText:[result stringValueForKey:@"msg"] addToView:self.view];
        
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}


#pragma mark - 界面跳转相关
//跳转评论界面
-(void)goToCommentVc{
    GcommentViewController *cc = [[GcommentViewController alloc]init];
    cc.productId = self.productId;
    [self.navigationController pushViewController:cc animated:YES];
}

//跳转单品详情页
-(void)goToProductDetailVcWithId:(NSString *)productId{
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    cc.productId = productId;
    cc.userChooseLocationDic = self.userChooseLocationDic;
    [self.navigationController pushViewController:cc animated:YES];
}

//跳转品牌店
-(void)goToBrandStoreHomeVc{
    
    if (![LTools isEmpty:self.theProductModel.brand_id]) {
        GBrandHomeViewController *cc = [[GBrandHomeViewController alloc]init];
        cc.brand_name = self.theProductModel.brand_name;
        cc.brand_id = self.theProductModel.brand_id;
        [self.navigationController pushViewController:cc animated:YES];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (scrollView.tag == 1000) {
        // 下拉到最底部时显示更多数据
        
        if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height + 30)))
        {
            [self moveToUp:YES];
        }
    }else if (scrollView.tag == 1001){
        if (scrollView.contentOffset.y < -30) {
            [self moveToUp:NO];
        }
    }
    
    
}


- (void)moveToUp:(BOOL)up
{
    NSLog(@"%s",__FUNCTION__);
    if (up) {
        [UIView animateWithDuration:0.3 animations:^{
            _tab.top = -500;
            _hiddenView.top = 0;
            self.myTitle = @"体检项目";
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _tab.top = 0;
            _hiddenView.top = CGRectGetMaxY(_tab.frame);
            self.myTitle = @"产品详情";
        }];
    }
}


#pragma mark - UITableViewDelegate && UITableViewDataSource
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 1000) {//单品详情
        static NSString *identifier = @"identifier";
        GproductDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[GproductDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.delegate = self;
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        [cell loadCustomViewWithIndex:indexPath productCommentArray:_productCommentArray lookAgainArray:_LookAgainProductListArray];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (tableView.tag == 1001){//项目详情
        static NSString *identi = @"identi";
        GproductDirectoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identi];
        if (!cell) {
            cell = [[GproductDirectoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi];
        }
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        
        NSArray *arr = _productProjectListDataArray[indexPath.section];
        NSDictionary *dic = arr[indexPath.row];
        
        [cell loadCustomViewWithData:dic indexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    
    
    
    return [[UITableViewCell alloc]init];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    NSInteger num = 1;
    
    if (tableView.tag == 1000) {
        //6个section
        //0     logo图 套餐名 描述 价钱
        //1     优惠券
        //2     主要参数
        //3     评价
        //4     看了又看
        //5     上拉显示体检项目详情
        num = 6;
    }else if (tableView.tag == 1001){
        num = 1;
    }
    
    return num;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    
    if (tableView.tag == 1000) {
        if (section == 0) {
            num = 1;
        }else if (section == 1){
            num = 1;
        }else if (section == 2){
            num = 1;
        }else if (section == 3){
            num = 2;
        }else if (section == 4){
            num = 1;
        }else if (section == 5){
            num = 1;
        }
    }else if (tableView.tag == 1001){
        NSArray *arr = _productProjectListDataArray[section];
        num = arr.count;
        
    }
    
    
    
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger height = 0;
    
    
    if (tableView.tag == 1000) {
        if (!_tmpCell) {
            _tmpCell = [[GproductDetailTableViewCell alloc]init];
            _tmpCell.delegate = self;
        }
        for (UIView *view in _tmpCell.contentView.subviews) {
            [view removeFromSuperview];
        }
        height = [_tmpCell loadCustomViewWithIndex:indexPath productCommentArray:_productCommentArray lookAgainArray:_LookAgainProductListArray];
    }else if (tableView.tag == 1001){
        if (!_tmpCell1) {
            _tmpCell1 = [[GproductDirectoryTableViewCell alloc]init];
        }
        for (UIView *view in _tmpCell1.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        NSArray *arr = _productProjectListDataArray[indexPath.section];
        NSDictionary *dic = arr[indexPath.row];
        
        height = [_tmpCell1 loadCustomViewWithData:dic indexPath:indexPath];
        
    }
    
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 0.01;
    
    if (tableView.tag == 1000) {
        
    }else if (tableView.tag == 1001){
        if (section == 0) {
            height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/220];
        }else{
            height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/60];
        }
        
        
    }
    
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat height = 0.01;
    
    if (tableView.tag == 1000) {
        
    }else if (tableView.tag == 1001){
        height = 44;
    }
    
    return height;
}


-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    if (tableView.tag == 1000) {
        
    }else if (tableView.tag == 1001){
        [view setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
//        view.backgroundColor = [UIColor orangeColor];
        UILabel *tishiLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH-20, 44)];
        tishiLabel.textAlignment = NSTextAlignmentCenter;
        tishiLabel.numberOfLines = 2;
        if (DEVICE_WIDTH>320) {
            tishiLabel.font = [UIFont boldSystemFontOfSize:11];
        }else{
            tishiLabel.font = [UIFont boldSystemFontOfSize:10];
        }
        
        tishiLabel.textColor = DEFAULT_TEXTCOLOR;
        tishiLabel.text = @"注：因各地区科室和设备设置不同，体检项目会略有不同，请悉知!";
        [view addSubview:tishiLabel];
    }
    return view;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    if (tableView.tag == 1000) {
        
    }else if (tableView.tag == 1001){
        if (section == 0) {
            [view setFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/220])];
            
            UIButton *tishiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [tishiBtn setFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/60])];
            tishiBtn.backgroundColor = [UIColor whiteColor];
            tishiBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            [tishiBtn setTitleColor:RGBCOLOR(26, 27, 28) forState:UIControlStateNormal];
            [tishiBtn setImage:[UIImage imageNamed:@"jiantou_down"] forState:UIControlStateNormal];
            [tishiBtn setTitle:@"下拉显示套餐详情" forState:UIControlStateNormal];
            [tishiBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            [view addSubview:tishiBtn];
            
            UIView *titleView =[[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tishiBtn.frame),DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/100])];
            titleView.backgroundColor = [UIColor whiteColor];
            [view addSubview:titleView];
            
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, [GMAPI scaleWithHeight:titleView.frame.size.height width:0 theWHscale:145.0/100], titleView.frame.size.height)];
            [imv setImage:[UIImage imageNamed:@"tijianxiangmu1.png"]];
            [titleView addSubview:imv];
            
            _xiangmutLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame)+10, 0, titleView.frame.size.width - 10 - imv.frame.size.width - 5 - 5, titleView.frame.size.height)];
            _xiangmutLabel.font = [UIFont systemFontOfSize:15];
            _xiangmutLabel.textColor = [UIColor blackColor];
            _xiangmutLabel.numberOfLines = 2.f;
            _xiangmutLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            _xiangmutLabel.text = self.theProductModel.setmeal_name;
            [titleView addSubview:_xiangmutLabel];
            
            UIView *blueView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(titleView.frame), DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/60])];
            blueView.backgroundColor = RGBCOLOR(222, 245, 255);
            [view addSubview:blueView];
            
            UILabel *xuhaoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, blueView.frame.size.width*1/7, blueView.frame.size.height)];
            xuhaoLabel.text = @"序号";
            xuhaoLabel.font = [UIFont systemFontOfSize:12];
            xuhaoLabel.textAlignment = NSTextAlignmentCenter;
            [blueView addSubview:xuhaoLabel];
            
            UILabel *mingxiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(xuhaoLabel.frame), 0, blueView.frame.size.width*2/7, xuhaoLabel.frame.size.height)];
            mingxiLabel.text = @"明细";
            mingxiLabel.font = [UIFont systemFontOfSize:12];
            mingxiLabel.textAlignment = NSTextAlignmentCenter;
            [blueView addSubview:mingxiLabel];
            
            
            UILabel *zuheneirongLbel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(mingxiLabel.frame), 0, blueView.frame.size.width*4/7, blueView.frame.size.height)];
            zuheneirongLbel.text = @"组合内容";
            zuheneirongLbel.font = [UIFont systemFontOfSize:12];
            zuheneirongLbel.textAlignment = NSTextAlignmentCenter;
            [blueView addSubview:zuheneirongLbel];
            
            
            
        }else{
            
        }
    }
    
    
    
    return view;
}



#pragma mark - 动画相关
//加入购物车动画效果
-(void)startShopCarAnimation{
    
    
    if (!_path) {
        _path = [UIBezierPath bezierPath];
        [_path moveToPoint:CGPointMake(DEVICE_WIDTH-_downView.addShopCarBtn.frame.size.width*0.25, DEVICE_HEIGHT - _downView.addShopCarBtn.frame.size.height - HMFitIphoneX_navcBarHeight)];//开始点
        [_path addQuadCurveToPoint:CGPointMake(DEVICE_WIDTH - _downView.addShopCarBtn.frame.size.width - _downView.shoucang_btn.frame.size.width*0.5, DEVICE_HEIGHT - HMFitIphoneX_navcBarHeight - _downView.shoucang_btn.frame.size.height*0.5) controlPoint:CGPointMake(DEVICE_WIDTH - _downView.addShopCarBtn.frame.size.width, DEVICE_HEIGHT - 300)];//结束点
    }
    
    
    if (!layer) {
        _btn.enabled = NO;
        layer = [CALayer layer];
        
        layer.contents = (__bridge id)[UIImage imageNamed:@"TabCartSelected.png"].CGImage;
        if (self.gouwucheProductImage) {
            layer.contents = (__bridge id)self.gouwucheProductImage.CGImage;
        }
        layer.contentsGravity = kCAGravityResizeAspectFill;
        layer.bounds = CGRectMake(0, 0, 20, 15);
        //        [layer setCornerRadius:CGRectGetHeight([layer bounds]) / 2];
        layer.masksToBounds = YES;
        layer.position =CGPointMake(50, 150);
        [self.view.layer addSublayer:layer];
    }
    [self groupAnimation];
    
}

-(void)groupAnimation{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = _path.CGPath;
    animation.rotationMode = kCAAnimationRotateAuto;
    CABasicAnimation *expandAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    expandAnimation.duration = 0.3f;
    expandAnimation.fromValue = [NSNumber numberWithFloat:1];
    expandAnimation.toValue = [NSNumber numberWithFloat:2.0f];
    expandAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *narrowAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    narrowAnimation.beginTime = 0.3;
    narrowAnimation.fromValue = [NSNumber numberWithFloat:2.0f];
    narrowAnimation.duration = 0.3f;
    narrowAnimation.toValue = [NSNumber numberWithFloat:0.5f];
    
    narrowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *groups = [CAAnimationGroup animation];
    groups.animations = @[animation,expandAnimation,narrowAnimation];
    groups.duration = 0.6f;
    groups.removedOnCompletion=NO;
    groups.fillMode=kCAFillModeForwards;
    groups.delegate = self;
    [layer addAnimation:groups forKey:@"group"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [layer animationForKey:@"group"]) {
        _btn.enabled = YES;
        [layer removeFromSuperlayer];
        layer = nil;
        
        CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        shakeAnimation.duration = 0.25f;
        shakeAnimation.fromValue = [NSNumber numberWithFloat:-5];
        shakeAnimation.toValue = [NSNumber numberWithFloat:5];
        shakeAnimation.autoreverses = YES;
        [_downView.gouwucheOneBtn.layer addAnimation:shakeAnimation forKey:nil];
        
        
        [self updateShopCarNumAndFrame];
        
    }
}


#pragma mark - 客服相关
/**
 *  开启客服
 */
- (void)clickToChat
{
    [MiddleTools pushToChatWithSourceType:SourceType_ProductDetail fromViewController:self model:_theProductModel];
}

@end
