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

/**
 Delegate method that allows you to serialize your object and return an arbitrary data payload.
 It is invoked whenever an object is added to the queue.
 
 @param object The object to be serialized
 @return A dictionary with arbitrary data
 */
@required - (NSDictionary *)persistentOperationQueueSerializeObject:(id)object;

/**
 Delegate method that is called when an operation is started by the queue.
 This allows you to deserialize an operation back to your original object, and do things with it.
 
 @param operation The operation that was just started
 */
@required - (void)persistentOperationQueueStartedOperation:(BAPersistentOperation *)operation;

@end

@interface BAPersistentOperationQueue : NSObject <BAPersistentOperationDelegate>

/**
 Lets you know whether the queue is suspended. A suspended queue does not process any of its operations.
 */
@property (nonatomic, readonly) BOOL suspended;

/**
 The delegate for this queue.
 */
@property (nonatomic, weak) id <BAPersistentOperationQueueDelegate> delegate;

/**
 The unique identifier for this queue.
 */
@property (nonatomic, strong) NSString *_id;

#pragma mark - Initialization
/**-----------------------------------------------------------------------------
 * @name Initializing a BAPersistentOperationQueue
 * -----------------------------------------------------------------------------
 */

/**
 Initializes a queue with a database path
 
 @param path A path to your database file
 
 @return A BAPersistentOperationQueue instance
 
 @warning If no `path` is provided, the queue will only exist in memory.
 */
- (instancetype)initWithDatabasePath:(NSString *)path;

#pragma mark - Queue information
/**-----------------------------------------------------------------------------
 * @name Obtaining information about a queue
 * -----------------------------------------------------------------------------
 */

/**
 Returns the number of operations in the queue.
 
 @return An array of BAPersistentOperation instances
 */
- (NSArray *)operations;

#pragma mark - Queue management
/**-----------------------------------------------------------------------------
 * @name Managing the queue
 * -----------------------------------------------------------------------------
 */

/**
 Adds an object to the queue, calling the appropriate delegate methods.
 
 @param object The object to create an operation from
 */
- (void)addObject:(id)object;

/**
 Starts processing operations in the queue. This sets the queue's `suspended` variable to `NO`.
 */
- (void)startWorking;

/**
 Stops processing operations in the queue. This sets the queue's `suspended` variable to `YES`.
 */
- (void)stopWorking;

/**
 Cancels all operations in the queue.
 
 @warning This removes all operations from the queue and the database, thereby deleting them.
 */
- (void)flush;

#pragma mark - Database
/**-----------------------------------------------------------------------------
 * @name Accessing the database
 * -----------------------------------------------------------------------------
 */

/**
 Loads operations from the database, if a database path was set.
 */
- (void)loadOperationsFromDatabase;

@end
