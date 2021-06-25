//
//  ActionProcess+private.h
//  JDSHActionPipeDemo
//
//  Created by 曾智 on 2021/6/18.
//  Copyright © 2021 曾智. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionProcess.h"

#define pipe_current_process        @"pipeCurrentProcess"

NS_ASSUME_NONNULL_BEGIN

@class ZZActionPipe;
@interface ActionProcess (Processprivate)

@property (nonatomic, readonly) ZZActionPipe *pipe;
@property (nonatomic, readonly) NSInvocation *currentInvocation;

- (instancetype)initWith:(NSInteger)state pipe:(ZZActionPipe *)pipe invocation:(NSInvocation *)invocation;
@end

NS_ASSUME_NONNULL_END
