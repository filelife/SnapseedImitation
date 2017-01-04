//
//  SnapseedDropMenuTableViewCell.m
//  CoreImageDemo
//
//  Created by Gejiaxin on 16/12/28.
//  Copyright © 2016  VincentJac. All rights reserved.
//

#import "SnapseedDropMenuTableViewCell.h"

@interface SnapseedDropMenuTableViewCell()

@end

@implementation SnapseedDropMenuTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.mainView = [[UIView alloc]  initWithFrame:CGRectMake(0, -1, SnapseedDropMenuCellWidth, SnapseedDropMenuCellHeight + 2)];
    self.mainView.opaque = YES;
    [self.contentView addSubview:self.mainView];
    
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SnapseedDropMenuCellWidth, SnapseedDropMenuCellHeight)];
    self.title.textColor = [UIColor whiteColor];
    [self.mainView addSubview:self.title];
    
    self.valueLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SnapseedDropMenuCellWidth - 15, SnapseedDropMenuCellHeight)];
    self.valueLab.textAlignment = NSTextAlignmentRight;
    self.valueLab.textColor = [UIColor whiteColor];
    [self.mainView addSubview:self.valueLab];
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
