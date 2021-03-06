//
//  LCWTools.h
//  FBAuto
//
//  Created by lichaowei on 14-7-9.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

#import "AppDelegate.h"

#define RESULT_INFO @"msg" //错误信息

#define RESULT_CODE @"errorcode" //错误code

typedef void(^ urlRequestBlock)(NSDictionary *result,NSError *erro);

typedef void(^versionBlock)(BOOL isNewVersion,NSString *updateUrl,NSString *updateContent);//版本更新

@interface LTools : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

+ (id)shareInstance;

+ (AppDelegate *)appDelegate;

+ (UINavigationController *)rootNavigationController;

#pragma mark - 判断是否是企业版本

+ (BOOL)isEnterprise;

/**
 *  获取appName
 *
 *  @return
 */
+ (NSString *)getAppName;

#pragma - mark MD5 加密

/**
 *  获取验证码的时候加此参数
 *
 *  @param phone 手机号
 *
 *  @return 手机号和特定字符串MD5之后的结果
 */
+ (NSString *)md5Phone:(NSString *)phone;

+ (NSString *) md5:(NSString *) text;

#pragma mark - 网络监控

/**
 *  判断网络wifi或者移动网络是否可用
 *
 *  @return YES or NO
 */
+ (BOOL)NetworkReachable;


#pragma mark - 版本更新信息

/**
 *  获取是否有最新版本
 */
- (void)versionForAppid:(NSString *)appid Block:(void(^)(BOOL isNewVersion,NSString *updateUrl,NSString *updateContent))version;//是否有新版本、新版本更新下地址


#pragma mark - NSUserDefault缓存

#pragma mark 缓存融云用户数据

/**
 *  获取融云未读消息num
 *
 *  @return
 */
+ (int)rongCloudUnreadNum;

/**
 *  更新未读消息显示
 *
 *  @param number 未读数
 */
+ (void)updateTabbarUnreadMessageNumber;

+ (void)cacheRongCloudUserName:(NSString *)userName forUserId:(NSString *)userId;
+ (NSString *)rongCloudUserNameWithUid:(NSString *)userId;

+ (void)cacheRongCloudUserIcon:(NSString *)iconUrl forUserId:(NSString *)userId;

+ (NSString *)rongCloudUserIconWithUid:(NSString *)userId;

/**
 *  融云 记录更新数据时间
 *
 *  @param userId 用户id
 */
+ (void)cacheRongCloudTimeForUserId:(NSString *)userId;

/**
 *  是否需要更新userId对应的信息
 *
 *  @param userId
 *
 *  @return 是否
 */
+ (BOOL)rongCloudNeedRefreshUserId:(NSString *)userId;

#pragma - mark NSUserDefaults本地缓存

/**
 *  归档的方式 归档的方式 model必须遵循 NSSecureCoding
 *
 *  @param aModel
 *  @param modelKey
 */
+ (void)cacheModel:(id)aModel forKey:(NSString *)modelKey;

+ (id)cacheModelForKey:(NSString *)modelKey;

+ (void)setObject:(id)object forKey:(NSString *)key;//存
+ (id)objectForKey:(NSString *)key;//取

+ (void)setBool:(BOOL)boo forKey:(NSString *)key;
+ (BOOL)boolForKey:(NSString *)key;

#pragma mark - 常用视图快速创建

/**
 *  通过xib创建cell
 *
 *  @param identify  标识名称
 *  @param tableView
 *  @param cellName
 *
 *  @return cell
 */
+ (UITableViewCell *)cellForIdentify:(NSString *)identify
                            cellName:(NSString *)cellName
                            forTable:(UITableView *)tableView;

#pragma - mark 文字自适应高度、宽度计算

/**
 *  计算宽度
 */
+ (CGFloat)widthForText:(NSString *)text uiFont:(UIFont *)font;
/**
 *  计算宽度
 */
+ (CGFloat)widthForText:(NSString *)text font:(CGFloat)size;

+ (CGFloat)widthForText:(NSString *)text boldFont:(CGFloat)size;

+ (CGFloat)widthForText:(NSString *)text height:(CGFloat)height font:(CGFloat)size;

