//
//  ActionRequirement.h
//  JDSHActionPipeDemo
//
//  Created by 曾智 on 2021/6/16.
//  Copyright © 2021 曾智. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ActionRequirement : NSObject

- (BOOL)registedSelectorMatch:(SEL)aSelector;
- (ActionRequirement*(^)(NSInteger state))state;

- (ActionRequirement*(^)(Class kindClass))returnKindOf;
- (ActionRequirement*(^)(NSInteger index, Class kindClass))paramKindOf;

- (ActionRequirement*(^)(void))returnNotNull;
- (ActionRequirement*(^)(NSInteger index))paramNotNull;

@end

@interface ActionRequirement (Block) //Use to block.

@property (nonatomic, copy)id action;

@end

@interface ActionRequirement (Class) //Use to instance object.

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) id strongDelegate;

- (ActionRequirement*(^)(void))upReturnToBeTarget;
@end
NS_ASSUME_NONNULL_END
