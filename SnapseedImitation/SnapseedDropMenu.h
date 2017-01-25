//
//  SnapseedDropMenu.h
//  CoreImageDemo
//
//  Created by Gejiaxin on 16/12/28.
//  Copyright © 2016 VincentJac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Extention.h"

@interface SnapseedDropMenuModel : NSObject
@property (nonatomic, assign) CGFloat defaultValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, copy) NSString * title;

- (instancetype)initWithTitle:(NSString *)title defaultValue:(CGFloat)defaultValue maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue;
@end

@class SnapseedDropMenu;

@protocol SnapseedDropMenuDelegate<NSObject>

- (void)snapseedDropMenu:(SnapseedDropMenu*)sender didSelectCellAtIndex:(NSInteger)index value:(CGFloat)value;
- (void)snapseedDropMenu:(SnapseedDropMenu*)sender atIndex:(NSInteger)index isChanging:(CGFloat)value;
- (void)snapseedDropMenu:(SnapseedDropMenu*)sender atIndex:(NSInteger)index valueDidChange:(CGFloat)value;
@end


@interface SnapseedDropMenu : UITableView
@property (nonatomic, weak) id<SnapseedDropMenuDelegate> dropMenuDelegate;
@property (nonatomic, assign) NSInteger selectNum;
- (instancetype)initWithArray:(NSArray *)array viewCenterPoint:(CGPoint)origin inView:(UIView *)superView;
@end
