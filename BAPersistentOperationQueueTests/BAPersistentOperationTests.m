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
  
  beforeEach(^{
    operation = [[BAPersistentOperation alloc] initWithTimestamp:200
                                                         andData:@{@"foo": @"bar"}];
    operation.delegate = mockDelegate;
  });

  describe(@"#initWithTimestamp:andData:", ^{
    
    it(@"sets #timestamp", ^{
      [[theValue(operation.timestamp) should] equal:theValue(200)];
    });
    
    context(@"when timestamp is nil", ^{
      __block double timestamp;
      beforeEach(^{
        timestamp = (double)[[NSDate date] timeIntervalSince1970];
        id dateMock = [NSDate mock];
        
        [NSDate stub:@selector(date) andReturn:dateMock];
        [dateMock stub:@selector(timeIntervalSince1970) andReturn:theValue(timestamp)];
        
        operation = [[BAPersistentOperation alloc] initWithTimestamp:0
                                                             andData:@{@"foo": @"bar"}];
      });
      
      it(@"uses the current timestamp", ^{
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
  
  describe(@"#start", ^{    
    it(@"calls persistentOperationStarted: on its delegate", ^{
      [[mockDelegate shouldEventually] receive:@selector(persistentOperationStarted:)
                                 withArguments:operation];
      [operation start];
    });
  });

  describe(@"#finish", ^{
    it(@"Calls the persistentOperation: delegate method", ^{
      [[mockDelegate shouldEventually] receive:@selector(persistentOperationFinished:)
                                 withArguments:operation];
      
      [operation start];
      [operation finish];
    });
  });
});

SPEC_END
