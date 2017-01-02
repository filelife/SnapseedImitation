//
//  PrefixHeader.pch
//  CoreImageDemo
//
//  Created by Gejiaxin on 16/12/28.
//  Copyright © 2016年 VincentJac. All rights reserved.
//

#ifndef PrefixHeader_pch
#define PrefixHeader_pch

//UI用宏定义
#define SnapseedDropMenuCellHeight 45
#define SnapseedDropMenuCellWidth 200
//宏定义表：
#pragma mark - 常用尺寸
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define NAV_VIEW_HEIGHT 44.0f           //顶部导航栏视图的高(baseview)

#pragma mark - 手机型号判断
#define IS_IPHONE4 (([[UIScreen mainScreen] bounds].size.height == 480) ? YES : NO)
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height == 568) ? YES : NO)
#define IS_IPHONE6 (([[UIScreen mainScreen] bounds].size.width == 375) ? YES : NO)
#define IS_IPHONE6P (([[UIScreen mainScreen] bounds].size.width == 414) ? YES : NO)

#pragma mark - 时间
#define CS_DATE_FORMAT_YYYY_MM_DD                                      @"yyyy-MM-dd"
#define CS_DATE_FORMAT_LONG                                            @"yyyy年MM月dd日 E"
#define CS_DATE_FORMAT_YMDHMS                                          @"yyyy-MM-dd HH:mm:ss"

#pragma mark - 系统版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define CurrentSystemVersion ([[UIDevice currentDevice] systemVersion])
#define HEX_RGBA(s,a) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s & 0xFF))/255.0 alpha:a]
#define COLOR_1 HEX_RGBA(0x333333, 1)
#define COLOR_2 HEX_RGBA(0x666666, 1)
#define COLOR_3 HEX_RGBA(0x0090ff, 1)
#define COLOR_4 HEX_RGBA(0x999999, 1)
#define COLOR_5 HEX_RGBA(0xcccccc, 1)
#define COLOR_6 HEX_RGBA(0xff6e00, 1)
#define COLOR_7 HEX_RGBA(0xffffff, 1)
#define COLOR_8 HEX_RGBA(0xdddddd, 1)
#define COLOR_9 HEX_RGBA(0xeeeeee, 1)
#define COLOR_10 HEX_RGBA(0xf5f5f5, 1)
#define COLOR_11 HEX_RGBA(0xebeced, 1)
#define COLOR_12 HEX_RGBA(0x7fedff, 1)
#define COLOR_14 HEX_RGBA(0x38adff, 1)
#define COLOR_16 HEX_RGBA(0xff6f6f, 1)
#define COLOR_19 HEX_RGBA(0xff9518, 1)
#define COLOR_20 HEX_RGBA(0x000000,0.6)
#define BACKGROUNDCOLOR HEX_RGBA(0x000000,0.80)

#endif /* PrefixHeader_pch */
