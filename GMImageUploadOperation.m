//
//  GMImageUploadOperation.m
//
//  Created by Gersham Meharg on 11-02-18.
//  Copyright 2011 Gersham Meharg. All rights reserved.
//

#import "GMImageUploadOperation.h"
#import "GMImageManager.h"
#import "GMImageUploadOperationResult.h"

@implementation GMImageUploadOperation
@synthesize url = _url;
@synthesize completion = _completion;
@synthesize result = _result;
@synthesize delegate = _delegate;
@synthesize data = _data;

- (void)main {
    
    NSLog(@"Uploading image to %@", _url);

    NSDateFormatter *format = [[NSDateFormatter alloc] init]; 
    [format setDateFormat:@"yyyyMMddHHmmss"];
    NSString *imageName = [NSString stringWithFormat:@"Image_%@", [format stringFromDate:[NSDate date]]];
    
    NSString *methodString = @"POST";

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:_url];
	[request setHTTPMethod:methodString];
    [request setValue:UIAppDelegate.apiKey forHTTPHeaderField:@"APIKEY"];

    NSString *boundary = @"---------------------------Boundary Line---------------------------";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@.jpg\"\r\n", imageName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:_data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set body with request.
    [request setHTTPBody:body];
    [request addValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
                
    NSError *error = nil;
    NSHTTPURLResponse *response;    
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    self.result = [ETImageUploadOperationResult new];
	_result.httpCode = [response statusCode];
	_result.url = _url;
    _result.completion = _completion;

    if ([response statusCode] == 201 || [response statusCode] == 200) {
        NSLog(@"Image uploaded, bytes: %i", body.length);
        
        NSError *error = nil;
        _result.json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if (error != nil) {
            NSLog(@"Error parsing JSON %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
      		NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithCapacity:2];
            [errorInfo setObject:@"JSON Parsing Error" forKey:NSLocalizedDescriptionKey];
            [errorInfo setObject:@"Error parsing JSON" forKey:NSLocalizedFailureReasonErrorKey];
            _result.error = [NSError errorWithDomain:@"NetworkOperationError" code:_result.httpCode userInfo:errorInfo];
            _result.errorTitle = [_result.error.userInfo objectForKey:NSLocalizedDescriptionKey];
            _result.errorDescription = [_result.error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
     }

    } else if ([response statusCode] == 401) {
        NSLog(@"Authentication failed for image upload");
        _result.httpCode = 401;
        [errorInfo setObject:@"Authentication Failure" forKey:NSLocalizedDescriptionKey];
        [errorInfo setObject:@"The supplied API Key was not found" forKey:NSLocalizedFailureReasonErrorKey];
        _result.error = [NSError errorWithDomain:@"NetworkOperationError" code:_result.httpCode userInfo:errorInfo];
        _result.errorTitle = [_result.error.userInfo objectForKey:NSLocalizedDescriptionKey];
        _result.errorDescription = [_result.error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
      
    } else if ([response statusCode] == 400) {
        _result.httpCode = 400;
        [errorInfo setObject:@"Upload Error" forKey:NSLocalizedDescriptionKey];
        [errorInfo setObject:responseString forKey:NSLocalizedFailureReasonErrorKey];
        _result.error = [NSError errorWithDomain:@"NetworkOperationError" code:_result.httpCode userInfo:errorInfo];
        _result.errorTitle = [_result.error.userInfo objectForKey:NSLocalizedDescriptionKey];
        _result.errorDescription = [_result.error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey];

    } else if (error != nil) {
        [errorInfo setObject:@"Connection Error" forKey:NSLocalizedDescriptionKey];
        [errorInfo setObject:error.localizedDescription forKey:NSLocalizedFailureReasonErrorKey];
        _result.error = [NSError errorWithDomain:@"NetworkOperationError" code:_result.httpCode userInfo:errorInfo];
        _result.errorTitle = [_result.error.userInfo objectForKey:NSLocalizedDescriptionKey];
        _result.errorDescription = [_result.error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    
    } else {
        [errorInfo setObject:@"Upload Error" forKey:NSLocalizedDescriptionKey];
        [errorInfo setObject:responseString forKey:NSLocalizedFailureReasonErrorKey];
        _result.error = [NSError errorWithDomain:@"NetworkOperationError" code:_result.httpCode userInfo:errorInfo];
        _result.errorTitle = [_result.error.userInfo objectForKey:NSLocalizedDescriptionKey];
        _result.errorDescription = [_result.error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    }

	// Send the result to the delegate
	if ([_delegate respondsToSelector:@selector(uploadResult:)]) {
		[_delegate performSelectorOnMainThread:@selector(uploadResult:) withObject:_result waitUntilDone:YES];
        
	} else if (_delegate != nil) {
		NSLog(@"* Delegate doesn't respond to networkOperationResult");
	}	

}

- (NSString *)encodeFormPostParameters: (NSDictionary *)postParameters {
    NSMutableString *formPostParams = [[NSMutableString alloc] init];
    
    NSEnumerator *keys = [postParameters keyEnumerator];
    
    NSString *name = [keys nextObject];
    while (nil != name) {
        NSString *encodedValue = ((__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) [postParameters objectForKey:name], NULL, CFSTR("=/:"), kCFStringEncodingUTF8));
        
        [formPostParams appendString: name];
        [formPostParams appendString: @"="];
        [formPostParams appendString: encodedValue];
        
        name = [keys nextObject];
        
        if (nil != name) {
            [formPostParams appendString: @"&"];
        }
    }
    
    return formPostParams;
}


@end
