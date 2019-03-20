//
//  ViewController.h
//  IndoorsNavi
//
//  Created by Eugenie Tyan on 3/10/19.
//  Copyright © 2019 Eugenie Tyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repositories.h"
#import <CoreData/CoreData.h>

@interface ViewController : UIViewController <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate> {
    BOOL isRequestSuccessful;
}

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *textfieldLogin;
@property (weak, nonatomic) IBOutlet UITextField *textfieldPass;
@property (weak, nonatomic) IBOutlet UIButton *buttonSignIn;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

