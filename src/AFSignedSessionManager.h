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

#import <AFNetworking/AFNetworking.h>

@interface AFSignedSessionManager : AFHTTPSessionManager

@property (nonatomic, strong, nonnull) NSString *clientId;
@property (nonatomic, strong, nonnull) NSString *clientSecret;
@property (nonatomic, strong, nonnull) NSString *clientVersion;

- (nullable NSURLSessionDataTask *)GET:(nullable NSString *)URLString
                            parameters:(nullable id)parameters
                               success:(nullable void (^)(NSURLSessionDataTask *  _Nullable task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error, id  _Nullable responseObject))failure;


- (nullable NSURLSessionDataTask *)POST:(nullable NSString *)URLString
                            parameters:(nullable id)parameters
                               success:(nullable void (^)(NSURLSessionDataTask *  _Nullable task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error, id  _Nullable responseObject))failure;



- (nullable NSURLSessionDataTask *)PUT:(nullable NSString *)URLString
                            parameters:(nullable id)parameters
                               success:(nullable void (^)(NSURLSessionDataTask *  _Nullable task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error, id  _Nullable responseObject))failure;



- (nullable NSURLSessionDataTask *)PATCH:(nullable NSString *)URLString
                            parameters:(nullable id)parameters
                               success:(nullable void (^)(NSURLSessionDataTask *  _Nullable task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error, id  _Nullable responseObject))failure;



- (nullable NSURLSessionDataTask *)DELETE:(nullable NSString *)URLString
                            parameters:(nullable id)parameters
                               success:(nullable void (^)(NSURLSessionDataTask *  _Nullable task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error, id  _Nullable responseObject))failure;

- (nullable NSURLSessionDataTask *)dataTaskWithHTTPMethod:(nullable NSString *)method
                                                URLString:(NSString * _Nullable)URLString
                                               parameters:(id _Nullable)parameters
                                           uploadProgress:(nullable void (^)(NSProgress * _Nullable uploadProgress)) uploadProgress
                                         downloadProgress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                                                  success:(void (^ _Nullable)(NSURLSessionDataTask * _Nullable, id _Nullable))success
                                                  failure:(void (^ _Nullable)(NSURLSessionDataTask * _Nullable, NSError * _Nullable, id _Nullable))failure;

- (nullable NSDictionary *)signatureParamsWithMethod:(NSString * _Nullable)method URLString:(NSString * _Nullable)URLString parameters:(NSDictionary * _Nullable)params;

@end
