//
// Copyright 2014 Adar Porat
// Created by Adar Porat (https://github.com/aporat) on 4/15/2014.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//		http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "AFSignedHTTPRequestOperationManager.h"
#import "NSString+SHA256HMAC.h"

@implementation AFSignedHTTPRequestOperationManager

#pragma mark -

- (instancetype)initWithBaseURL:(NSURL *)url {
    self.clientVersion = @"2";
    
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *params = [self signatureParamsWithMethod:@"GET" URLString:URLString parameters:parameters];
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:params error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)HEAD:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(AFHTTPRequestOperation *operation))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *params = [self signatureParamsWithMethod:@"HEAD" URLString:URLString parameters:parameters];
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"HEAD" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:params error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *requestOperation, __unused id responseObject) {
        if (success) {
            success(requestOperation);
        }
    } failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *params = [self signatureParamsWithMethod:@"POST" URLString:URLString parameters:parameters];
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:params error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
       constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *params = [self signatureParamsWithMethod:@"POST" URLString:URLString parameters:parameters];
    
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:params constructingBodyWithBlock:block error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *params = [self signatureParamsWithMethod:@"PUT" URLString:URLString parameters:parameters];
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PUT" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:params error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)PATCH:(NSString *)URLString
                       parameters:(id)parameters
                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *params = [self signatureParamsWithMethod:@"PATCH" URLString:URLString parameters:parameters];
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PATCH" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:params error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString
                        parameters:(id)parameters
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *params = [self signatureParamsWithMethod:@"DELETE" URLString:URLString parameters:parameters];
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"DELETE" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:params error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark -

- (NSDictionary *)signRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters
{
    NSMutableDictionary *params = [parameters mutableCopy];
    if (params==nil) {
        params = [NSMutableDictionary dictionary];
    }
    
    NSDictionary *signatureParams = [self signatureParamsWithMethod:method URLString:URLString parameters:params];
    [params addEntriesFromDictionary:signatureParams];
    
    return params;
}

- (NSDictionary *)signatureParamsWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)params
{
    
    NSString* timestamp = [NSString stringWithFormat:@"%lld",
                           [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] longLongValue]];
    
    NSArray *components = @[method, URLString, [self parameterString:params]];
    
    NSString *signature = [[components componentsJoinedByString:@"\n"] stringByReplacingOccurrencesOfString:@"&&" withString:@"&"];
    signature = [signature SHA256HMACWithKey:self.clientSecret];
    
    NSDictionary *signatureParams = @{
                                      @"auth_version": self.clientVersion,
                                      @"auth_client_id": self.clientId,
                                      @"auth_timestamp": timestamp,
                                      @"auth_signature": signature
                                      };
    
    
    return signatureParams;
}

- (NSString *)parameterString:(NSDictionary *)params {
    NSMutableDictionary* lowerCaseParams = [NSMutableDictionary dictionaryWithCapacity:[params count]];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* obj, BOOL *stop) {
        [lowerCaseParams setObject:obj forKey:[key lowercaseString]];
    }];
    
    NSArray* sortedKeys = [[lowerCaseParams allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray* encodedParamerers = [NSMutableArray array];
    [sortedKeys enumerateObjectsUsingBlock:^(NSString* key, NSUInteger idx, BOOL *stop) {
        [encodedParamerers addObject:[self encodeParamWithoutEscapingUsingKey:key
                                                                     andValue:[lowerCaseParams objectForKey:key]]];
    }];
    return [encodedParamerers componentsJoinedByString:@"&"];
}

- (NSString *)encodeParamWithoutEscapingUsingKey:(NSString*)key andValue:(id<NSObject>)value {
    if ([value isKindOfClass:[NSArray class]]) {
        
        NSArray* array = (NSArray*) value;
        if ([array count]==0) {
            return @"";
        }
        
        NSMutableArray* encodedArray = [NSMutableArray array];
        [array enumerateObjectsUsingBlock:^(id<NSObject> obj, NSUInteger idx, BOOL *stop) {
            
            if (obj!=nil) {
                [encodedArray addObject:[NSString stringWithFormat:@"%@[]=%@", key, obj]];
            }
        }];
        
        return [encodedArray componentsJoinedByString:@"&"];
    } else {
        return [NSString stringWithFormat:@"%@=%@", key, value];
    }
}


@end
