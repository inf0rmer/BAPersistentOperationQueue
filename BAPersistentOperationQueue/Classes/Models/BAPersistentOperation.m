//
//  BAPersistentOperation.m
//  BAPersistentOperationQueue
//
//  Created by Bruno Abrantes on 21/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import "BAPersistentOperation.h"

@implementation BAPersistentOperation

#pragma mark - Lifecycle

- (instancetype)initWithTimestamp:(double)timestamp
                          andData:(NSDictionary *)data
{
  if (self = [super init]) {
    self.timestamp = timestamp;
    self.data = data;
    
    _isExecuting = NO;
    _isFinished = NO;
  }
  
  return self;
}

- (void)start
{
  [self willChangeValueForKey:@"isExecuting"];
  _isExecuting = YES;
  [self didChangeValueForKey:@"isExecuting"];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate persistentOperationStarted:self];
  });
}

- (void)cancel {
  [super cancel];
  
  [self willChangeValueForKey:@"isExecuting"];
  [self willChangeValueForKey:@"isFinished"];
  
  _isExecuting = NO;
  _isFinished = YES;
  
  [self didChangeValueForKey:@"isExecuting"];
  [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Custom
- (void)finish {
  [self willChangeValueForKey:@"isExecuting"];
  [self willChangeValueForKey:@"isFinished"];
  
  _isExecuting = NO;
  _isFinished = YES;
  
  [self didChangeValueForKey:@"isExecuting"];
  [self didChangeValueForKey:@"isFinished"];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate persistentOperationFinished:self];
  });
}

#pragma mark - Custom setters
- (void)setData:(NSDictionary *)data
{
  if (!data) {
    data = [[NSDictionary alloc] init];
  }
  
  _data = data;
}

- (void)setTimestamp:(double)timestamp
{
  if (!timestamp) {
    timestamp = (double)[[NSDate date] timeIntervalSince1970];
  }
  
  _timestamp = timestamp;
}

#pragma mark - Custom getters

- (BOOL)isConcurrent
{
  return YES;
}

@end
