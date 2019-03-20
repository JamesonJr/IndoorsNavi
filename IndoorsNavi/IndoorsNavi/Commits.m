//
//  Commits.m
//  IndoorsNavi
//
//  Created by Eugenie Tyan on 3/13/19.
//  Copyright © 2019 Eugenie Tyan. All rights reserved.
//

#import "Commits.h"
#import "CommitsCell.h"

@interface Commits ()

@end

@implementation Commits

@synthesize isEmpty, commits;

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath {
    return 120;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isEmpty) {
        return 1;
    } else {
        return commits.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"CommitsCell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];
    CommitsCell *cell = (CommitsCell *)[tableView dequeueReusableCellWithIdentifier: cellId];
    if (cell == nil) {
        cell = [[CommitsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellId];
    }
    //    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: cellId];
    if (isEmpty) {
        cell.commitMessage.hidden = TRUE;
        cell.date.hidden = TRUE;
        cell.hash.hidden = TRUE;
        cell.author.text = @"Empty repo";
    } else {
        NSDictionary *tempDict = commits[indexPath.row];
        if ([tempDict objectForKey: @"name"] != (id)[NSNull null]) {
            cell.author.text = [tempDict objectForKey: @"name"];
        }
        if ([tempDict objectForKey: @"message"] != (id)[NSNull null]) {
            cell.commitMessage.text = [tempDict objectForKey: @"message"];
        }
        if ([tempDict objectForKey: @"date"] != (id)[NSNull null]) {
            NSArray *dateCommit = [[tempDict objectForKey: @"date"] componentsSeparatedByString: @"T"];
            cell.date.text = dateCommit[0];
        }
        if ([tempDict objectForKey: @"hash"] != (id)[NSNull null]) {
            cell.hash.text = [tempDict objectForKey: @"hash"];
        }
    }
    
    
    
    //    NSLog(@"%li", [indexPath row]);
    return cell;
}



@end
