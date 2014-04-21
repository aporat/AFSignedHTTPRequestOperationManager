# AFSignedHTTPRequestOperationManager

AFNetworking 2.0 AFHTTPRequestOperationManager with API signed SHA256 signature and timestamp

Sample usage is available in the `example` project.


## Requirements

`AFSignedHTTPRequestOperationManager` reiles on `AFNetworking` 2.0 +.

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


### extend `AFSignedHTTPRequestOperationManager` into your api client class
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
