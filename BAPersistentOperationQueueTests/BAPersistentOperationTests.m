//
//  BAPersistentOperationTests.m
//  BAPersistentOperationQueue
//
//  Created by Bruno Abrantes on 22/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "BAPersistentOperation.h"

SPEC_BEGIN(BAPERSISTENTOPERATIONSPEC)

describe(@"BAPersistentOperation", ^{
  describe(@"#initWithTimestamp:andData:", ^{
    __block BAPersistentOperation *operation;
    
    beforeEach(^{
      operation = [[BAPersistentOperation alloc] initWithTimestamp:200
                                                           andData:@{@"foo": @"bar"}];
    });
    
    it(@"sets #timestamp", ^{
      [[theValue(operation.timestamp) should] equal:theValue(200)];
    });
    
    it(@"sets #data", ^{
      [[operation.data should] equal:@{@"foo": @"bar"}];
    });
    
    it(@"sets #finished", ^{
      [[theValue(operation.finished) shouldNot] beTrue];
    });
  });
});

SPEC_END
