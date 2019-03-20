//
//  Repositories.m
//  IndoorsNavi
//
//  Created by Eugenie Tyan on 3/13/19.
//  Copyright © 2019 Eugenie Tyan. All rights reserved.
//

#import "Repositories.h"
#import "TableViewCell.h"

@interface Repositories () {
    NSArray *outputData;
}

@end

@implementation Repositories

@synthesize repos;
dispatch_semaphore_t sema1;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isEmptyRepo = FALSE;
    sema1 = dispatch_semaphore_create(0);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return repos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"Cell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier: cellId];
    if (cell == nil) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellId];
    }
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: cellId];
    NSDictionary *tempDict = repos[indexPath.row];
    if ([tempDict objectForKey: @"name"] != (id)[NSNull null]) {
        cell.projectTitle.text = [tempDict objectForKey: @"name"];
    }
    if ([tempDict objectForKey: @"description"] != (id)[NSNull null]) {
        cell.projectDescription.text = [tempDict objectForKey: @"description"];
    }
    if ([tempDict objectForKey: @"login"] != (id)[NSNull null]) {
        cell.author.text = [tempDict objectForKey: @"login"];
    }
    if ([tempDict objectForKey: @"name"] != (id)[NSNull null]) {
        cell.projectTitle.text = [tempDict objectForKey: @"name"];
    }
    if ([tempDict objectForKey: @"watchers_count"] != (id)[NSNull null] && [tempDict objectForKey: @"forks_count"] != (id)[NSNull null]) {
        cell.forksAndWatchs.text = [NSString stringWithFormat: @"W: %@ F: %@", [tempDict objectForKey: @"watchers_count"], [tempDict objectForKey: @"forks_count"]];
    }
    if ([tempDict objectForKey: @"avatar_url"] != (id)[NSNull null]) {
        cell.avatar.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: [tempDict objectForKey: @"avatar_url"]]]];
    }
    
    
//    NSLog(@"%li", [indexPath row]);
    return cell;
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath {
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tempDict = repos [indexPath.row];
    if ([tempDict objectForKey: @"commits_url"] != (id)[NSNull null]) {
        NSString *commitsString = [tempDict objectForKey: @"commits_url"];
        NSArray *arr = [commitsString componentsSeparatedByString: @"{"];
        NSURL *commitsURL = [NSURL URLWithString: arr[0]];
        [self commitsRequest: commitsURL];
        while (dispatch_semaphore_wait(sema1, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop]
             runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        }
        
            [self performSegueWithIdentifier: @"CommitSegue" sender: self];
    }
    


}

- (NSArray *) parseCommitsJSON: (NSArray *) input {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i < input.count; i++) {
        NSMutableDictionary *outputDict = [[NSMutableDictionary alloc] init];
        
        NSString *temp = [self checkAndGet: input [i] andKey: @"sha"];
        [outputDict setObject: temp forKey: @"hash"];
        if ([input[i] valueForKey: @"commit"]) {
            NSDictionary *dict = [input[i] valueForKey: @"commit"];
            temp = [self checkAndGet: dict andKey: @"message"];
            [outputDict setObject: temp forKey: @"message"];
            if ([dict valueForKey: @"committer"]) {
                NSDictionary *committer = [dict valueForKey: @"committer"];
                
                temp = [self checkAndGet: committer andKey: @"name"];
                [outputDict setObject: temp forKey: @"name"];
                temp = [self checkAndGet: committer andKey: @"date"];
                [outputDict setObject: temp forKey: @"date"];
            }
            
        }
        
        NSLog(@"%@", outputDict);
        [arr addObject: outputDict];
    }
    return arr;
}

- (NSString *) checkAndGet: (NSDictionary *) dict andKey: (NSString *) key{
    if ([dict valueForKey: key]) {
        return [dict valueForKey: key];
    }
    return 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString: @"CommitSegue"])
    {
        Commits *destController = (Commits *) [segue destinationViewController];
        destController.commits = outputData;
        destController.isEmpty = isEmptyRepo;
    }
}

#pragma mark - NSURLSessionDelegate

- (void) commitsRequest: (NSURL *) url {
    NSURLRequest *req = [NSURLRequest requestWithURL: url];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: sessionConfiguration
                                                          delegate: self
                                                     delegateQueue: [NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req];
    [dataTask resume];
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if (data) {
//        NSLog(@"parse JSON");
        if (!isEmptyRepo) {
            NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
            outputData = [self parseCommitsJSON: jsonObject];
            
        } else {
            NSLog(@"Empty Repo");
        }
        
        
    } else {
        NSLog(@"error");
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"didCompleteWithError");
    if (error) {
        NSLog(@"Error");
    }
    dispatch_semaphore_signal(sema1);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
        if ([(NSHTTPURLResponse *) response statusCode] != 200) {
            NSLog(@"error !200");
            isEmptyRepo = TRUE;
        } else {
            isEmptyRepo = FALSE;
        }
    }
    completionHandler(NSURLSessionResponseAllow);
}

@end
