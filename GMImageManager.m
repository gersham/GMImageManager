//
//  GMImageManager.m
//
//  Created by Gersham Meharg on 11-02-18.
//  Copyright 2011 Gersham Meharg. All rights reserved.
//

#import "GMImageManager.h"
#import "GMImageUploadOperation.h"
#import "GMImageUploadOperationResult.h"
#import "NSString+URLEncode.h"

@implementation GMImageManager
static GMImageManager *shared = nil;

NSString *const ImageUploadCompleteNotification = @"ImageUploadCompleteNotification";
NSString *const ImageUploadFailedNotification = @"ImageUploadFailedNotification";

@synthesize uploadQueue;
@synthesize downloadQueue = _downloadQueue;
@synthesize pendingImageDownloads = _pendingImageDownloads;
@synthesize apiEndpoint = _apiEndpoint;

- (void)uploadImage:(UIImage *)image 
               path:(NSString *)path
         parameters:(NSDictionary *)parameters
         completion:(void (^)(GMImageUploadOperationResult *result))completion {

	// Build URL
	NSString *location;
	if (parameters.count > 0) {
        NSMutableString *args = [NSMutableString stringWithString:@"?"];
		for (NSString *key in parameters) {
            if ([parameters objectForKey:key] == [NSNull null]) {
                DLog(@"Null value for %@ skipping", key);
                continue;
            }
            
            NSString *value = [[parameters objectForKey:key] urlEncodedString];
			[args appendString:[NSString stringWithFormat:@"%@=%@&", key, value]];
		}	
		location = [NSString stringWithFormat:@"%@%@%@", _apiEndpoint, path, [args substringWithRange:NSMakeRange(0, args.length-1)]];
        
	} else { 
		location = [NSString stringWithFormat:@"%@%@", _apiEndpoint, path];
	}
    
	NSURL *url = [[NSURL alloc] initWithString:location];
    
    [self uploadImage:image url:url completion:completion];
}

- (void)uploadImage:(UIImage *)image 
                url:(NSURL *)url
         completion:(void (^)(GMImageUploadOperationResult *result))completion {
        
    NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 0.5)];
    
    // Do Operation
    if (url != nil) {        
        GMImageUploadOperation *op = [GMImageUploadOperation new];
        op.url = url;
        op.completion = completion;
        op.delegate = self;
        op.data = data;
        [self.uploadQueue addOperation:op];		
        
    } else {
        NSLog(@"Not performing network operation for undefined url");
    }
}

- (void)uploadResult:(GMOperationResult *)result {
    OperationCallbackBlock block = (OperationCallbackBlock)result.completion;
    block(result);
}

#pragma mark Singleton
+ (id)shared {
	@synchronized(self) {
		if(shared == nil)
			shared = [[super allocWithZone:NULL] init];
	}
	return shared;
}

+ (id)allocWithZone:(NSZone *)zone {
	return [self shared];
}

- (id)init {
	if ((self = [super init])) {
        self.uploadQueue = [[NSOperationQueue alloc] init];
        [self.uploadQueue setMaxConcurrentOperationCount:1];
	}
	return self;
}


@end
