//
//  ViewController.m
//  AFSignedHTTPRequestOperationManagerExample
//
//  Created by Adar Porat on 4/21/14.
//  Copyright (c) 2014 None. All rights reserved.
//

#import "ViewController.h"
#import "APIClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];



    [[APIClient sharedClient] POST:@"/users" parameters:@{@"site_id" : @10} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
