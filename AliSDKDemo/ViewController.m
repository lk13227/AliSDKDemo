//
//  ViewController.m
//  AliSDKDemo
//
//  Created by 888 on 16/8/10.
//  Copyright © 2016年 lk. All rights reserved.
//

#import "ViewController.h"

#import "AlipayVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[AlipayVC sharedInstanceTool] alipayWithCommodityTitle:@"测试商品名称" andCommodityDescription:@"测试商品描述" andCommodityPrices:@"0.01" andUserId:@"1" andVrId:@"1"];
}

@end
