//
//  BAPersistentOperation.h
//  BAPersistentOperationQueue
//
//  Created by Bruno Abrantes on 21/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BAPersistentOperation : NSOperation

@property (nonatomic, assign) NSUInteger timestamp;
@property (nonatomic, strong) NSDictionary *data;

#pragma mark - Initialization
- (instancetype)initWithTimestamp:(NSUInteger)timestamp
                          andData:(NSDictionary *)data;

@end
