//
//  BAPersistentOperationQueue.m
//  BAPersistentOperationQueue
//
//  Created by Bruno Abrantes on 20/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import "BAPersistentOperationQueue.h"
#import <ObjectiveSugar/ObjectiveSugar.h>

@interface BAPersistentOperationQueue ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation BAPersistentOperationQueue

#pragma mark - Initialization

- (instancetype)init
{
  if (self = [super init]) {
    _operationQueue = [[NSOperationQueue alloc] init];
    // Ensures FIFO
    _operationQueue.maxConcurrentOperationCount = 1;
    [self stopWorking];
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
  operation.delegate = self;
  [_operationQueue addOperation:operation];
}

- (void)startWorking
{
  [_operationQueue setSuspended:NO];
  self.suspended = NO;
}

- (void)stopWorking
{
  [_operationQueue setSuspended:YES];
  self.suspended = YES;
}

- (void)flush
{

}

#pragma mark - BAPersistentOperationDelegate
- (void)persistentOperationStartedWithTimestamp:(NSUInteger)timestamp
{
  BAPersistentOperation *operation = [self operationFromTimestamp:timestamp];
  [self.delegate persistentOperationQueueReceivedOperation:operation];
}

- (void)persistentOperationFinishedWithTimestamp:(NSUInteger)timestamp
{
  
}

#pragma mark - Helpers
- (BAPersistentOperation *)operationFromTimestamp:(NSUInteger)timestamp
{
  BAPersistentOperation *operation = [[_operationQueue.operations select:^BOOL(BAPersistentOperation *operation) {
    return (operation.timestamp == timestamp);
  }] firstObject];
  
  return operation;
}

@end
