# AFSignedHTTPRequestOperationManager

[![Build Status](https://travis-ci.org/aporat/AFSignedHTTPRequestOperationManager.svg?branch=master)](https://travis-ci.org/aporat/AFSignedHTTPRequestOperationManager) &nbsp;
![](http://cocoapod-badges.herokuapp.com/v/AFSignedHTTPRequestOperationManager/badge.png) &nbsp; ![](http://cocoapod-badges.herokuapp.com/p/AFSignedHTTPRequestOperationManager/badge.png) &nbsp;[![Dependency Status](https://www.versioneye.com/user/projects/5376544914c15877850000b7/badge.svg)](https://www.versioneye.com/user/projects/5376544914c15877850000b7)

Automatically sign AFNetworking api requests with SHA-256 hash signature and timestamp.

Sample usage is available in the `example` project.

The purpose of the SHA256 signature is to guarantee that restful API requests are being delivered only by authorized api clients.

For example, 


```objective-c
    [[APIClient sharedClient] POST:@"/users" parameters:@{@"some" : @"parameters"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
```
will generate a set of auth parameters which can be verified on the server.

```ruby
{
  :some           => "parameters",
  :auth_timestamp => 1273231888,
  :auth_signature => "28b6bb0f242f71064916fad6ae463fe91f5adc302222dfc02c348ae1941eaf80",
  :auth_version   => "2",
  :auth_key       => "my_key"
}

```



## Requirements

`AFSignedHTTPRequestOperationManager` reiles on `AFNetworking 2.0` and `IGDigest`.

## Installation

### CocoaPods

Add the following line to your Podfile:

```ruby
pod 'AFSignedHTTPRequestOperationManager'
```

Then run the following in the same directory as your Podfile:
```ruby
pod install
```

### Manual

Copy the folder `src` to your project.

## Usage

`AFSignedHTTPRequestOperationManager` is a subclass of `AFHTTPRequestOperationManager`, so use the class as a normally use a `AFNetworking` api client.


### extend `AFSignedHTTPRequestOperationManager`

```objective-c
#import "AFSignedHTTPRequestOperationManager.h"

@interface APIClient : AFSignedHTTPRequestOperationManager

+ (instancetype)sharedClient;

@end
```

```objective-c
#import "APIClient.h"

@implementation APIClient

+ (instancetype)sharedClient {
    static APIClient *_sharedClient = nil;
    static dispatch_once_t onceKosherPenguinToken;
    dispatch_once(&onceKosherPenguinToken, ^{
        _sharedClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.example.com"]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.clientId = @"CLIENT_ID";
        self.clientSecret = @"CLIENT_SECRET";
    }
    
    return self;
}


@end
```

### Call your API

```objective-c
    [[APIClient sharedClient] POST:@"/users" parameters:@{@"site_id" : @10} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
```

### On the backend

Ruby - Use https://github.com/mloughran/signature

PHP Example

```php

    $client_id = 'CLIENT_ID';
    $client_secret = 'CLIENT_SECRET';

    $auth_version = $app->request->params('auth_version');
    $auth_client_id = $app->request->params('auth_client_id');
    $auth_signature = $app->request->params('auth_signature');
    $auth_timestamp = $app->request->params('auth_timestamp');

    if ($auth_version != "2") {
        throw new Exception('Incorrect client version');
    }

    if ($auth_client_id != $client_id) {
        throw new Exception('Incorrect client id');
    }
  
    if ($auth_timestamp <= time() - (60*60*12) || $auth_timestamp >= time() + 60*60*12) {
        throw new Exception('Incorrect auth timestamp');
    }

    
    // generate the auth_signature
    $params = $app->request->params();
    ksort($params);
    
    foreach ($params as $key => $value) {
        if (substr($key, 0, 5)=='auth_') {
            unset($params[$key]);
        }
    }
    
    $signatureString = '';
    foreach ($params as $key => $value) {
        
        if (is_array($value)) {
            foreach ($value as $item) {
                $signatureString[] = $key . '[]=' . $item;
            }
        } else {
            $signatureString[] = $key . '=' . $value;
        }
    }
    
    $signatureString = $app->request->getMethod() . "\n" . urldecode($app->request->getPathInfo()) . "\n" . urldecode(implode('&', $signatureString));
    $checksum = hash_hmac('sha256', $signatureString, $client_secret);
    
    if ($checksum!=$auth_signature) {
        throw new Exception('Incorrect auth signature ' . $signatureString);
    }

```
