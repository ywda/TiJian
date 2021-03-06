//
//  QueryReportController.m
//  TiJian
//
//  Created by lichaowei on 16/5/16.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "QueryReportController.h"
#import "LPickerView.h"
#define Cache_brandName @"cache_brandname" //缓存品牌名
#define Cache_brandId @"cache_brandid" //缓存品牌id
#define Cache_account @"cache_account" //缓存账号
#define Cache_account_password @"cache_account_password" //缓存账号对应密码
#define Cache_brandId_newest @"cache_brandid_newest" //缓存品牌id最近的一个

@interface QueryReportController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    LPickerView *_pickerView;
    NSArray *_itemsArray;
    NSString *_brandId;//选择的品牌id
    NSString *_brandName;//选择的品牌
    BOOL _isEdited;//是否编辑过
}

@property(nonatomic,retain)MBProgressHUD *loading;

@end

@implementation QueryReportController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"查找报告";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    [self.view addTapGestureTaget:self action:@selector(hiddenKeyboard) imageViewTag:0];
    
    [self netWorkForBrandList];//请求品牌列表
    
    NSArray *items = @[@"品牌",@"账号",@"密码"];
    NSArray *placeHolders = @[@"请选择体检品牌",@"请输入体检中心提供的账号",@"请输入体检中心提供的密码"];
    CGFloat top = 0.f;
    for (int i = 0; i < items.count; i ++) {
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(23, 30 + (50 + 20) * i, DEVICE_WIDTH - 23 * 2, 50)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bgView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 50) font:15 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE title:items[i]];
        titleLabel.tag = 1000 + i;
        [bgView addSubview:titleLabel];
        
        UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(titleLabel.right, 2, bgView.width - titleLabel.width, bgView.height - 2)];
        tf.delegate = self;
        tf.font = [UIFont systemFontOfSize:14];
        [bgView addSubview:tf];
        tf.placeholder = placeHolders[i];
        tf.tag = 100 + i;
        if (i == 2) {
            tf.secureTextEntry = YES;
        }
        //品牌
        if (i == 0) {
            
            NSString *brandName = [self getBrandNameWithBrandId:[self getNewestBrandId]];
            NSString *brandId = [self getNewestBrandId];
            if (![LTools isEmpty:brandName] &&
                ![LTools isEmpty:brandId]) {
                tf.text = brandName;
                _brandId = brandId;
                _brandName = brandName;
            }
        }
        //账号
        if (i == 1) {
            tf.returnKeyType = UIReturnKeyNext;
            tf.clearButtonMode = UITextFieldViewModeWhileEditing;
//            NSString *account = [self getAccountWithBrandId:[self getNewestBrandId]];
//            if (![LTools isEmpty:account]) {
//                tf.text = account;
//            }
        }
        //密码
        else if (i == 2)
        {
            tf.returnKeyType = UIReturnKeyDone;
            tf.clearButtonMode = UITextFieldViewModeWhileEditing;
            
//            NSString *accountPassword = [self getAccountPasswordWithBrandId:[self getNewestBrandId]];
//            if (![LTools isEmpty:accountPassword]) {
//                tf.text = accountPassword;
//            }
        }
        
        top = bgView.bottom;
    }
    
    //提交信息按钮
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.backgroundColor = DEFAULT_TEXTCOLOR;
    loginBtn.frame = CGRectMake((DEVICE_WIDTH - 200)/2.f, top + 60, 200, 40);
    [self.view addSubview:loginBtn];
    [loginBtn setTitle:@"提交信息" forState:UIControlStateNormal];
    [loginBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [loginBtn addTarget:self action:@selector(clickToSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn addCornerRadius:5.f];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(loginBtn.left, loginBtn.bottom + 13, loginBtn.width, 14) font:13 align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR title:@"不清楚账号、密码？"];
    [label addTaget:self action:@selector(clickToConfused:) tag:0];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

-(MBProgressHUD *)loading
{
    if (!_loading) {
        _loading = [LTools MBProgressWithText:@"努力加载中..." addToView:self.view];
    }
    [self.view addSubview:_loading];
    return _loading;
}

#pragma mark - 数据处理

//---------- get

//最新的brandid
- (NSString *)getNewestBrandId
{
    return [LTools objectForKey:Cache_brandId_newest];
}

- (NSString *)getBrandNameWithBrandId:(NSString *)brandId
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",Cache_brandName,brandId];
    NSString *brandName = [LTools objectForKey:key];
    return brandName;
}

- (NSString *)getAccountWithBrandId:(NSString *)brandId
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",Cache_account,brandId];
    NSString *account = [LTools objectForKey:key];
    return account;
}

- (NSString *)getAccountPasswordWithBrandId:(NSString *)brandId
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",Cache_account_password,brandId];
    NSString *account = [LTools objectForKey:key];
    return account;
}