+ (CGFloat)heightForText:(NSString *)text width:(CGFloat)width font:(CGFloat)size;

+ (CGFloat)heightForText:(NSString *)text width:(CGFloat)width Boldfont:(CGFloat)size;

#pragma mark - 验证有消息

//是否是字典
+ (BOOL)isDictinary:(id)object;

#pragma - mark 判断为空或者是空格

+ (BOOL)isEmpty:(NSString *) str;

#pragma - mark 验证邮箱、电话等有效性

/*匹配正整数*/
+ (BOOL)isValidateInt:(NSString *)digit;

/*匹配整浮点数*/
+ (BOOL)isValidateFloat:(NSString *)digit;

/*邮箱*/
+ (BOOL)isValidateEmail:(NSString *)email;

+ (BOOL)isValidateName:(NSString *)userName;

//数字和字母 和 _
+ (BOOL)isValidatePwd:(NSString *)pwdString;

//验证身份证
+ (BOOL)isValidateIDCard:(NSString *)idCard;


/*手机及固话*/
+ (BOOL)isValidateMobile:(NSString *)mobileNum;

#pragma - mark 小工具

/**
 *  根据6的屏幕计算比例宽度
 *
 *  @param aWidth 6上的宽
 *
 *  @return 等比例的宽
 */
+ (CGFloat)fitWidth:(CGFloat)aWidth;

/**
 *  根据宽度等比例适配高度
 *
 *  @param x 6的高度
 *
 *  @return
 */
+ (CGFloat)fitWithIPhone6:(CGFloat)x;

/**
 *  根据6的屏幕计算比例高度
 *
 *  @param aWidth 6上的高
 *
 *  @return 等比例的高
 */
+ (CGFloat)fitHeight:(CGFloat)aHeight;

/**
 *  根据6的宽度等比例适配size
 */
+ (CGSize)fitWidthForSize:(CGSize)size;

/**
 *  根据6的高度等比例适配size
 */
+ (CGSize)fitHeightForSize:(CGSize)size;

/**
 *  根据color id获取优惠劵背景图
 *
 *  @param color color 的id
 *
 *  @return image
 */
+ (UIImage *)imageForCoupeColorId:(NSString *)color;

/**
 *  返回距离 大于1000 为km,小于m
 *
 *  @param distance 距离
 *
 *  @return
 */
+ (NSString *)distanceString:(NSString *)distance;

#pragma - mark 时间相关

/**
 *  时间戳转化为格式时间
 *
 *  @param placetime 时间线
 *  @param format    时间格式 @"yyyy-MM-dd HH:mm:ss"
 *
 *  @return 返回时间字符串
 */
+(NSString *)timeString:(NSString *)placetime
             withFormat:(NSString *)format;

/**
 *  NSDate转指定格式string
 *
 *  @param date   日期
 *  @param format 格式
 *
 *  @return
 */
+(NSString *)timeDate:(NSDate *)date
           withFormat:(NSString *)format;

/**
 *  获取当前时间戳
 */
+(NSString *)timechangeToDateline;

/**
 *  NSDate对应的时间戳
 *  @return
 */
+(NSString *)timeDatelineWithDate:(NSDate *)date;

/**
 *  时间转化为对应的时间戳
 *
 *  @param string 时间
 *  @param format 格式
 *
 *  @return
 */
+(NSString *)timeDatelineWithString:(NSString *)string
                             format:(NSString *)format;

/**
 *  显示间隔时间 一天内显示时分、几天前、几周前、大于一周 显示具体日期
 *
 *  @param myTime 时间线
 *  @param format 时间格式 “HH:mm”
 *
 *  @return
 */
+ (NSString*)showIntervalTimeWithTimestamp:(NSString*)myTime
                                withFormat:(NSString *)format;


+(NSString*)timestamp:(NSString*)myTime;


+ (NSString *)currentTime;

/**
 *  字符串格式转换NSDate
 *
 *  @param string 2016-05-13
 *  @param format @"yyyy-MM-dd"
 *
 *  @return
 */
+ (NSDate *)dateFromString:(NSString *)string
                withFormat:(NSString *)format;


