//
//  CommitsCell.h
//  IndoorsNavi
//
//  Created by Eugenie Tyan on 3/20/19.
//  Copyright © 2019 Eugenie Tyan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommitsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *commitMessage;
@property (weak, nonatomic) IBOutlet UILabel *hash;

@end

NS_ASSUME_NONNULL_END
