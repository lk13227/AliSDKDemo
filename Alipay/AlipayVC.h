//
//  AlipayVC.h
//  AliSDKDemo
//
//  Created by 888 on 16/8/10.
//  Copyright © 2016年 lk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlipayVC : UIViewController


+ (instancetype)sharedInstanceTool;

//拉起支付宝
- (void)alipayWithCommodityTitle:(NSString *)commodityTitle
         andCommodityDescription:(NSString *)commodityDescription
              andCommodityPrices:(NSString *)commodityPrices
                       andUserId:(NSString *)userId
                         andVrId:(NSString *)vrId;

//发送订单结果至服务器
- (void)uploadedToTheServerWithResultCode:(NSString *)result_code;

@end
