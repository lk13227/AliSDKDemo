//
//  AlipayVC.m
//  AliSDKDemo
//
//  Created by 888 on 16/8/10.
//  Copyright © 2016年 lk. All rights reserved.
//

#import "AlipayVC.h"

#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "AFNetworking.h"

@interface AlipayVC ()

/** 订单号返回值 */
@property (nonatomic,copy) NSString * outTradeNO;
/** 订单号返回值的sessionid */
@property (nonatomic,copy) NSString * sessionid;

@end

@implementation AlipayVC

/************************* 单例 **********************************/

static id _instance;
//重写allocWithZone:方法，在这里创建唯一的实例(注意线程安全)
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    }
    return _instance;
}

+ (instancetype)sharedInstanceTool{
    @synchronized(self){
        if(_instance == nil){
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

-(id)copyWithZone:(struct _NSZone *)zone{
    return _instance;
}

/************************* 单例 **********************************/

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - 支付方法
- (void)alipayWithCommodityTitle:(NSString *)commodityTitle
         andCommodityDescription:(NSString *)commodityDescription
              andCommodityPrices:(NSString *)commodityPrices
                   andOutTradeNO:(NSString *)outTradeNO
{
    
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"";
    NSString *seller = @"";
    NSString *privateKey = @"";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                            message:@"缺少partner或者seller或者私钥。"
                                            preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
//        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                        message:@"缺少partner或者seller或者私钥。"
//                                                       delegate:self
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil];
//        [alert1 show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.sellerID = seller;
    order.outTradeNO = outTradeNO; //订单ID（由商家自行制定）
    order.subject = commodityTitle; //商品标题
    order.body = commodityDescription; //商品描述
    order.totalFee = commodityPrices; //商品价格 .2
    order.notifyURL =  @"http://kdbwg.ez360.cn"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showURL = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"alisdkdemo";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            /*
             reslut = {
             memo = "";
             result = "partner=\"2088911899518234\"&seller_id=\"yiyouwuxian@ez360.cn\"&out_trade_no=\"XJMX29NJVMGQNKO\"&subject=\"\U6d4b\U8bd5\"&body=\"\U8fd9\U53ea\U662f\U6d4b\U8bd5\"&total_fee=\"0.01\"&notify_url=\"http://www.xxx.com\"&service=\"mobile.securitypay.pay\"&payment_type=\"1\"&_input_charset=\"utf-8\"&it_b_pay=\"30m\"&show_url=\"m.alipay.com\"&success=\"true\"&sign_type=\"RSA\"&sign=\"oZrtVOW5SUGCqakRfrAnbpxXdbN9WvH2WZo8amDiOPTAc8BZMDrFGzuQsuGHyKX/w5vw8/yivlPUri/8r6m37bd4JOfUJA+NeX9PW2okmAIr6UMr7x2cO72IxLazHRxCO2eFiX1do7/hOTDTXcOJmS65yGJ4rZneDbJ5pUpx4CQ=\"";
             resultStatus = 9000;
             }
             */
            //支付结果
            NSLog(@"reslut = %@",resultDic);
            //支付结果传到服务器
            NSString *resultStatus = [resultDic objectForKey:@"resultStatus"];
            [self uploadedToTheServerWithResultCode:resultStatus];
        }];
    }
}


#pragma mark   ==============产生订单号==============
- (void)alipayWithCommodityTitle:(NSString *)commodityTitle
         andCommodityDescription:(NSString *)commodityDescription
              andCommodityPrices:(NSString *)commodityPrices
                       andUserId:(NSString *)userId
                         andVrId:(NSString *)vrId
{
    self.outTradeNO = nil;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"userId"] = userId;
    parameters[@"price"] = commodityPrices;
    parameters[@"vrId"] = vrId;
    
    [manager POST:@"http://kdbwg.ez360.cn/KDBWG_SERVER/client/user/userPayment" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"订单请求成功---%@",responseObject);
        
        self.outTradeNO = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"data"] objectForKey:@"order_number"]];
        self.sessionid = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"data"] objectForKey:@"sessionid"]];
        
        if (self.outTradeNO.length > 0 && self.outTradeNO != nil) {
            [self alipayWithCommodityTitle:commodityTitle andCommodityDescription:commodityDescription andCommodityPrices:commodityPrices andOutTradeNO:self.outTradeNO];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"订单请求失败");
    }];
    
}


#pragma mark - 得到订单结果发送到服务器
- (void)uploadedToTheServerWithResultCode:(NSString *)result_code
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"sessionid"] = self.sessionid;
    parameters[@"result_code"] = result_code;
    
    [manager POST:@"http://kdbwg.ez360.cn/KDBWG_SERVER/client/user/confirmUserPayment" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"订单结果发送成功---%@",responseObject);
        
        //UnitySendMessage("GoumaiUI", "PayResult", result.UTF8String);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"订单结果发送失败");
    }];
}


@end
