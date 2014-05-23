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
#import <KVOController/FBKVOController.h>

@interface BAPersistentOperationQueue ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

@end

static int cid = 0;

@implementation BAPersistentOperationQueue {
  FBKVOController *_KVOController;
}

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
    
    // Setup KVO
    [self setupKVO];
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
  
  [self loadOperationsFromDatabase];
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

#pragma mark - Database
- (void)insertOperationInDatabase:(BAPersistentOperation *)operation
{
  if (_databaseQueue == nil) {
    return;
  }
  
  [_databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *s = [db executeQuery:[self sqlForCheckingIfOperationExists], operation.timestamp];
    
    if ([s next]) {
      NSString *data = [self JSONStringFromDictionary:operation.data];
      NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:operation.timestamp], @"timestamp", data, @"data", nil];
      [db executeUpdate:[self sqlForInsertingOperation], args];
    }
  }];
}

- (void)loadOperationsFromDatabase
{
  if (_databaseQueue == nil) {
    return;
  }
  
  [_databaseQueue inDatabase:^(FMDatabase *db) {
    NSString *sql = [self sqlForFetchOperation];
    FMResultSet *results = [db executeQuery:sql];
    
    while ([results next]) {
      NSInteger timestamp = [results intForColumn:@"timestamp"];
      NSString *json = [results stringForColumn:@"data"];
      NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
      NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData
                                                           options:0
                                                             error:nil];
      
      BAPersistentOperation *operation = [[BAPersistentOperation alloc] initWithTimestamp:timestamp
                                                                                  andData:data];
      
      [_operationQueue addOperation:operation];
    }
  }];
}

#pragma mark - Helpers
- (void)setupKVO
{
  _KVOController = [FBKVOController controllerWithObserver:self];
  
  [_KVOController observe:_operationQueue keyPath:@"operations" options:NSKeyValueObservingOptionNew
                    block:^(id observer, id object, NSDictionary *change) {
                      if ([_operationQueue operationCount] == 0) {
                        [self loadOperationsFromDatabase];
                      }
                      
                      BAPersistentOperation *operation = (BAPersistentOperation *)[change[NSKeyValueChangeNewKey] firstObject];
                      
                      if (operation) {
                        [self insertOperationInDatabase:operation];
                      }
                    }];
}

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

- (NSString *)JSONStringFromDictionary:(NSDictionary *)dictionary
{
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                     options:0
                                                       error:&error];
  
  unless(jsonData) {
    return @"{}";
  } else {
    return [[NSString alloc] initWithData:jsonData
                                 encoding:NSUTF8StringEncoding];
  }
}

@end
