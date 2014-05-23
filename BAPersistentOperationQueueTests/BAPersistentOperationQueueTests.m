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
      
      afterEach(^{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error;
        [fm removeItemAtPath:databasePath error:&error];
      });
      
      it(@"creates a database at the specified path", ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        [[theValue([fm fileExistsAtPath:databasePath]) should] beTrue];
      });
    });
  });
  
  describe(@"#insertObject", ^{
    __block BAPersistentOperationQueue *queue = nil;
    __block id dbMock = [FMDatabase nullMock];
    
    beforeEach(^{
      queue = [[BAPersistentOperationQueue alloc] initWithDatabasePath:databasePath];
      queue.delegate = mockDelegate;
      
      [queue.databaseQueue stub:@selector(inDatabase:) withBlock:^id(NSArray *params) {
        void (^block)(FMDatabase *db) = params[0];
        block(dbMock);

        return nil;
      }];
    });
    
    it(@"serializes the object to a NSDictionary through a delegate method", ^{
      NSDictionary *object = @{};
      [[mockDelegate should] receive:@selector(persistentOperationQueueSerializeObject:)
                         withArguments:object];
      
      [queue insertObject:object];
    });
    
    it(@"inserts the object in the database", ^{
      NSString *insertStatement = [NSString stringWithFormat:@"INSERT INTO %@ VALUES (:timestamp, :data)", queue._id];
      [[dbMock should] receive:@selector(executeUpdate:) withArguments:insertStatement];
      [queue insertObject:@{}];
    });
  });
  
  describe(@"#startWorking", ^{
    __block NSDictionary *data = @{@"foo": @"bar"};
    __block NSDictionary *data2 = @{@"foo2": @"bar2"};
    beforeEach(^{
      [queue insertObject:data];
      [queue insertObject:data2];
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
          [operation setFinished:YES];
        } else {
          returnedData = operation.data;
        }
        
        return nil;
      }];
      
      [queue startWorking];
      [[expectFutureValue(returnedData) shouldEventually] equal:data2];
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
      [queue insertObject:@{}];
      [queue insertObject:@{}];
      [queue insertObject:@{}];
      [queue insertObject:@{}];
      [queue startWorking];
    });
    
    it(@"clears the queue", ^{
      [queue flush];
      [[expectFutureValue(theValue([queue.operations count])) shouldEventually] equal:theValue(0)];
    });
  });
});

SPEC_END
