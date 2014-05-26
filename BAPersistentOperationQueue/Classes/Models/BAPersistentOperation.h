//
//  BAPersistentOperation.h
//  BAPersistentOperationQueue
//
//  Created by Bruno Abrantes on 21/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BAPersistentOperationDelegate

@required - (void)persistentOperationStartedWithTimestamp:(NSUInteger)timestamp;
@required - (void)persistentOperationFinishedWithTimestamp:(NSUInteger)timestamp;

@end

@interface BAPersistentOperation : NSOperation

@property (nonatomic, assign) NSUInteger timestamp;
@property (nonatomic, strong) NSDictionary *data;

@property (readwrite) BOOL isExecuting;
@property (readwrite) BOOL isFinished;

@property (nonatomic, weak) id <BAPersistentOperationDelegate> delegate;

#pragma mark - Initialization
- (instancetype)initWithTimestamp:(NSUInteger)timestamp
                          andData:(NSDictionary *)data;

#pragma mark - Control
- (void)finish;

@end
