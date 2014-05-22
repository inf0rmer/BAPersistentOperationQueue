//
//  BAPersistentOperationQueue.h
//  BAPersistentOperationQueue
//
//  Created by Bruno Abrantes on 20/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BAPersistentOperation.h"

#pragma mark - Protocol
@protocol BAPersistentOperationQueueDelegate

@required - (NSDictionary *)persistentOperationQueueSerializeObject:(id)object;
@required - (void)persistentOperationQueueReceivedOperation:(BAPersistentOperation *)operation;

@end

@interface BAPersistentOperationQueue : NSObject <BAPersistentOperationDelegate>

@property (nonatomic, assign) BOOL suspended;
@property (nonatomic, weak) id <BAPersistentOperationQueueDelegate> delegate;

#pragma mark - Initialization
- (instancetype)init;

#pragma mark - Queue information
- (NSArray *)operations;

#pragma mark - Queue management
- (void)insertObject:(id)object;
- (void)startWorking;
- (void)stopWorking;
- (void)flush;

@end
