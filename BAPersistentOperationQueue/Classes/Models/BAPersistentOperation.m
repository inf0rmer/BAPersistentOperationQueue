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
    _timestamp = timestamp;
    
    if (!_timestamp) {
      _timestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
    }
    
    _data = data;
    
    if (!_data) {
      _data = [[NSDictionary alloc] init];
    }
    
    _finished = NO;
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

@end
