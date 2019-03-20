//
//  TableViewCell.h
//  IndoorsNavi
//
//  Created by Eugenie Tyan on 3/16/19.
//  Copyright © 2019 Eugenie Tyan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *projectTitle;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *forksAndWatchs;
@property (weak, nonatomic) IBOutlet UILabel *projectDescription;

@end

NS_ASSUME_NONNULL_END
