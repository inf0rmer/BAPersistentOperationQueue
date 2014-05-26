//
//  BAPersistentOperation.h
//  BAPersistentOperationQueue
//
//  Created by Bruno Abrantes on 21/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BAPersistentOperation;
@protocol BAPersistentOperationDelegate

/**
 Delegate method that indicates an operation has started.
 
 @param operation the BAPersistentOperation instance
 */
@required - (void)persistentOperationStarted:(BAPersistentOperation *)operation;

/**
 Delegate method that indicates an operation has finished.
 
 @param operation the BAPersistentOperation instance
 */
@required - (void)persistentOperationFinished:(BAPersistentOperation *)operation;

@end

@interface BAPersistentOperation : NSOperation

/**
 The UNIX timestamp for the operation.
 @warning This needs to be unique.
 */
@property (nonatomic, assign) double timestamp;

/**
 The arbitrary serialized data to be stored in an operation.
 */
@property (nonatomic, strong) NSDictionary *data;

/**
 Lets you know whether the operation is currently running.
 */
@property (readwrite) BOOL isExecuting;

/**
 Lets you know if an operation is finished.
 */
@property (readwrite) BOOL isFinished;

/**
 The delegate for this operation.
 */
@property (nonatomic, weak) id <BAPersistentOperationDelegate> delegate;

#pragma mark - Initialization

/**-----------------------------------------------------------------------------
 * @name Initializing a BAPersistentOperation
 * -----------------------------------------------------------------------------
 */

/**
 Initializes an operation with a timestamp and data
 
 @param timestamp A unique UNIX timestamp
 @param data An arbitrary data payload
 
 @return A BAPersistentOperation instance
 
 @warning If no `timestamp` is provided, the current date will be used to calculate it.
 @warning If no `data` is provided, an empty NSDictionary will be used.
 */
- (instancetype)initWithTimestamp:(double)timestamp
                          andData:(NSDictionary *)data;

#pragma mark - Control
/**-----------------------------------------------------------------------------
 * @name Controlling the flow of a BAPersistentOperation
 * -----------------------------------------------------------------------------
 */

/**
 Finishes an operation, triggering the call of the appropriate delegate methods.
 */
- (void)finish;

/**
 Begins the execution of the operation, triggering the call of the appropriate delegate methods.
 */
- (void)start;

@end
