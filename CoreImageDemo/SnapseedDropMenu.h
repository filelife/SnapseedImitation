//
//  SnapseedDropMenu.h
//  CoreImageDemo
//
//  Created by Gejiaxin on 16/12/28.
//  Copyright © 2016年 VincentJac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Extention.h"
@class SnapseedDropMenu;

@protocol SnapseedDropMenuDelegate<NSObject>

- (void)snapseedDropMenu:(SnapseedDropMenu*)sender didSelectCellAtIndex:(NSInteger)index value:(CGFloat)value;
- (void)snapseedDropMenu:(SnapseedDropMenu*)sender atIndex:(NSInteger)index valueDidChange:(CGFloat)value;
@end


@interface SnapseedDropMenu : UITableView
@property (nonatomic, weak) id<SnapseedDropMenuDelegate> dropMenuDelegate;
- (instancetype)initWithArray:(NSArray *)array viewCenterPoint:(CGPoint)origin inView:(UIView *)superView;
@end