/**
 *  是否需要更新
 *
 *  @param hours      时间间隔
 *  @param recordDate 上次记录时间
 *
 *  @return 是否需要更新
 */
+ (BOOL)needUpdateForHours:(CGFloat)hours
                recordDate:(NSDate *)recordDate;


#pragma - mark UIAlertView快捷方式

+ (void)alertText:(NSString *)text viewController:(UIViewController *)vc;


//alert 提示

+ (void)alertText:(NSString *)text;

#pragma - mark MBProgressHUD快捷方式

+ (void)showMBProgressWithText:(NSString *)text addToView:(UIView *)aView;

+ (MBProgressHUD *)MBProgressWithText:(NSString *)text addToView:(UIView *)aView;

#pragma - mark 身份证安全性处理
/**
 *  处理身份证号
 *
 *  @param idCard 身份证号
 *
 *  @return
 */
+ (NSString *)safeStringWithIdCard:(NSString *)idCard;

#pragma - mark 非空字符串

/**
 *  NSNumber按照设置格式输出
 *
 *  @param number
 *  @param style  NSNumberFormatterRoundCeiling = kCFNumberFormatterRoundCeiling,//四舍五入，原值2.7999999999,直接输出3
 
 * NSNumberFormatterRoundFloor = kCFNumberFormatterRoundFloor,//保留小数输出2.8 正是想要的
 
 * NSNumberFormatterRoundDown = kCFNumberFormatterRoundDown,//加上了人民币标志，原值输出￥2.8
 
 * NSNumberFormatterRoundUp = kCFNumberFormatterRoundUp,//本身数值乘以100后用百分号表示,输出280%
 
 * NSNumberFormatterRoundHalfEven = kCFNumberFormatterRoundHalfEven,//原值表示，输出2.799999999E0
 
 * NSNumberFormatterRoundHalfDown = kCFNumberFormatterRoundHalfDown,//原值的中文表示，输出二点七九九九。。。。
 
 * NSNumberFormatterRoundHalfUp = kCFNumberFormatterRoundHalfUp //原值中文表示，输出第三
 *
 *  @return
 */

+(NSString *)numberToString:(long)number
                numberStyle:(NSNumberFormatterStyle)style;

/**
 *  排除NSNull null 和 (null)
 *
 *  @param text
 *
 *  @return 空格
 */
+ (NSString *)NSStringNotNull:(NSString *)text;

/**
 *  判断是否为null、NSNull活着nil
 *
 *  @return
 */
+ (BOOL)NSStringIsNull:(NSString *)text;


/**
 *  去除开头的空格
 */
+ (NSString *)stringHeadNoSpace:(NSString *)string;

/**
 *  给字符串加逗号
 *
 *  @param string 源字符串 如： 123456.78 或者 123456
 *
 *  @return 逗号分割字符串  1,234,567.89 或者 123,456
 */

+ (NSString *)NSStringAddComma:(NSString *)string;//添加逗号


/**
 *  行间距string
 */

+ (NSAttributedString *)attributedString:(NSString *)string
                            lineSpaceing:(CGFloat)lineSpage;

/**
 *  行间距string 字体大小
 */

+ (NSAttributedString *)attributedString:(NSString *)string
                            lineSpaceing:(CGFloat)lineSpage
                                fontSize:(CGFloat)fontSize;

/**
 *  行间距string 字体大小 字体颜色
 */

+ (NSAttributedString *)attributedString:(NSString *)string
                            lineSpaceing:(CGFloat)lineSpage
                                fontSize:(CGFloat)fontSize
                               textColor:(UIColor *)textColor;


/**
 *  关键词特殊显示
 *
 *  @param content   源字符串
 *  @param aKeyword  关键词
 *  @param textColor 关键词颜色
 */
+ (NSAttributedString *)attributedString:(NSString *)content
                                 keyword:(NSString *)aKeyword
                                   color:(UIColor *)textColor;

/**
 *  关键词特殊显示
 *
 *  @param content   源字符串
 *  @param aKeyword  关键词
 *  @param textColor 关键词颜色
 *  @param keywordFontSize 关键字大小
 */
