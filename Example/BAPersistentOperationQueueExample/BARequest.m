
//
//  BARequest.m
//  BAPersistentOperationQueueExample
//
//  Created by Bruno Abrantes on 23/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import "BARequest.h"

@implementation BARequest

- (instancetype)initWithName:(NSString *)name
{
  if (self = [super init]) {
    self.name = name;
  }
  
  return self;
}

- (void)performWithBlock:(void (^)())completionBlock
{
  self.performing = YES;
  
  // Simulating a network request
  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // Sleep for some time to simulate latency
    [NSThread sleepForTimeInterval:[self getRandomNumberBetween:1 maxNumber:5]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
      self.finished = YES;
      self.performing = NO;
      
      if (completionBlock) {
        completionBlock();
      }
      
      if ([self.delegate respondsToSelector:@selector(BARequestDidFinish:)]) {
        [self.delegate BARequestDidFinish:self];
      }
    });
  });
}

#pragma mark - Helpers
- (NSInteger)getRandomNumberBetween:(NSInteger)min
                          maxNumber:(NSInteger)max
{
  return min + arc4random() % (max - min + 1);
}

@end
