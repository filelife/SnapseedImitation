//
//  SnapseedDropMenu.m
//  CoreImageDemo
//
//  Created by Gejiaxin on 16/12/28.
//  Copyright © 2016年 VincentJac. All rights reserved.
//

#import "SnapseedDropMenu.h"
#import "SnapseedDropMenuTableViewCell.h"
#import <math.h>
typedef NS_ENUM(NSInteger, PanGestureDirection) {
    NoGestureDirection = 0,
    LeftOrRight = 1,
    UpOrDown,
    PanGestureUp,
    PanGestureDown,
    PanGestureleft,
    PanGestureRight
};
#define MoveZoom 5
@interface SnapseedDropMenu()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, copy)NSArray * dataArray;
@property (nonatomic, strong) NSMutableArray * valueArray;
@property (nonatomic, assign) NSInteger selectNum;
@property (nonatomic, strong) UIView * superView;
@property (nonatomic, assign) PanGestureDirection lastGestureDirecttion;
@property (nonatomic, assign) PanGestureDirection gestureLock;
@property (nonatomic, assign) NSInteger originY;
@property (nonatomic, assign) NSInteger curValue;
@end
@implementation SnapseedDropMenu
- (instancetype)initWithArray:(NSArray *)array viewCenterPoint:(CGPoint)origin inView:(UIView *)superView{
    self = [super initWithFrame:CGRectMake(0, 0, SnapseedDropMenuCellWidth, SnapseedDropMenuCellHeight * array.count)];
    _dataArray = array;
    self.centerX = origin.x;
    self.centerY = origin.y;
    self.originY = origin.y - (self.height / 2);
    self.dataSource = self;
    self.delegate = self;
    self.rowHeight = SnapseedDropMenuCellHeight;
    self.backgroundColor = [UIColor clearColor];
    self.scrollEnabled = NO;
    self.hidden = YES;
    _superView = superView;
    _selectNum = 0;
    [self reloadData];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [_superView addGestureRecognizer:panGesture];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.valueArray = [NSMutableArray array];
    for(int i = 0; i < _dataArray.count; i++) {
        NSNumber * num = @0;
        [self.valueArray addObject:num];
    }
    
    return self;
}


- (void) selectCellByOffsetY{
    CGFloat distant = self.y - self.originY;
    NSInteger selectNum = 0;
    if(distant >= 0) {
        selectNum = distant / SnapseedDropMenuCellHeight;
    } else {
        selectNum = (-distant) / SnapseedDropMenuCellHeight ;
    }
    _selectNum = selectNum;
    
    [self reloadData];
}

#pragma mark - UITableview



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * title = [_dataArray objectAtIndex:indexPath.row];
    SnapseedDropMenuTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SnapseedDrowMenuCell"];
    if(!cell) {
        cell = [[SnapseedDropMenuTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SnapseedDrowMenuCell"];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.title.text = title;
    cell.valueLab.text = @"0";
    if(indexPath.row == _selectNum) {
        cell.mainView.backgroundColor = COLOR_14;
    } else {
        cell.mainView.backgroundColor = COLOR_20;
    }
    return cell;
}

- (void)panGesture:(id)sender {
    
    UIPanGestureRecognizer *panGesture = sender;
    
    if(!_superView) {
        return ;
    }
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateEnded: {
            if(self.dropMenuDelegate && _gestureLock == UpOrDown) {
                if([self.dropMenuDelegate respondsToSelector:@selector(snapseedDropMenu:didSelectCellAtIndex:value:)]) {
                    NSNumber * value = [self.valueArray objectAtIndex:(NSUInteger)_selectNum];
                    [self.dropMenuDelegate snapseedDropMenu:self didSelectCellAtIndex:_selectNum value:value.floatValue];
                }
            }
            self.hidden = YES;
            _gestureLock = NoGestureDirection;
        }
            break;
        case UIGestureRecognizerStateBegan: {
            
        }
            break;
        case UIGestureRecognizerStateChanged : {
            if(_gestureLock == UpOrDown) {
                self.hidden = NO;
            }
        }
        default:
            break;
    }
    //每次仅获取较短的位移距离
    CGPoint movePoint = [panGesture translationInView:_superView];
    [panGesture setTranslation:CGPointZero inView:_superView];
    NSLog(@"X:%.0fY:%.0f",movePoint.x,movePoint.y);
    if(_gestureLock == UpOrDown){
        //锁定当前滑动为上下滑动
        
        self.y += movePoint.y;
        if(self.y <= (self.originY - self.height + SnapseedDropMenuCellHeight)) {
            self.y = self.originY - self.height + SnapseedDropMenuCellHeight;
        } else if(self.y >= self.originY) {
            self.y = self.originY;
        }
        [self selectCellByOffsetY];
        
    } else if(_gestureLock == LeftOrRight ){
        //锁定当前滑动为左右滑动
        if(self.dropMenuDelegate) {
            if([self.dropMenuDelegate respondsToSelector:@selector(snapseedDropMenu: atIndex:valueDidChange:)]) {
                [self.dropMenuDelegate snapseedDropMenu:self atIndex:_selectNum valueDidChange:movePoint.x];
            }
        }
        
    } else {
        //首次滑动,判断用户意图为上下滑动还是左右滑动
        if(movePoint.x > -MoveZoom && movePoint.x < MoveZoom ) {
            if(movePoint.y <= -MoveZoom || movePoint.y >= MoveZoom ) {
                if(_gestureLock == UpOrDown || _gestureLock == NoGestureDirection) {
                    _gestureLock = UpOrDown;
                }
            }
        } else {
            _gestureLock = LeftOrRight;
        }
    }
    
}


@end
