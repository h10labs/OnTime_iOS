//
//  OnTimeConnection.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/28/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "OnTimeConnection.h"

// this is necessary to keep the OnTimeConnection around after the caller's
// frame goes out of scope.
static NSMutableArray *sharedConnectionList = nil;

@implementation OnTimeConnection
@synthesize request;
@synthesize completionBlock;

- (id)initWithRequest:(NSURLRequest *)req {
    self = [super init];
    if (self) {
        if (!req){
            [NSException raise:@"Request not provided"
                        format:@"Request needs to be provided for the connection"];
            return nil;
        }
        [self setRequest:req];
    }
    return self;
}

- (id)init {
    [NSException raise:@"Default init failed"
                format:@"Reason: init is not supported by %@", [self class]];
    return nil;
}

- (void)start {
    container = [[NSMutableData alloc] init];
    internalConnection = [[NSURLConnection alloc] initWithRequest:[self request]
                                                         delegate:self
                                                 startImmediately:YES];
    if (!sharedConnectionList){
        sharedConnectionList = [NSMutableArray array];
    }
    [sharedConnectionList addObject:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [container appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // by default we expect JSON response
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:container
                                                             options:0
                                                               error:nil];
    if (self.completionBlock){
        self.completionBlock(jsonData, nil);
    }
    [sharedConnectionList removeObject:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.completionBlock){
        self.completionBlock(nil, error);
    }
    [sharedConnectionList removeObject:self];
}

@end