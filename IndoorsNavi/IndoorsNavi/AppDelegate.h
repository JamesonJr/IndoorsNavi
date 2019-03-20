//
//  AppDelegate.h
//  IndoorsNavi
//
//  Created by Eugenie Tyan on 3/10/19.
//  Copyright © 2019 Eugenie Tyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