//---------- set

- (void)setBrandName:(NSString *)brandName
         withBrandId:(NSString *)brandId
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",Cache_brandName,brandId];
    [LTools setObject:brandName forKey:key];
}

- (void)setAccount:(NSString *)account
       withBrandId:(NSString *)brandId
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",Cache_account,brandId];
    [LTools setObject:account forKey:key];
}

- (void)setAccountPassword:(NSString *)accountPassword
       withBrandId:(NSString *)brandId
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",Cache_account_password,brandId];
    [LTools setObject:accountPassword forKey:key];
}

#pragma mark - 网络请求

- (void)netWorkForBrandList
{
    NSString *api = Report_center;
    
     @WeakObj(self);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        NSArray *list = result[@"list"];
        [Weakself updateBrandList:list];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [_pickerView loadFailWithMsg:@""];

    }];
}

/**
 *  更新品牌列表
 *
 *  @param list
 */
- (void)updateBrandList:(NSArray *)list
{
    _itemsArray = [NSArray arrayWithArray:list];
    if (_pickerView) {
        [_pickerView reloadAllComponents];
        
        //设置显示位置
        NSString *selectBrandId = [self getNewestBrandId];
        if (![LTools isEmpty:selectBrandId]) {
            
            if (_itemsArray.count > 0) {
                
                for (int i = 0; i < _itemsArray.count; i ++) {
                    int brandid = [_itemsArray[i][@"brand_id"] intValue];
                    if ([selectBrandId intValue] == brandid) {
                        [_pickerView selectrow:i component:0 animated:NO];
                    }
                }
            }
        }
    }
}

/**
 *  查询报告
 *
 *  @param brandId   品牌id
 *  @param accountNo 账号
 *  @param password  密码
 */
-(void)queryReportWithBrandId:(NSString *)brandId
                    accountNo:(NSString *)accountNo
                     password:(NSString *)password{
    
    //本地缓存
    [LTools setObject:brandId forKey:Cache_brandId_newest];
    [self setAccount:accountNo withBrandId:brandId];
    [self setAccountPassword:password withBrandId:brandId];//保存密码
    [self setBrandName:_brandName withBrandId:brandId];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetString:[UserInfo getAuthkey] forKey:@"authcode"];
    [params safeSetString:brandId forKey:@"brand_id"];
    [params safeSetString:accountNo forKey:@"account_no"];
    [params safeSetString:password forKey:@"password"];
    [params safeSetString:@"2" forKey:@"type"];// 2 表示输入账号密码查询（上传）

     @WeakObj(self);
    [self.loading show:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:REPORT_ADD parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [_loading hide:YES];
        
        if ([result[RESULT_CODE] intValue] == 0) {
            NSString *url = result[@"url"];
            [MiddleTools pushToWebFromViewController:Weakself weburl:url title:@"体检报告" moreInfo:NO hiddenBottom:NO];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_REPORT_ADD_SUCCESS object:nil];//通知更新报告列表
        
    } failBlock:^(NSDictionary *result) {
        [_loading hide:YES];
//        int errocode = [result[RESULT_CODE]intValue];
        DDLOG(@"result %@ %@",result[RESULT_CODE],result[RESULT_INFO]);

    }];
}

- (UITextField *)textFieldWithTag:(int)tag
{
    return [self.view viewWithTag:tag];
}

#pragma mark - 年龄选择器

- (void)selectBrand
{
    if (!_pickerView) {
        
         @WeakObj(self);
        _pickerView = [[LPickerView alloc]initWithDelegate:self delegate:self pickerBlock:^(ACTIONTYPE type, int row, int component) {
            if (type == ACTIONTYPE_SURE) {
                [Weakself selectBrandWithRow:row];
            }else if (type == ACTIONTYPE_Refresh)
            {
                [Weakself netWorkForBrandList];
            }
        }];
    }
    
    if (_itemsArray.count > 0) {
        [self updateBrandList:_itemsArray];
    }
    [_pickerView pickerViewShow:YES];
}

