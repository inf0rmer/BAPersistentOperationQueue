//
//  BAPersistentOperation.m
//  BAPersistentOperationQueue
//
//  Created by Bruno Abrantes on 21/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import "BAPersistentOperation.h"

@implementation BAPersistentOperation

- (instancetype)initWithTimestamp:(NSUInteger)timestamp
                          andData:(NSDictionary *)data
{
  if (self = [super init]) {
    _timestamp = timestamp;
    _data = data;
  }
  
  return self;
}

@end
