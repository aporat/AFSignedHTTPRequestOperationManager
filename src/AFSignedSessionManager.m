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

#import "AFSignedSessionManager.h"
#import "NSString+SHA256HMAC.h"

@implementation AFSignedSessionManager

#pragma mark -

- (instancetype)initWithBaseURL:(NSURL *)url {
    self.clientVersion = @"2";
    
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
  
    return self;
}

#pragma mark -

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error, id responseObject))failure
{
  NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:@"GET" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil success:success failure:failure];
  
  [dataTask resume];
  
  return dataTask;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error, id responseObject))failure
{
  
  NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:@"POST" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil success:success failure:failure];

  [dataTask resume];
  
  return dataTask;
}


- (NSURLSessionDataTask *)PUT:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error, id responseObject))failure
{
  NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:@"PUT" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil success:success failure:failure];
  
  [dataTask resume];
  
  return dataTask;
}

- (NSURLSessionDataTask *)PATCH:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error, id responseObject))failure
{
  NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:@"PATCH" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil success:success failure:failure];
  
  [dataTask resume];
  
  return dataTask;
}

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error, id responseObject))failure
{
  NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:@"DELETE" URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil success:success failure:failure];
  
  [dataTask resume];
  
  return dataTask;
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *, id))failure
{
  NSDictionary *params = [self signatureParamsWithMethod:method URLString:URLString parameters:parameters];

  NSError *serializationError = nil;
  NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:params error:&serializationError];
  if (serializationError) {
    if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
      dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
        failure(nil, serializationError, nil);
      });
#pragma clang diagnostic pop
    }
    
    return nil;
  }
  
  __block NSURLSessionDataTask *dataTask = nil;
  dataTask = [self dataTaskWithRequest:request
                        uploadProgress:uploadProgress
                      downloadProgress:downloadProgress
                     completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                       if (error) {
                         if (failure) {
                           failure(dataTask, error, responseObject);
                         }
                       } else {
                         if (success) {
                           success(dataTask, responseObject);
                         }
                       }
                     }];
  
  return dataTask;
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
