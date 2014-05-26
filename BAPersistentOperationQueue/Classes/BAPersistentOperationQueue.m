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
#import <FMDB/FMDatabaseAdditions.h>

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
      [db close];
    }];
  }
  
  return self;
}

#pragma mark - Queue information
- (NSArray *)operations {
  return [_operationQueue operations];
}

#pragma mark - Queue management
- (void)addObject:(id)object
{
  NSDictionary *data = [self.delegate persistentOperationQueueSerializeObject:object];

  BAPersistentOperation *operation = [[BAPersistentOperation alloc] initWithTimestamp:0
                                                                              andData:data];
  operation.delegate = self;
  [_operationQueue addOperation:operation];
  
  [self insertOperationInDatabase:operation];
}

- (void)startWorking
{
  [_operationQueue setSuspended:NO];
  _suspended = NO;
  
  [self loadOperationsFromDatabase];
}

- (void)stopWorking
{
  [_operationQueue setSuspended:YES];
  _suspended = YES;
}

- (void)flush
{
  [_operationQueue cancelAllOperations];
  
  if (_databaseQueue != nil) {
    [_databaseQueue inDatabase:^(FMDatabase *db) {
      if ([db open]) {
        [db executeUpdate:[self sqlForDeletingAllOperations]];
        [db close];
      }
    }];
  }
}

#pragma mark - BAPersistentOperationDelegate
- (void)persistentOperationStarted:(BAPersistentOperation *)operation
{
  [self.delegate persistentOperationQueueStartedOperation:operation];
}

- (void)persistentOperationFinished:(BAPersistentOperation *)operation
{
  [self deleteOperationFromDatabaseWithTimestamp:operation.timestamp];
}

#pragma mark - Database
- (void)insertOperationInDatabase:(BAPersistentOperation *)operation
{
  if (_databaseQueue == nil) {
    return;
  }
  
  [_databaseQueue inDatabase:^(FMDatabase *db) {
    NSString *timestamp = [NSString stringWithFormat:@"%f", operation.timestamp];
    NSUInteger count = [db doubleForQuery:[self sqlForCheckingIfOperationExists], timestamp];
    
    if (count == 0 && [db open]) {
      NSString *data = [self JSONStringFromDictionary:operation.data];
      NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:timestamp, @"timestamp", data, @"data", nil];
      [db executeUpdate:[self sqlForInsertingOperation] withParameterDictionary:args];
      [db close];
    }
  }];
}

- (void)deleteOperationFromDatabaseWithTimestamp:(double)timestamp
{
  if (_databaseQueue == nil || !timestamp) {
    return;
  }
  
  [_databaseQueue inDatabase:^(FMDatabase *db) {
    if ([db open]) {
      [db executeUpdate:[self sqlForDeletingOperationWithTimestamp], [NSString stringWithFormat:@"%f", timestamp]];
      [db close];
    }
  }];
}

- (void)loadOperationsFromDatabase
{
  if (_databaseQueue == nil) {
    return;
  }
  
  [_databaseQueue inDatabase:^(FMDatabase *db) {
    if ([db open]) {
      NSString *sql = [self sqlForFetchOperation];
      FMResultSet *results = [db executeQuery:sql];
      
      while ([results next]) {
        double timestamp = [[results stringForColumn:@"timestamp"] doubleValue];
        NSString *json = [results stringForColumn:@"data"];
        NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:0
                                                               error:nil];
        
        BAPersistentOperation *operation = [[BAPersistentOperation alloc] initWithTimestamp:timestamp
                                                                                    andData:data];
        operation.delegate = self;
        
        [self.operationQueue addOperation:operation];
      }
      
      [db close];
    }
  }];
}

#pragma mark - Helpers

- (NSString *)sqlForCreatingDBSchema
{
  return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (timestamp TEXT PRIMARY KEY, data TEXT);", __id];
}

- (NSString *)sqlForInsertingOperation
{
  return [NSString stringWithFormat:@"INSERT INTO %@ VALUES (:timestamp, :data)", __id];
}

- (NSString *)sqlForFetchOperation
{
  return [NSString stringWithFormat:@"SELECT * FROM %@", __id];
}

- (NSString *)sqlForCheckingIfOperationExists
{
  return [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE timestamp = ?", __id];
}

- (NSString *)sqlForDeletingOperationWithTimestamp
{
  return [NSString stringWithFormat:@"DELETE FROM %@ WHERE timestamp = ?", __id];
}

- (NSString *)sqlForDeletingAllOperations
{
  return [NSString stringWithFormat:@"DELETE FROM %@", __id];
}

- (NSString *)JSONStringFromDictionary:(NSDictionary *)dictionary
{
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                     options:0
                                                       error:&error];
  
  if(!jsonData) {
    return @"{}";
  } else {
    return [[NSString alloc] initWithData:jsonData
                                 encoding:NSUTF8StringEncoding];
  }
}

@end
