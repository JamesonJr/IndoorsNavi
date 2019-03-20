//
//  ViewController.m
//  IndoorsNavi
//
//  Created by Eugenie Tyan on 3/10/19.
//  Copyright © 2019 Eugenie Tyan. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
{
    AppDelegate *appDelegate;
    NSManagedObjectContext *context;
    NSArray *dictionaries;
    NSArray *outputData;
}

@end

@implementation ViewController

@synthesize errorLabel, textfieldLogin, textfieldPass, tapRecognizer;
dispatch_semaphore_t sema;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    errorLabel.hidden = YES;
    isRequestSuccessful = TRUE;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver: self selector: @selector(keyboardWillShow:) name:
     UIKeyboardWillShowNotification object: nil];
    
    [nc addObserver: self selector: @selector(keyboardWillHide:) name:
     UIKeyboardWillHideNotification object: nil];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                            action: @selector(didTapAnywhere:)];
    sema = dispatch_semaphore_create(0);
    
}

- (void) viewDidAppear:(BOOL)animated {
    [self checkAuthorization];
}

#pragma mark - Hide keyboard by tapping
-(void) keyboardWillShow:(NSNotification *) note {
    [self.view addGestureRecognizer:tapRecognizer];
}

-(void) keyboardWillHide:(NSNotification *) note
{
    [self.view removeGestureRecognizer:tapRecognizer];
}

-(void)didTapAnywhere: (UITapGestureRecognizer *) recognizer {
    [textfieldPass resignFirstResponder];
    [textfieldLogin resignFirstResponder];
}

#pragma mark - NSURLSessionDelegate

- (void) authorizationRequestToGithub: (NSString *) username andPass: (NSString *) password {
    
    NSString *requestString = @"https://api.github.com/user/repos";
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *req = [NSURLRequest requestWithURL: url];
    
    NSData *userPasswordData = [[NSString stringWithFormat: @"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedCredential = [userPasswordData base64EncodedStringWithOptions:0];
    NSString *authString = [NSString stringWithFormat: @"Basic %@", base64EncodedCredential];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders=@{@"Authorization":authString};
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration: sessionConfiguration
                                                          delegate: self
                                                     delegateQueue: [NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest: req];
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if (data) {
        NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
//        NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if (!isRequestSuccessful) {
            if ([jsonObject valueForKey: @"message"]) {
                if ([[jsonObject valueForKey: @"message"] isEqualToString: @"Bad credentials"]) {
                    errorLabel.hidden = FALSE;
                    errorLabel.text = @"Неверные данные учетной записи";
                }
                if ([[jsonObject valueForKey: @"message"] isEqualToString: @"Requires authentication"]) {
                    errorLabel.hidden = FALSE;
                    errorLabel.text = @"Заполните поля логин и пароль";
                }
            }
        } else {
            outputData = [self parseJSON: jsonObject];
//            NSLog(@"%@", outputData);
        }
//        NSArray *arr = [jsonObject allKeys];
//        if (arr) {
//            NSLog(@"%@", arr);
//        }
//        NSArray *arr = [jsonObject allValues];
//        NSLog(@"%@", arr[0]);
        
    } else {
        errorLabel.hidden = FALSE;
        errorLabel.text = @"Проверьте подключение к интернету";
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"didCompleteWithError");
    if (error) {
        NSLog(@"Error");
    }
    dispatch_semaphore_signal(sema);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
        if ([(NSHTTPURLResponse *) response statusCode] != 200) {
            errorLabel.hidden = FALSE;
            errorLabel.text = @"Проверьте подключение к интернету";
            isRequestSuccessful = FALSE;
        }
    }
    completionHandler(NSURLSessionResponseAllow);
}

#pragma mark -

- (IBAction)buttonSignInPressed:(id)sender {
    
    NSString *username = textfieldLogin.text;
    NSString *password = textfieldPass.text;
    
    [self authorizationRequestToGithub: username andPass: password];
    while (dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop]
         runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    }
    if (isRequestSuccessful) {
        NSLog(@"Segue");
        NSManagedObject *entityObject = [NSEntityDescription insertNewObjectForEntityForName: @"Authorization" inManagedObjectContext: context];
        [entityObject setValue: textfieldLogin.text forKey: @"login"];
        [entityObject setValue: textfieldPass.text forKey: @"password"];
        [appDelegate saveContext];
        [self performSegueWithIdentifier: @"LoggedIn" sender: self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString: @"LoggedIn"])
    {
        // Get reference to the destination view controller
        UINavigationController *navi = [segue destinationViewController];
        Repositories *vc = (Repositories *)navi.topViewController;

        // Pass any objects to the view controller here, like...
        vc.repos = outputData;
    }
}

- (void) checkAuthorization {
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    context = appDelegate.persistentContainer.viewContext;
    
    // Do any additional setup after loading the view.
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Authorization"];
    NSArray *results = [context executeFetchRequest: request error: nil];
    if (results.count > 0) {
        NSDictionary *dictionary;
        NSArray *keys;
        NSMutableArray *resultsData = [[NSMutableArray alloc] init];
        for (NSManagedObject *obj in results) {
            keys = [[[obj entity] attributesByName] allKeys];
            dictionary =[obj dictionaryWithValuesForKeys: keys];
            [resultsData addObject: dictionary];
            
        }
        
        NSString *username = [resultsData[0] valueForKey: @"login"];
        NSString *password = [resultsData[0] valueForKey: @"password"];
        [self authorizationRequestToGithub: username andPass: password];
        while (dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop]
             runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        }
        if (isRequestSuccessful) {
            [self performSegueWithIdentifier: @"LoggedIn" sender: self];
        }
    }
}

- (NSMutableArray *) parseJSON: (NSArray *) input {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i < input.count; i++) {
        NSMutableDictionary *outputDict = [[NSMutableDictionary alloc] init];
        NSString *temp = [self checkAndGet: input [i] andKey: @"commits_url"];
        [outputDict setObject: temp forKey: @"commits_url"];
        temp = [self checkAndGet: input [i] andKey: @"description"];
        [outputDict setObject: temp forKey: @"description"];
        temp = [self checkAndGet: input [i] andKey: @"forks_count"];
        [outputDict setObject: temp forKey: @"forks_count"];
        temp = [self checkAndGet: input [i] andKey: @"watchers_count"];
        [outputDict setObject: temp forKey: @"watchers_count"];
        temp = [self checkAndGet: input [i] andKey: @"name"];
        [outputDict setObject: temp forKey: @"name"];
        if ([input[i] valueForKey: @"owner"]) {
            NSDictionary *dict = [input[i] valueForKey: @"owner"];
            temp = [self checkAndGet: dict andKey: @"login"];
            [outputDict setObject: temp forKey: @"login"];
            temp = [self checkAndGet: dict andKey: @"avatar_url"];
            [outputDict setObject: temp forKey: @"avatar_url"];
        }
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

@end
