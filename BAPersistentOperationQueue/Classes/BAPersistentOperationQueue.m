//
//  BAPersistentOperationQueue.m
//  BAPersistentOperationQueue
//
//  Created by Bruno Abrantes on 20/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import "BAPersistentOperationQueue.h"
#import <FMDB/FMDatabaseQueue.h>
#import <FMDB/FMDatabase.h>
#import <ObjectiveSugar/ObjectiveSugar.h>

@interface BAPersistentOperationQueue ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

@end

static int cid = 0;

@implementation BAPersistentOperationQueue

#pragma mark - Initialization

- (instancetype)init
{
  if (self = [super init]) {
    // Generate unique ID
    __id = [NSString stringWithFormat:@"BAPersistentOperationQueue_%ld", (long)cid];
    cid++;
    
    // Create operation queue
    _operationQueue = [[NSOperationQueue alloc] init];
    // Ensures FIFO
    _operationQueue.maxConcurrentOperationCount = 1;
    [self stopWorking];
  }
  
  return self;
}

- (instancetype)initWithDatabasePath:(NSString *)path
{
  if (self = [self init]) {
    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    
    // Create initial schema
    [_databaseQueue inDatabase:^(FMDatabase *db) {
      BOOL succeeded = [db executeUpdate:[self sqlForCreatingDBSchema]];
      NSAssert(succeeded, ([NSString stringWithFormat:@"Failed to create a storage table for %@", __id]));
    }];
  }
  
  return self;
}

#pragma mark - Queue information
- (NSArray *)operations {
  return [_operationQueue operations];
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
  [_operationQueue cancelAllOperations];
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

- (NSString *)sqlForCreatingDBSchema
{
  return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (timestamp INTEGER PRIMARY KEY ASC, data TEXT);", __id];
}

@end
