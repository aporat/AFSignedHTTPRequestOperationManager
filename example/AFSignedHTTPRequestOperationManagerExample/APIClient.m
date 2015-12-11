//
//  APIClient.m
//  AFSignedHTTPRequestOperationManagerExample
//
//  Created by Adar Porat on 4/21/14.
//  Copyright (c) 2014 None. All rights reserved.
//

#import "APIClient.h"

@implementation APIClient

+ (instancetype)sharedInstance {
  static APIClient *_sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.example.com"]];
  });
  
  return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  if (self) {
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.clientId = @"CLIENT_ID";
    self.clientSecret = @"CLIENT_SECRET";
  }
  
  return self;
}


@end
