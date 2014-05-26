//
//  BARequest.h
//  BAPersistentOperationQueueExample
//
//  Created by Bruno Abrantes on 23/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BARequest;

@protocol BARequestDelegate <NSObject>

@optional - (void)BARequestDidFinish:(BARequest *)request;

@end

@interface BARequest : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL performing;
@property (nonatomic, weak) id <BARequestDelegate> delegate;

- (instancetype)initWithName:(NSString *)name;
- (void)perform;

@end
