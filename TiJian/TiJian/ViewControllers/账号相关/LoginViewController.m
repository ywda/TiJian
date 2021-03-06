//
//  LoginViewController.m
//  OneTheBike
//
//  Created by lichaowei on 14/10/26.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "LoginViewController.h"
#import "GRegisterViewController.h"
#import "ForgetPwdController.h"
#import "UserInfo.h"
//#import "WXApi.h"
#import "LTools.h"
//#import "APService.h"//JPush推送
#import "JPUSHService.h" //JPush推送

@interface LoginViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

+ (LoginViewController *)shareInstance
{
    static dispatch_once_t once_t;
    static LoginViewController *login;
    dispatch_once(&once_t, ^{
       
        login = [[LoginViewController alloc]init];
    });
    return login;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([UIApplication sharedApplication].isStatusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    
    [self setNavigationStyle:NAVIGATIONSTYLE_BLUE title:@"登录"];

    //微信未安装或者不支持
//    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
//        
//        self.thirdLoginView2.hidden = NO;
//        self.thirdLoginView.hidden = YES;
//    }else
//    {
//        self.thirdLoginView.hidden = NO;
//        self.thirdLoginView2.hidden = YES;
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        
    self.myTitle = @"登录";    

    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    self.view.backgroundColor = [UIColor colorWithHexString:@"6da0cf"];
    
    NSMutableAttributedString *aaa = [[NSMutableAttributedString alloc]initWithString:@"没有账户？去注册"];
    
    [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(105, 106, 107) range:NSMakeRange(0,5)];
    [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0,5)];
    [aaa addAttribute:NSForegroundColorAttributeName value:DEFAULT_TEXTCOLOR range:NSMakeRange(5, 3)];
    [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(5, 3)];
    [aaa addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(5, 3)];
    
    [self.registerBtn addTarget:self action:@selector(clickToRegiter) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *phoneText = @"请输入手机号";
    NSMutableAttributedString *phone = [[NSMutableAttributedString alloc]initWithString:phoneText];
    [phone addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, phoneText.length)];
    [self.phoneTF setAttributedPlaceholder:phone];
    
    NSString *passText = @"请输入密码";
    NSMutableAttributedString *password = [[NSMutableAttributedString alloc]initWithString:passText];
    [password addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, passText.length)];
    [self.pwdTF setAttributedPlaceholder:password];
    
    //默认不可点击
    self.loginButton.userInteractionEnabled = NO;
    self.loginButton.alpha = 0.5f;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
}

#pragma mark - 通知处理

