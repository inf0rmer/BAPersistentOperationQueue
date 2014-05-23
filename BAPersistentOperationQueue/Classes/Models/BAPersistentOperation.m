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

- (instancetype)initWithTimestamp:(NSUInteger)timestamp
                          andData:(NSDictionary *)data
{
  if (self = [super init]) {
    self.timestamp = timestamp;
    self.data = data;
    self.finished = NO;
  }
  
  return self;
}

- (void)main
{
  @autoreleasepool {
    if (self.isCancelled) {
      return;
    }
    
    [self.delegate persistentOperationStartedWithTimestamp:self.timestamp];
    
    if (self.isCancelled) {
      return;
    }
    
    while (_finished == NO) {
      [NSThread sleepForTimeInterval:1.0];
    }
    
    if (self.isCancelled) {
      return;
    }
    
    if (_finished) {
      [self.delegate persistentOperationFinishedWithTimestamp:self.timestamp];
    }
  }
}

#pragma mark - Custom setters
- (void)setData:(NSDictionary *)data
{
  if (!data) {
    data = [[NSDictionary alloc] init];
  }
  
  _data= data;
}

- (void)setTimestamp:(NSUInteger)timestamp
{
  if (!timestamp) {
    timestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
  }
  
  _timestamp = timestamp;
}

@end
