//
//  BAPersistentOperationQueueTests.m
//  BAPersistentOperationQueue
//
//  Created by Bruno Abrantes on 21/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "BAPersistentOperationQueue.h"
#import "PersistentOperationQueueDelegate.h"

SPEC_BEGIN(BAPERSISTENTOPERATIONQUEUESPEC)

describe(@"BAPersistentOperationQueue", ^{
  context(@"When initializing", ^{

    __block BAPersistentOperationQueue *queue;
    beforeEach(^{
      queue = [[BAPersistentOperationQueue alloc] init];
    });
    
    it(@"instantiates an NSOperationQueue", ^{
      [[queue.operationQueue shouldNot] beNil];
      [[queue.operationQueue should] beKindOfClass:[NSOperationQueue class]];
    });
    
    it(@"ensures FIFO", ^{
      [[theValue(queue.operationQueue.maxConcurrentOperationCount) should] equal:theValue(1)];
    });
  });
  
  describe(@"#insertObject", ^{
    __block BAPersistentOperationQueue *queue;
    __block PersistentOperationQueueDelegate *mockDelegate;
    beforeEach(^{
      queue = [[BAPersistentOperationQueue alloc] init];
      mockDelegate = [[PersistentOperationQueueDelegate alloc] init];
      queue.delegate = mockDelegate;
    });
    
    it(@"serializes the object to a NSDictionary through a delegate method", ^{
      NSDictionary *object = @{};
      [[mockDelegate should] receive:@selector(persistentOperationQueueSerializeObject:)
                         withArguments:object];
      
      [queue insertObject:object];
    });
  });
});

SPEC_END
