//
//  BAPersistentOperationTests.m
//  BAPersistentOperationQueue
//
//  Created by Bruno Abrantes on 22/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "BAPersistentOperation.h"
#import "PersistentOperationDelegate.h"

SPEC_BEGIN(BAPERSISTENTOPERATIONSPEC)

describe(@"BAPersistentOperation", ^{
  __block BAPersistentOperation *operation;
  __block PersistentOperationDelegate *mockDelegate = [[PersistentOperationDelegate alloc] init];

  describe(@"#initWithTimestamp:andData:", ^{
    beforeEach(^{
      operation = [[BAPersistentOperation alloc] initWithTimestamp:200
                                                           andData:@{@"foo": @"bar"}];
      operation.delegate = mockDelegate;
    });
    
    it(@"sets #timestamp", ^{
      [[theValue(operation.timestamp) should] equal:theValue(200)];
    });
    
    context(@"when timestamp is nil", ^{
      beforeEach(^{
        operation = [[BAPersistentOperation alloc] initWithTimestamp:(NSInteger)nil
                                                             andData:@{@"foo": @"bar"}];
      });
      
      it(@"uses the current timestamp", ^{
        NSInteger timestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
        [[theValue(operation.timestamp) should] equal:theValue(timestamp)];
      });
    });
    
    it(@"sets #data", ^{
      [[operation.data should] equal:@{@"foo": @"bar"}];
    });
    
    context(@"when data is nil", ^{
      beforeEach(^{
        operation = [[BAPersistentOperation alloc] initWithTimestamp:500
                                                             andData:nil];
      });
      
      it(@"sets an empty dictionary", ^{
        [[operation.data should] equal:@{}];
      });
    });
    
    it(@"sets #isFinished", ^{
      [[theValue(operation.isFinished) shouldNot] beTrue];
    });
    
    it(@"sets #isExecuting", ^{
      [[theValue(operation.isExecuting) shouldNot] beTrue];
    });
  });

  context(@"When an item finishes processing", ^{
    beforeEach(^{
      operation = [[BAPersistentOperation alloc] initWithTimestamp:200
                                                           andData:@{@"foo": @"bar"}];
      operation.delegate = mockDelegate;
    });
    
    it(@"Calls the persistentOperationFinishedWithTimestamp: delegate method", ^{
      [[mockDelegate shouldEventually] receive:@selector(persistentOperationFinishedWithTimestamp:)
                withArguments:theValue(operation.timestamp)];
      
      [operation start];
      [operation finish];
    });
  });
});

SPEC_END
