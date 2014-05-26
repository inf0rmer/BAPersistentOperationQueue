//
//  BAPersistentOperationQueueTests.m
//  BAPersistentOperationQueue
//
//  Created by Bruno Abrantes on 21/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <ObjectiveSugar/ObjectiveSugar.h>
#import <FMDB/FMDatabaseQueue.h>
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseAdditions.h>
#import "BAPersistentOperationQueue.h"
#import "PersistentOperationQueueDelegate.h"

@interface BAPersistentOperationQueue ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

- (void)insertOperationInDatabase:(BAPersistentOperation *)operation;

@end

SPEC_BEGIN(BAPERSISTENTOPERATIONQUEUESPEC)

describe(@"BAPersistentOperationQueue", ^{
  
  __block BAPersistentOperationQueue *queue;
  __block PersistentOperationQueueDelegate *mockDelegate;
  __block NSString *databasePath = @"/tmp/tmp.db";
  
  beforeEach(^{
    queue = [[BAPersistentOperationQueue alloc] init];
    mockDelegate = [[PersistentOperationQueueDelegate alloc] init];
    queue.delegate = mockDelegate;
  });
  
  afterEach(^{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    [fm removeItemAtPath:databasePath error:&error];
  });
  
  context(@"When initializing", ^{
    it(@"instantiates an NSOperationQueue", ^{
      [[queue.operationQueue shouldNot] beNil];
      [[queue.operationQueue should] beKindOfClass:[NSOperationQueue class]];
    });
    
    it(@"ensures FIFO", ^{
      [[theValue(queue.operationQueue.maxConcurrentOperationCount) should] equal:theValue(1)];
    });
    
    it(@"begins in a suspended state", ^{
      [[theValue(queue.operationQueue.isSuspended) should] beTrue];
    });
    
    it(@"generates a unique ID", ^{
      [[theValue([queue._id containsString:@"BAPersistentOperationQueue_"]) should] beTrue];
    });
    
    describe(@"#initWithDatabasePath", ^{
      beforeEach(^{
        queue = [[BAPersistentOperationQueue alloc] initWithDatabasePath:databasePath];
      });
      
      it(@"creates a database at the specified path", ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        [[theValue([fm fileExistsAtPath:databasePath]) should] beTrue];
      });
    });
  });
  
  describe(@"#addObject", ^{
    __block BAPersistentOperationQueue *queue = nil;
    __block id dbMock = [FMDatabase nullMock];
    
    beforeEach(^{      
      id databaseQueueMock = [FMDatabaseQueue mock];
      
      [FMDatabaseQueue stub:@selector(databaseQueueWithPath:) andReturn:databaseQueueMock];
      
      [databaseQueueMock stub:@selector(inDatabase:) withBlock:^id(NSArray *params) {
        void (^block)(FMDatabase *db) = params[0];
        block(dbMock);
        
        return nil;
      }];
      
      [dbMock stub:@selector(executeUpdate:) andReturn:theValue(YES)];
      [dbMock stub:@selector(executeUpdate:withParameterDictionary:) andReturn:theValue(YES)];
      [dbMock stub:@selector(intForQuery:) andReturn:theValue(0)];
      [dbMock stub:@selector(open) andReturn:theValue(YES)];
      
      queue = [[BAPersistentOperationQueue alloc] initWithDatabasePath:databasePath];
      queue.delegate = mockDelegate;
    });
    
    it(@"serializes the object to a NSDictionary through a delegate method", ^{
      NSDictionary *object = @{};
      [[mockDelegate should] receive:@selector(persistentOperationQueueSerializeObject:)
                         withArguments:object];
      
      [queue addObject:object];
    });
    
    it(@"inserts the object in the database", ^{
      NSString *insertStatement = [NSString stringWithFormat:@"INSERT INTO %@ VALUES (:timestamp, :data)", queue._id];
      [[dbMock should] receive:@selector(executeUpdate:withParameterDictionary:) withArguments:insertStatement, any()];
      [queue addObject:@{}];
    });
    
    context(@"When the object is already in the database", ^{
      __block BAPersistentOperation *operation;
      
      beforeEach(^{
        operation = [[BAPersistentOperation alloc] initWithTimestamp:1000
                                                             andData:@{@"foo": @"bar"}];
        
        id databaseQueueMock = [FMDatabaseQueue mock];
        
        [FMDatabaseQueue stub:@selector(databaseQueueWithPath:) andReturn:databaseQueueMock];
        
        [databaseQueueMock stub:@selector(inDatabase:) withBlock:^id(NSArray *params) {
          void (^block)(FMDatabase *db) = params[0];
          block(dbMock);
          
          return nil;
        }];
        
        FMResultSet *resultSet = [[FMResultSet alloc] init];
        [resultSet stub:@selector(next) andReturn:theValue(NO)];
        
        [dbMock stub:@selector(executeUpdate:) andReturn:theValue(YES)];
        [dbMock stub:@selector(executeQuery:) andReturn:resultSet];
        
        queue = [[BAPersistentOperationQueue alloc] initWithDatabasePath:databasePath];
      });
      
      it(@"does not insert it to the database", ^{
        NSString *insertStatement = [NSString stringWithFormat:@"INSERT INTO %@ VALUES (:timestamp, :data)", queue._id];
        [[dbMock shouldNot] receive:@selector(executeUpdate:) withArguments:insertStatement];
        
        [queue insertOperationInDatabase:operation];
      });
    });
  });
  
  describe(@"#startWorking", ^{
    __block NSDictionary *data = @{@"foo": @"bar"};
    __block NSDictionary *data2 = @{@"foo2": @"bar2"};
    beforeEach(^{
      [queue addObject:data];
      [queue addObject:data2];
    });
    
    afterEach(^{
      [queue stopWorking];
      [queue.operationQueue cancelAllOperations];
    });
    
    it(@"sets #suspended to NO", ^{
      [queue startWorking];
      [[theValue(queue.suspended) shouldNot] beTrue];
    });
    
    it(@"invokes the #persistentOperationQueueReceivedOperation delegate method with the next operation in line", ^{
      __block NSDictionary *returnedData = nil;
      [mockDelegate stub:@selector(persistentOperationQueueReceivedOperation:) withBlock:^id(NSArray *params) {
        BAPersistentOperation *operation = [params firstObject];
        returnedData = operation.data;

        return nil;
      }];
      
      [queue startWorking];
      [[expectFutureValue(returnedData) shouldEventually] equal:data];
    });
    
    it(@"only starts working on the next operation when the previous one is finished", ^{
      __block NSDictionary *returnedData = nil;
      [mockDelegate stub:@selector(persistentOperationQueueReceivedOperation:) withBlock:^id(NSArray *params) {
        BAPersistentOperation *operation = [params firstObject];
        
        if (operation.data == data) {
          [operation finish];
        } else {
          returnedData = operation.data;
        }
        
        return nil;
      }];
      
      [queue startWorking];
      [[expectFutureValue(returnedData) shouldEventually] equal:data2];
    });
    
    it(@"tries loading from the database", ^{
      [[queue should] receive:@selector(loadOperationsFromDatabase)];
      [queue startWorking];
    });
  });
  
  describe(@"#stopWorking", ^{
    it(@"sets #suspended to YES", ^{
      [queue stopWorking];
      [[theValue(queue.suspended) should] beTrue];
    });
    
    it(@"suspends operation execution", ^{
      [queue stopWorking];
      [[theValue(queue.operationQueue.isSuspended) should] beTrue];
    });
  });
  
  describe(@"flush", ^{
    beforeEach(^{
      queue = [[BAPersistentOperationQueue alloc] init];
      [queue addObject:@{}];
      [queue addObject:@{}];
      [queue addObject:@{}];
      [queue addObject:@{}];
      [queue startWorking];
    });
    
    it(@"clears the queue", ^{
      [queue flush];
      [[expectFutureValue(theValue([queue.operations count])) shouldEventually] equal:theValue(0)];
    });
  });
  
  describe(@"#loadOperationsFromDatabase", ^{
    __block id dbMock = [FMDatabase nullMock];
    
    beforeEach(^{
      id databaseQueueMock = [FMDatabaseQueue mock];
      
      [FMDatabaseQueue stub:@selector(databaseQueueWithPath:) andReturn:databaseQueueMock];
      
      [databaseQueueMock stub:@selector(inDatabase:) withBlock:^id(NSArray *params) {
        void (^block)(FMDatabase *db) = params[0];
        block(dbMock);
        
        return nil;
      }];
      
      FMResultSet *resultSet = [[FMResultSet alloc] init];
      
      __block int fetchedCount = 0;
      [resultSet stub:@selector(intForColumn:) andReturn:theValue(1000)];
      [resultSet stub:@selector(stringForColumn:) andReturn:@"{\"foo\": \"someData\"}"];
      [resultSet stub:@selector(next) withBlock:^id(NSArray *params) {
        fetchedCount++;
        
        return theValue((fetchedCount <= 1));
      }];
      
      [dbMock stub:@selector(executeUpdate:) andReturn:theValue(YES)];
      [dbMock stub:@selector(executeQuery:) andReturn:resultSet];
      [dbMock stub:@selector(open) andReturn:theValue(YES)];
      
      queue = [[BAPersistentOperationQueue alloc] initWithDatabasePath:databasePath];
      [queue.operationQueue stub:@selector(operationCount) andReturn:theValue(1)];
    });
    
    it(@"Tries to load additional content from the database", ^{
      [[dbMock shouldEventually] receive:@selector(executeQuery:)
                 withArguments:[NSString stringWithFormat:@"SELECT * FROM %@", queue._id]];

      [queue loadOperationsFromDatabase];
    });
    
    it(@"Adds a retrieved operation from the DB to the queue", ^{
      KWCaptureSpy *spy = [queue.operationQueue captureArgument:@selector(addOperation:)
                                                        atIndex:0];
      
      [queue loadOperationsFromDatabase];
      
      BAPersistentOperation *operation = spy.argument;
      [[theValue(operation.timestamp) shouldEventually] equal:theValue(1000)];
      [[operation.data shouldEventually] equal:@{@"foo": @"someData"}];
    });
  });
  
  context(@"When queue is empty", ^{
    beforeEach(^{
      queue = [[BAPersistentOperationQueue alloc] initWithDatabasePath:databasePath];
      [queue.operationQueue stub:@selector(operationCount) andReturn:theValue(0)];
    });
    
    it(@"tries loading from the database", ^{
      [[queue shouldEventually] receive:@selector(loadOperationsFromDatabase)];
      
      [queue startWorking];
      [queue flush];
    });
  });
  
  context(@"When an operation finishes", ^{
    __block id dbMock = [FMDatabase nullMock];
    __block BAPersistentOperation *operation;
    beforeEach(^{
      id databaseQueueMock = [FMDatabaseQueue mock];
      
      [FMDatabaseQueue stub:@selector(databaseQueueWithPath:) andReturn:databaseQueueMock];
      
      [databaseQueueMock stub:@selector(inDatabase:) withBlock:^id(NSArray *params) {
        void (^block)(FMDatabase *db) = params[0];
        block(dbMock);
        
        return nil;
      }];
      
      [dbMock stub:@selector(executeUpdate:) andReturn:theValue(YES)];
      [dbMock stub:@selector(executeQuery:) andReturn:nil];
      
      queue = [[BAPersistentOperationQueue alloc] initWithDatabasePath:databasePath];
      
      operation = [[BAPersistentOperation alloc] initWithTimestamp:200 andData:@{}];
      [queue.operationQueue addOperation:operation];
    });
    
    it(@"tries deleting it from the database", ^{
      NSString *query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE timestamp = ?", queue._id];
      [[dbMock shouldEventually] receive:@selector(executeUpdate:) withArguments:query];
      [queue persistentOperationFinishedWithTimestamp:200];
    });
  });
});

SPEC_END
