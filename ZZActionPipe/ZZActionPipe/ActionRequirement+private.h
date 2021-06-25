//
//  ActionRequirement+private.h
//  JDSHActionPipeDemo
//
//  Created by 曾智 on 2021/6/16.
//  Copyright © 2021 曾智. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionRequirement.h"

NS_ASSUME_NONNULL_BEGIN
@class ZZActionPipe;
@interface ActionRequirement (requirementPrivate)

- (instancetype)initWith:(ActionRequirement *)requirement;

@property (nonatomic, weak) ZZActionPipe *pipe;
@property (nonatomic, assign) SEL selector;

- (NSInteger)getState;
- (BOOL)isReturnNotNull;
- (BOOL)isUpReturnToBeTarget;
- (Class)returnClass;
- (NSDictionary *)notNullParams;
- (NSDictionary *)dicParamKindOf;

@end

@interface BlockActionRequirement : ActionRequirement {
    @private
    __strong id _action;
}

@end

@interface ClassActionRequirement : ActionRequirement {
    @private
    __strong id _strongDelegate;
    __weak id _delegate;
};

@end
NS_ASSUME_NONNULL_END