+ (NSAttributedString *)attributedString:(NSString *)content
                                 keyword:(NSString *)aKeyword
                                   color:(UIColor *)textColor
                         keywordFontSize:(CGFloat)keywordFontSize;
/**
 *  每次只给一个关键词加高亮颜色
 *
 *  @param attibutedString 可以为空
 *  @param string          attibutedString 为空时,用此进行初始化;并且用于找到关键词的range
 *  @param keyword         需要高亮的部分
 *  @param color           高亮的颜色
 *
 *  @return NSAttributedString
 */
+ (NSAttributedString *)attributedString:(NSMutableAttributedString *)attibutedString
                          originalString:(NSString *)string
                              AddKeyword:(NSString *)keyword
                                   color:(UIColor *)color;

/**
 *  给关键字设置颜色、下划线、字体大小
 *
 *  @param content          目标string
 *  @param underlineKeyword 关键词
 *  @param textColor        颜色
 *  @param keywordFontSize  字体大小
 *
 *  @return
 */
+ (NSAttributedString *)attributedString:(NSString *)content
                        underlineKeyword:(NSString *)underlineKeyword
                                   color:(UIColor *)textColor
                         keywordFontSize:(CGFloat)keywordFontSize;

#pragma - mark 获取JSONString
/**
 *  object转化为JSON字符串
 *
 *  @param object
 *
 *  @return
 */
+ (NSString *)JSONStringWithObject:(id)object;

/**
 *  解析jsonString to NSDictionary
 *
 *  @param JSONString
 *
 *  @return
 */
+(NSDictionary *)parseJSONStringToNSDictionary:(NSString *)JSONString;

#pragma - mark 图片处理相关

#pragma mark 切图

+(UIImage *)scaleToSizeWithImage:(UIImage *)img size:(CGSize)size;

//根据url获取SDWebImage 缓存的图片

+ (UIImage *)sd_imageForUrl:(NSString *)url;

//通过图片Data数据第一个字节 来获取图片扩展名
//图片数第一个字节是固定的,代表图片的类型
- (NSString *)contentTypeForImageData:(NSData *)data;

#pragma - mark 图片比例计算

/**
 *  计算等比例高度
 *
 *  @param image_height   图片的高度
 *  @param image_width    图片的宽度
 *  @param show_Width     实际显示宽度
 *
 *  @return 实际显示高度
 */
+ (CGFloat)heightForImageHeight:(CGFloat)image_height
                     imageWidth:(CGFloat)image_width
                      showWidth:(CGFloat)show_Width;

#pragma mark - 动画

/**
 *  view先变大再恢复原样
 *
 *  @param annimationView 需要做动画的view
 *  @param duration       动画时间
 *  @param scacle         变大比例
 */
+ (void)animationToBigger:(UIView *)annimationView
                 duration:(CGFloat)duration
                   scacle:(CGFloat)scacle;

#pragma mark - 身份证信息处理

/**
 *  根据身份证号获取性别,18位(17位代表性别)15位(15位代表性别)奇数为男,偶数为女。
 *
 *  @param numberStr
 *
 *  @return Gender
 */
+ (Gender)getIdCardSex:(NSString *)numberStr;

/**
 *  根据省份证号获取年龄
 *
 *  @param numberStr
 *
 *  @return
 */
+(NSString *)getIdCardAge:(NSString *)numberStr;

/**
 *  根据身份证号获取生日(18位身份证 7-14为出生日期)
 *
 *  @param numberStr
 *
 *  @return
 */
+ (NSString *)getIdCardbirthday:(NSString *)numberStr;

/**
 *  身份证号移除不必要字符0-9 x X
 *
 *  @param idCard
 */
+ (NSString *)stringByRemoveUnavailableWithIdCard:(NSString *)idCard;

/**
 *  手机号移除不必要字符 0-9
 *
 *  @param idCard
 */
+ (NSString *)stringByRemoveUnavailableWithPhone:(NSString *)phone;

/**
 *  获取num位随机字符串
 *
 *  @param num 位数
 *
 *  @return
 */
+ (NSString *)randomNum:(int)num;

@end
