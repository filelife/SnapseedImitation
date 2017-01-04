//
//  UIView(Extention).m
//  CoreImageDemo
//
//  Created by Gejiaxin on 16/12/28.
//  Copyright © 2016  VincentJac. All rights reserved.
//

#import "UIView+Extention.h"

@implementation UIView (Extention)



- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)screenX {
    CGFloat x = 0.0f;
    for (UIView *view = self; view; view = view.superview) {
        x += view.left;
    }
    return x;
}

- (CGFloat)screenY {
    CGFloat y = 0.0f;
    for (UIView *view = self; view; view = view.superview) {
        y += view.top;
    }
    return y;
}

- (CGFloat)screenViewX {
    CGFloat x = 0.0f;
    for (UIView *view = self; view; view = view.superview) {
        x += view.left;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            x -= scrollView.contentOffset.x;
        }
    }
    
    return x;
}

- (CGFloat)screenViewY {
    CGFloat y = 0;
    for (UIView *view = self; view; view = view.superview) {
        y += view.top;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}



- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)orientationWidth {
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
    ? self.height : self.width;
}

- (CGFloat)orientationHeight {
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
    ? self.width : self.height;
}

- (CGPoint)offsetFromView:(UIView*)otherView {
    CGFloat x = 0.0f, y = 0.0f;
    for (UIView *view = self; view && view != otherView; view = view.superview) {
        x += view.left;
        y += view.top;
    }
    return CGPointMake(x, y);
}



- (CGRect)screenFrame {
    NSLog(@"~~~~FrameW = %f",self.width);
    NSLog(@"~~~~screenFrameW = %f",self.screenSize.width);
    return CGRectMake(self.screenViewX, self.screenViewY, self.screenSize.width, self.screenSize.height);
}


- (CGSize)screenSize
{
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    int w = screenFrame.size.width, h = screenFrame.size.height;
    UIDeviceOrientation deviceOri = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation statusOri = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIDeviceOrientationIsLandscape(deviceOri)) {
        w = screenFrame.size.height;
        h = screenFrame.size.width;
    } else if (!UIDeviceOrientationIsPortrait(deviceOri)) {
        if (UIDeviceOrientationIsLandscape(statusOri)) {
            w = screenFrame.size.height;
            h = screenFrame.size.width;
        }
    }
    CGSize size = CGSizeMake(w, h);
    return size;
}

-(void)setScreenSize:(CGSize)screenSize
{
    CGRect frame = self.frame;
    frame.size = screenSize;
    self.frame = frame;
}




- (CGFloat)x
{
    return self.left;
}

- (void)setX:(CGFloat)value
{
    self.left = value;
}

- (CGFloat)y
{
    return self.top;
}

- (void)setY:(CGFloat)value
{
    self.top = value;
}

- (CGFloat)w
{
    return self.width;
}

- (void)setW:(CGFloat)width
{
    self.width = width;
}

- (CGFloat)h
{
    return self.height;
}

- (void)setH:(CGFloat)height
{
    self.height = height;
}

- (void)removeAllSubviews {
    while (self.subviews.count) {
        UIView *child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}


@end
