//
//  GMImageManager.h
//
//  Created by Gersham Meharg on 11-02-18.
//  Copyright 2011 Gersham Meharg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMImageUploadOperationResult.h"

#define SharedImageManager \
((GMImageManager *)[GMImageManager shared])

@class GMImageUploadOperationResult;

extern NSString *const ImageUploadCompleteNotification;
extern NSString *const ImageUploadFailedNotification;

@interface GMImageManager : NSObject <UIAlertViewDelegate> 

typedef void (^ImageOperationCallbackBlock)(GMImageUploadOperationResult *);

@property (nonatomic, strong) NSOperationQueue *uploadQueue;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) NSMutableSet *pendingImageDownloads;
@property (nonatomic, strong) NSString *apiEndpoint;

- (void)uploadImage:(UIImage *)image 
               path:(NSString *)path
         parameters:(NSDictionary *)parameters
         completion:(void (^)(GMImageUploadOperationResult *result))completion;

- (void)uploadImage:(UIImage *)image 
                url:(NSURL *)url
         completion:(ImageOperationCallbackBlock)completion;

+ (GMImageManager *)shared;


@end