- (void)selectBrandWithRow:(int)row
{
    NSString *title = _itemsArray[row][@"brand_name"];
    [self textFieldWithTag:100].text = title;
    _brandId = _itemsArray[row][@"brand_id"];//选中的品牌id
    _brandName = title;
    
    //被编辑过了,新编辑的内容优先级最高
    if (_isEdited) {
        return;
    }
    
//    //缓存数据
//    NSString *account = [self getAccountWithBrandId:_brandId];
//    if (![LTools isEmpty:account]) {
//        
//        [self textFieldWithTag:101].text = account;
//
//    }else
//    {
//        [self textFieldWithTag:101].text = nil;
//    }
//    
//    NSString *account_password = [self getAccountPasswordWithBrandId:_brandId];
//    if (![LTools isEmpty:account_password]) {
//        
//        [self textFieldWithTag:102].text = account_password;
//        
//    }else
//    {
//        [self textFieldWithTag:102].text = nil;
//    }
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return _itemsArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)componen{
    
    return [NSString stringWithFormat:@"%d",(int)row + 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSLog(@"选择品牌：%d",(int)row + 1);
    if (row + 1 == 4) {//姓名 手机号
        UILabel *label_name = [self.view viewWithTag:1001];
        label_name.text = @"姓名";
        UITextField *tf_name = [self textFieldWithTag:101];
        tf_name.placeholder = @"请输入姓名";
        
        UILabel *label_idCard = [self.view viewWithTag:1002];
        label_idCard.text = @"身份证";
        UITextField *tf_idCard = [self textFieldWithTag:102];
        tf_idCard.placeholder = @"请输入身份证号";
        tf_idCard.secureTextEntry = NO;
        
    }else{
        UILabel *label_name = [self.view viewWithTag:1001];
        label_name.text = @"账号";
        UITextField *tf_name = [self textFieldWithTag:101];
        tf_name.placeholder = @"请输入体检中心提供的账号";
        
        UILabel *label_phone = [self.view viewWithTag:1002];
        label_phone.text = @"密码";
        UITextField *tf_phone = [self textFieldWithTag:102];
        tf_phone.placeholder = @"请输入体检中心提供的密码";
        tf_phone.secureTextEntry = YES;
    }
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 45.f;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view __TVOS_PROHIBITED
{
    UIView *pickerCell = view;
    if (!pickerCell) {
        pickerCell = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, [UIScreen mainScreen].bounds.size.width, 45.0f}];
        UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(50, 10, 25, 25)];
        icon.backgroundColor = [UIColor orangeColor];
        [pickerCell addSubview:icon];
        icon.tag = 100;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(icon.right + 10, 10, 200, 25) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@""];
        [pickerCell addSubview:label];
        label.tag = 101;
    }
    
    UIImageView *icon = [pickerCell viewWithTag:100];
    UILabel *label = [pickerCell viewWithTag:101];
    NSString *iconUrl = _itemsArray[row][@"brand_logo"];
    NSString *title = _itemsArray[row][@"brand_name"];
    [icon l_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:DEFAULT_HEADIMAGE];
    label.text = title;
    
    return pickerCell;
}

#pragma mark - 事件处理

- (void)clickToSubmit:(UIButton *)sender
{
    [self hiddenKeyboard];
    
    NSString *brandName = [self textFieldWithTag:100].text;//品牌名
    NSString *account = [self textFieldWithTag:101].text;//账号
    NSString *password = [self textFieldWithTag:102].text;//密码
    
    if ([LTools isEmpty:brandName]) {
        
        [LTools showMBProgressWithText:@"请选择体检品牌" addToView:self.view];
        return;
    }
    
    if ([LTools isEmpty:account]) {
        
        [LTools showMBProgressWithText:@"请输入有效的体检账号" addToView:self.view];
        return;
    }
    
    if ([LTools isEmpty:password]) {
        
        [LTools showMBProgressWithText:@"请输入有效的密码" addToView:self.view];
        return;
    }
    
    [self queryReportWithBrandId:_brandId accountNo:account password:password];
}

/**
 *  不清楚账号、密码
 *
 *  @param sender
 */
- (void)clickToConfused:(UIButton *)sender
{
    NSString *urlstring = [NSString stringWithFormat:@"%@%@",SERVER_URL,URL_ReportAccount];
    [MiddleTools pushToWebFromViewController:self weburl:urlstring title:@"体检账号说明" moreInfo:NO hiddenBottom:NO];
}

- (void)hiddenKeyboard
{
    for (int i = 0; i < 3; i ++) {
        
        UITextField *tf = [self.view viewWithTag:100 + i];
        if ([tf isFirstResponder]) {
            [tf resignFirstResponder];
        }
    }
}

#pragma mark - UITextFieldDelegate <NSObject>

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //性别选择
    if (textField.tag == 100) {

    for (int i = 0; i < 3; i ++) {

        UITextField *tf = [self.view viewWithTag:100 + i];
        if ([tf isFirstResponder]) {
            [tf resignFirstResponder];
        }
    }
        [self selectBrand];
        if (_itemsArray.count == 0) {
            [self netWorkForBrandList];
        }
        
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 101) {
        [[self textFieldWithTag:102] becomeFirstResponder];
    }else if (textField.tag == 102)
    {
        [textField resignFirstResponder];
        [self clickToSubmit:nil];//提交
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string   // return NO to not change text
{
    //账号
    if (textField.tag == 101) {
        
        _isEdited = YES;//被编辑过,权限高
    }
    return YES;
}


@end
