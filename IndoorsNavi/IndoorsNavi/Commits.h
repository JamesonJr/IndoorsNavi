//
//  Commits.h
//  IndoorsNavi
//
//  Created by Eugenie Tyan on 3/13/19.
//  Copyright © 2019 Eugenie Tyan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Commits : UITableViewController

@property (weak, nonatomic) NSArray *commits;
@property (assign, nonatomic) BOOL isEmpty;

@end

NS_ASSUME_NONNULL_END
