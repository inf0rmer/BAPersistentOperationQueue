//
//  PersistentOperationQueueDelegate.m
//  BAPersistentOperationQueue
//
//  Created by Bruno Abrantes on 21/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import "PersistentOperationQueueDelegate.h"

@implementation PersistentOperationQueueDelegate

#pragma mark - BAPersistentOperationQueueDelegate
- (NSDictionary *)persistentOperationQueueSerializeObject:(id)object
{
  object = (NSDictionary *)object;
  
  return object;
}

- (void)persistentOperationQueueReceivedOperation:(BAPersistentOperation *)operation
{

}

@end