- (void)textFieldChange:(NSNotification *)notify
{
    NSString *notifyName = notify.name;
    if ([notifyName isEqualToString:UITextFieldTextDidChangeNotification]) {
        
        UITextField *textField = notify.object;
        
        NSString *phone = self.phoneTF.text;
        
        if (textField == self.phoneTF) {
            
            phone = [LTools stringByRemoveUnavailableWithPhone:phone];
            textField.text = phone;
        }
        
        NSString *pwd = self.pwdTF.text;
        
        if (phone &&
            [LTools isValidateMobile:phone] &&
            pwd.length) {
            
            self.loginButton.userInteractionEnabled = YES;
            self.loginButton.alpha = 1.f;
        }else
        {
            self.loginButton.userInteractionEnabled = NO;
            self.loginButton.alpha = 0.5f;
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (BOOL)isLogin
{
    NSString *authey = [UserInfo getAuthkey];
    
    if (authey && authey.length > 0) {
        
        return YES;
    }
    return NO;
}

+ (BOOL)isLogin:(UIViewController *)viewController
{
    return [self isLogin:viewController loginBlock:nil];
}

+ (BOOL)isLogin:(UIViewController *)viewController loginBlock:(LoginBlock)aBlock
{
    if (![self isLogin]) {

        LoginViewController *login = [LoginViewController shareInstance];

        [login setLoginBlock:aBlock];//登录block
        
        //如果已经登录直接进行下一步操作
        if (aBlock) {
            aBlock(NO);//登录成功
            aBlock = nil;
        }

        LNavigationController *unVc = [[LNavigationController alloc]initWithRootViewController:login];

        [viewController presentViewController:unVc animated:YES completion:nil];

        return NO;
    }
    
    //如果已经登录直接进行下一步操作
    if (aBlock) {
        aBlock(YES);//登录成功
        aBlock = nil;
    }
    return YES;
}

#pragma mark - 免密登录

/**
 *  免密登录
 *
 *  @param sender
 */
- (IBAction)clickToLoginWithoutPassword:(id)sender {
    
    ForgetPwdController *forget = [[ForgetPwdController alloc]init];
    forget.forgetType = ForgetType_loginWithoutPwd;
    
    @WeakObj(self);
    [forget setUpdateParamsBlock:^(NSDictionary *params) {
        
        BOOL isLogin = [params[@"isLogin"]boolValue];//是否是登录
        if (isLogin) {
            [Weakself loginWithoutPwdWithParmas:params];
        }
    }];
    [self.navigationController pushViewController:forget animated:YES];
}

/**
 *  免密登录
 *
 *  @param params
 */
- (void)loginWithoutPwdWithParmas:(NSDictionary *)params
{
    NSString *mobile = params[@"mobile"];
    NSString *securityCode = params[@"code"];//验证码
    
    [self loginType:Login_withoutPwd thirdId:nil nickName:nil thirdphoto:nil gender:Gender_Boy password:securityCode mobile:mobile];
}

/**
 *  登录成功
 *
 *  @param newerCoupon 是否领取新人优惠劵
 */
- (void)actionForLoginWithResult:(NSDictionary *)result
{
    //判断是否领取了新人优惠劵
    int newer_coupon = [result[@"newer_coupon"]intValue];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGIN object:nil];

    [self loginResultIsSuccess:YES];
    
    if (newer_coupon == 1) { //领取了新人优惠劵
        
        NSString *title = result[RESULT_INFO];
        NSString *msg = @"恭喜您获得新人优惠劵,已放入您的钱包";
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
    }else
    {
        [LTools showMBProgressWithText:@"登录成功" addToView:[UIApplication sharedApplication].keyWindow];
        [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.3];
    }
}

#pragma mark - 事件处理

- (void)loginResultIsSuccess:(BOOL)isSuccess
{
    if (_aLoginBlock) {
        _aLoginBlock(isSuccess);
    }
}

- (void)setLoginBlock:(LoginBlock)aBlock
{
    _aLoginBlock = aBlock;
}


/**
 *  忘记密码
 */
- (IBAction)clickToForgetPwd:(id)sender {
    
    ForgetPwdController *forget = [[ForgetPwdController alloc]init];
    [self.navigationController pushViewController:forget animated:YES];
}

/**
 *  注册
 */
-(void)clickToRegiter{
    GRegisterViewController *regis = [[GRegisterViewController alloc]init];
    [self.navigationController pushViewController:regis animated:YES];
    
    __weak typeof(self)weakSelf = self;
    
    regis.registerBlock = ^(NSString *phoneNum,NSString *password){
        
        weakSelf.phoneTF.text = phoneNum;
        weakSelf.pwdTF.text = password;
        
        [weakSelf clickToNormalLogin:nil];
    } ;
}

/**
 *  正常登录
 */
- (IBAction)clickToNormalLogin:(id)sender {
    
    [self tapToHiddenKeyboard:nil];
    
    if (![LTools isValidateMobile:self.phoneTF.text]) {
        
        [LTools alertText:ALERT_ERRO_PHONE viewController:self];
        return;
    }
    
    if (![LTools isValidatePwd:self.pwdTF.text]) {
        
        [LTools alertText:ALERT_ERRO_PASSWORD viewController:self];
        return;
    }
    
    
    [self loginType:Login_Normal thirdId:nil nickName:nil thirdphoto:nil gender:Gender_Girl password:self.pwdTF.text mobile:self.phoneTF.text];
    
}

-(void)leftButtonTap:(UIButton *)sender
{
    if (self.isSpecial) {
        
        [self.navigationController.view removeFromSuperview];
        [self.navigationController removeFromParentViewController];
        
        return;
    }
    
    [self loginResultIsSuccess:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)clickToSina:(id)sender {
    
//    [self loginToPlat:UMShareToSina];
}

- (IBAction)clickToQQ:(id)sender {
    
//    [self loginToPlat:UMShareToQQ];
}

- (IBAction)tapToHiddenKeyboard:(id)sender {
    
    [self.phoneTF resignFirstResponder];
    [self.pwdTF resignFirstResponder];
}

- (IBAction)clickToWeiXin:(id)sender {
    //微信
    NSLog(@"微信");
//    [self loginToPlat:UMShareToWechatSession];
}


#pragma mark - 授权登录

//- (void)loginToPlat:(NSString *)snsPlatName
//{
//    //此处调用授权的方法,你可以把下面的platformName 替换成 UMShareToSina,UMShareToTencent等
//    
//    __weak typeof(self)weakSelf = self;
//    
//    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsPlatName];
//    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
//        
//        NSLog(@"login response is %@",response);
//        
//        //获取微博用户名、uid、token等
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:snsPlatName];
//            NSLog(@"username is %@, uid is %@, token is %@",snsAccount.userName,snsAccount.usid,[UMSocialAccountManager socialAccountDictionary]);
//            
//            Login_Type type;
//            if ([snsPlatName isEqualToString:UMShareToSina]) {
//                type = Login_Sweibo;
//            }else if ([snsPlatName isEqualToString:UMShareToQQ]) {
//                type = Login_QQ;
//            }else if ([snsPlatName isEqualToString:UMShareToWechatSession]) {
//                type = Login_Weixin;
//            }
//
//            NSLog(@"name %@ photo %@",snsAccount.userName,snsAccount.iconURL);
//            [weakSelf loginType:type thirdId:snsAccount.usid nickName:snsAccount.userName thirdphoto:snsAccount.iconURL gender:Gender_Girl password:nil mobile:nil];
//        }
//        
//    });
//}

#pragma mark - 事件处理

//清空原先数据
- (void)changeUser:(NSNotification *)notification
{
    
}

#pragma mark - 数据解析

#pragma mark - 网络请求

/**
 *  @param type       (登录方式，normal为正常手机登录，s_weibo、qq、weixin分别代表新浪微博、qq、微信登录) string
 *  @param thirdId    (第三方id，若为第三方登录需要该参数)
 *  @param nickName   (第三方昵称，若为第三方登录需要该参数)
 *  @param thirdphoto (第三方头像，若为第三方登录需要该参数)
 *  @param gender     (性别，若第三方登录可填写，也可不填写，1=》男 2=》女 默认为女) int
 */

- (void)loginType:(Login_Type)loginType
          thirdId:(NSString *)thirdId
             nickName:(NSString *)nickName
       thirdphoto:(NSString *)thirdphoto
           gender:(Gender)gender
         password:(NSString *)password
           mobile:(NSString *)mobile
{
    NSString *type;
    NSString *provider = @"";
    switch (loginType) {
        case Login_Normal:
        {
            type = @"normal";
            provider = @"";
        }
            break;
        case Login_withoutPwd: //免密登录
        {
            type = @"mobile";
            provider = @"noPwd";
        }
            break;
        case Login_Sweibo:
        {
            type = @"s_weibo";
            provider = @"WB";
        }
            break;
        case Login_QQ:
        {
            type = @"qq";
            provider = @"QQ";
        }
            break;
        case Login_Weixin:
        {
           type = @"weixin";
            provider = @"WX";
        }
            break;
            
        default:
            break;
    }
    
    __weak typeof(self)weakSelf = self;
    
    NSString *token = [UserInfo getDeviceToken];
    
    if (token.length == 0) {
        token = @"noToken,may close remote push";
    }
    
    NSDictionary *params;
    if ([type isEqualToString:@"normal"]) {
        params = @{
                   @"type":type,
                   @"mobile":mobile,
                   @"password":password,
                   @"devicetoken":token,
                   @"login_source":@"iOS"
                   };
    }else if ([type isEqualToString:@"mobile"])
    {
        params = @{
                   @"type":type,
                   @"mobile":mobile,
                   @"code":password,
                   @"devicetoken":token,
                   @"login_source":@"iOS"
                   };
    }
    else{
        
        thirdId = thirdId ? : @"";
        nickName = nickName ? : @"";
        thirdphoto = thirdphoto ? : @"";
        
        params = @{
                   @"type":type,
                   @"thirdid":thirdId,
                   @"nickname":nickName,
                   @"third_photo":thirdphoto,
                   @"gender":[NSString stringWithFormat:@"%d",gender],
                   @"devicetoken":token,
                   @"login_source":@"iOS"
                   };
    }
    
    NSMutableDictionary *Mut_params = [NSMutableDictionary dictionaryWithDictionary:params];
    
    //JPush registerid
    NSString *registration_id = [JPUSHService registrationID];
    if (registration_id && registration_id.length > 0) {
        
        [Mut_params setObject:registration_id forKey:@"registration_id"];
    }
    
    UIView *rootView = [UIApplication sharedApplication].keyWindow;
    
    [MBProgressHUD showHUDAddedTo:rootView animated:YES];
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_LOGIN_ACTION parameters:Mut_params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:rootView animated:YES];
        
        DDLOG(@"%@",result);
        
        UserInfo *user = [[UserInfo alloc]initWithDictionary:result];
        /**
         *  归档的方式保存userInfo
         */
        [user cacheUserInfo];
        
        //记录authkey
        [LTools setObject:user.authcode forKey:USER_AUTHOD];
        
        //记录没有密码
        [LTools setObject:user.no_password forKey:USER_NoPwd];
        
        //保存登录状态 yes
        [LTools setBool:YES forKey:LOGIN_SERVER_STATE];
        
        //友盟账号统计
        NSString *uid = user.uid;
        [MobClick profileSignInWithPUID:uid provider:provider];
        
        //处理登录结果
        [weakSelf actionForLoginWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:rootView animated:YES];
        NSLog(@"%@",result);
        [weakSelf loginResultIsSuccess:NO];
    }];
    
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *text = textField.text;
    if(textField == self.phoneTF)
    {
        text = [LTools stringByRemoveUnavailableWithPhone:text];
    }
    textField.text = text;
}


@end

/**
 *  主要目的实现loginManager
 */

@implementation LoginManager

@end
