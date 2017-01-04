//
//  UIView(Extention).h
//  CoreImageDemo
//
//  Created by Gejiaxin on 16/12/28.
//  Copyright © 2016  VincentJac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extention)
/**
 *    top = frame.origin.y
 */
@property (nonatomic, assign) CGFloat top;

/**
 *    left = frame.origin.x
 */
@property (nonatomic, assign) CGFloat left;

/**
 *    bottom = frame.origin.y + frame.size.height
 */
@property (nonatomic, assign) CGFloat bottom;

/**
 *    right = frame.origin.x + frame.size.width
 */
@property (nonatomic, assign) CGFloat right;

/**
 *    width = frame.size.width
 */
@property (nonatomic, assign) CGFloat width;

/**
 *    height = frame.size.height
 */
@property (nonatomic, assign) CGFloat height;

/**
 *    centerX = center.x
 */
@property (nonatomic, assign) CGFloat centerX;

/**
 *    centerY = center.y
 */
@property (nonatomic, assign) CGFloat centerY;

/**
 *    当前实例在屏幕上的x坐标
 */
@property (nonatomic, readonly) CGFloat screenX;

/**
 *    当前实例在屏幕上的y坐标
 */
@property (nonatomic, readonly) CGFloat screenY;

/**
 *    当前实例在屏幕上的x坐标（scroll view适用）
 */
@property (nonatomic, readonly) CGFloat screenViewX;

/**
 *    当前实例在屏幕上的y坐标（scroll view适用）
 */
@property (nonatomic, readonly) CGFloat screenViewY;

/**
 *    当前实例在屏幕上的位置大小
 */
@property (nonatomic, readonly) CGRect screenFrame;

/**
 *    origin = frame.origin
 */
@property (nonatomic) CGPoint origin;

/**
 *    size = frame.size
 */
@property (nonatomic) CGSize size;

/**
 *    返回实例在竖屏下的宽或横屏下的高
 */
@property (nonatomic, readonly) CGFloat orientationWidth;

/**
 *    返回实例在竖屏下的高或横屏下的宽
 */
@property (nonatomic, readonly) CGFloat orientationHeight;

/**
 *    返回实例相对于otherView的位置，otherView指某一层的superview
 */
- (CGPoint)offsetFromView:(UIView*)otherView;


/**
 *    返回screenSize
 */
@property (nonatomic) CGSize screenSize;

/**
 *  移除VIEW上所有的子VIEW
 */
- (void)removeAllSubviews;

@property (assign, nonatomic) CGFloat	x;
@property (assign, nonatomic) CGFloat	y;
@property (assign, nonatomic) CGFloat	w;
@property (assign, nonatomic) CGFloat	h;
@end
