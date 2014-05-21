//
//  BAPersistentOperationQueue.m
//  BAPersistentOperationQueue
//
//  Created by Bruno Abrantes on 20/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import "BAPersistentOperationQueue.h"

@implementation BAPersistentOperationQueue

#pragma mark - Initialization

- (instancetype)init
{
  if (self = [super init]) {
    _operationQueue = [[NSOperationQueue alloc] init];
    // Ensures FIFO
    _operationQueue.maxConcurrentOperationCount = 1;
  }
  
  return self;
}

#pragma mark - Queue management
- (void)insertObject:(id)object
{
  NSDictionary *data = [self.delegate persistentOperationQueueSerializeObject:object];

  NSUInteger timestamp = (NSUInteger)[[NSDate date] timeIntervalSince1970];
  BAPersistentOperation *operation = [[BAPersistentOperation alloc] initWithTimestamp:timestamp
                                                                              andData:data];
  [_operationQueue addOperation:operation];
}

@end
