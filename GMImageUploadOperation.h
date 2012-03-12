//
//  GMImageUploadOperation.h
//
//  Created by Gersham Meharg on 11-02-18.
//  Copyright 2011 Gersham Meharg. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GMImageUploadOperationResult;

@interface GMImageUploadOperation : NSOperation

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) GMImageUploadOperationResult *result;
@property (nonatomic, weak) id delegate;
@property (nonatomic, copy) id completion;

- (NSString *)encodeFormPostParameters: (NSDictionary *)postParameters;

@end
