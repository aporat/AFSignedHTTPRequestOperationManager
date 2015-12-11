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
  
  
  [[APIClient sharedInstance] POST:@"/users" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    
  } failure:^(NSURLSessionDataTask *task, NSError *error, id responseObject) {
    
  }];
  
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
