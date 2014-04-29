# AFSignedHTTPRequestOperationManager

![](http://cocoapod-badges.herokuapp.com/v/AFSignedHTTPRequestOperationManager/badge.png) &nbsp; ![](http://cocoapod-badges.herokuapp.com/p/AFSignedHTTPRequestOperationManager/badge.png)


AFNetworking 2.0 AFHTTPRequestOperationManager with API signed SHA256 signature and timestamp

Sample usage is available in the `example` project.


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
