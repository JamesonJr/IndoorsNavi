//
//  TableViewCell.m
//  IndoorsNavi
//
//  Created by Eugenie Tyan on 3/16/19.
//  Copyright © 2019 Eugenie Tyan. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

@synthesize projectTitle, projectDescription, avatar, forksAndWatchs, author;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
