//
//  APIClient.h
//  AFSignedHTTPRequestOperationManagerExample
//
//  Created by Adar Porat on 4/21/14.
//  Copyright (c) 2014 None. All rights reserved.
//

#import "AFSignedSessionManager.h"

@interface APIClient : AFSignedSessionManager

+ (instancetype)sharedInstance;

@end