//
//  Repositories.h
//  IndoorsNavi
//
//  Created by Eugenie Tyan on 3/13/19.
//  Copyright © 2019 Eugenie Tyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commits.h"

NS_ASSUME_NONNULL_BEGIN

@interface Repositories : UITableViewController <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate> {
    BOOL isEmptyRepo;
}

@property (weak, nonatomic) NSArray *repos;

@end

NS_ASSUME_NONNULL_END
