//
//  GMNetworkOperationResult.h
//
//  Created by Gersham Meharg on 10-12-01.
//  Copyright 2010 Gersham Meharg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMImageUploadOperationResult : NSObject

@property NSUInteger type;
@property NSUInteger httpCode;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSDictionary *json;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSString *errorTitle;
@property (nonatomic, strong) NSString *errorDescription;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, copy) id completion;

@end
