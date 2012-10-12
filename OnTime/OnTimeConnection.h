//
//  OnTimeConnection.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/28/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnTimeConnection : NSObject
<NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    NSURLConnection *internalConnection; // why is this necessary??
    NSMutableData *container;
}

- (id)initWithRequest:(NSURLRequest *) req;
- (void)start;

@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) void (^completionBlock)(id obj, NSError *err);
@end
