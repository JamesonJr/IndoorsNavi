//
//  CommitsCell.m
//  IndoorsNavi
//
//  Created by Eugenie Tyan on 3/20/19.
//  Copyright © 2019 Eugenie Tyan. All rights reserved.
//

#import "CommitsCell.h"

@implementation CommitsCell

@synthesize author, hash, commitMessage, date;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
