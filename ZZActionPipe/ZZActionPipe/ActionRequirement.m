//
//  ActionRequirement.m
//  JDSHActionPipeDemo
//
//  Created by 曾智 on 2021/6/16.
//  Copyright © 2021 曾智. All rights reserved.
//

#import "ActionRequirement+private.h"
#import "ZZActionPipe+private.h"

@interface ActionRequirement () {
    @private
    __weak ZZActionPipe *_pipe;
    SEL _selector;
    Class _returnClass;
    NSMutableDictionary *_muDicParamsClass;
    NSMutableDictionary *_muDicParamNotNull;
    NSInteger _state;
    BOOL _returnNotNull;
    BOOL _upReturnToBeTarget;
}

@end

@implementation ActionRequirement

- (instancetype)init {
    self = [super init];
    if (self) {
        _returnNotNull = NO;
        _state = zzRequirementStateDefault;
        _returnClass = nil;
    }
    return self;
}

- (BOOL)registedSelectorMatch:(SEL)aSelector {
    NSString *strSelectorForm = NSStringFromSelector(aSelector);
    NSString *strSelectorRetain = NSStringFromSelector(_selector);
    if ([strSelectorForm isEqualToString:strSelectorRetain]) {
        return YES;
    }
    return NO;
}

- (ActionRequirement * _Nonnull (^)(NSInteger))state {
    return ^(NSInteger state){
        self->_state = state;
        return self;
    };
}

- (ActionRequirement * _Nonnull (^)(Class  _Nonnull __unsafe_unretained))returnKindOf {
    return ^(Class returnClass){
        self->_returnClass = returnClass;
        self->_returnNotNull = YES;
        return self;
    };
}

- (ActionRequirement * _Nonnull (^)(NSInteger, Class  _Nonnull __unsafe_unretained))paramKindOf {
    if (!_muDicParamsClass) {
        _muDicParamsClass = [NSMutableDictionary new];
    }
    return ^(NSInteger index, Class  _Nonnull __unsafe_unretained paramClass){
        [self->_muDicParamsClass setObject:paramClass forKey:@(index)];
        self.paramNotNull(index);
        return self;
    };
}

- (ActionRequirement*(^)(void))returnNotNull {
    return ^{
        self->_returnNotNull = YES;
        return self;
    };
}
- (ActionRequirement*(^)(NSInteger))paramNotNull {
    if (!_muDicParamNotNull) {
        _muDicParamNotNull = [NSMutableDictionary new];
    }
    return ^(NSInteger index){
        [self->_muDicParamNotNull setObject:@(YES) forKey:@(index)];
        return self;
    };
}

@end

@implementation ActionRequirement (Block)

- (void)setAction:(id)actionBlock {
    _upReturnToBeTarget = NO;
    BlockActionRequirement *newRequirement = [[BlockActionRequirement alloc]initWith:self];
    newRequirement.action = actionBlock;
}

- (id)action {
    return nil;
}

@end

@implementation ActionRequirement (Class)

- (id)delegate {return nil;}
- (void)setDelegate:(id)delegate {
    ClassActionRequirement *newRequirement = [[ClassActionRequirement alloc]initWith:self];
    newRequirement.delegate = delegate;
}

- (id)strongDelegate{return nil;}
- (void)setStrongDelegate:(id)strongDelegate {
    ClassActionRequirement *newRequirement = [[ClassActionRequirement alloc]initWith:self];
    newRequirement.strongDelegate = strongDelegate;
}

- (ActionRequirement*(^)(void))upReturnToBeTarget {
    return ^{
        self->_upReturnToBeTarget = YES;
        return self;
    };
}

@end

@implementation ActionRequirement (requirementPrivate)

- (instancetype)initWith:(ActionRequirement *)requirement {
    self = [super init];
    if (self) {
        _pipe = requirement->_pipe;
        _selector = requirement->_selector;
        _returnClass = requirement->_returnClass;
        _muDicParamsClass = [requirement->_muDicParamsClass mutableCopy];
        _muDicParamNotNull = [requirement->_muDicParamNotNull mutableCopy];
        _returnNotNull = requirement->_returnNotNull;
        _state = requirement->_state;
        _upReturnToBeTarget = requirement->_upReturnToBeTarget;
    }
    return self;
}

- (NSInteger)getState {
    return _state;
}

- (BOOL)isReturnNotNull {
    return _returnNotNull;
}

- (Class)returnClass {
    return _returnClass;
}

- (NSDictionary *)notNullParams {
    return [_muDicParamNotNull copy];
}

- (NSDictionary *)dicParamKindOf {
    return [_muDicParamsClass copy];
}

- (ZZActionPipe *)pipe {
    return _pipe;
}

- (void)setPipe:(ZZActionPipe *)pipe {
    _pipe = pipe;
}

- (SEL)selector {
    return _selector;
}

- (void)setSelector:(SEL)selector {
    _selector = selector;
}

- (BOOL)isUpReturnToBeTarget {
    return self->_upReturnToBeTarget;
}
@end

@implementation BlockActionRequirement
- (void)setAction:(id)actionBlock {
    
    Class nsBlock = NSClassFromString(@"NSBlock");
    NSAssert([actionBlock isKindOfClass:nsBlock], @"Action should be a block. If you want to use an object as target, set instance to delegate.");
    
    if (self.pipe && self.selector && actionBlock) {
        [self.pipe registActionSelector:self.selector block:actionBlock requirement:self];
        _action = actionBlock;
    }
}

- (id)action {
    return _action;
}

- (void)setDelegate:(id)delegate {
    return;
}

- (void)setStrongDelegate:(id)strongDelegate {
    return;
}
@end

@implementation ClassActionRequirement

- (id)delegate {
    return _delegate;
}

- (void)setDelegate:(id)delegate {
    Class nsBlock = NSClassFromString(@"NSBlock");
    NSAssert(![delegate isKindOfClass:nsBlock], @"delegate should not be a block.");
    
    if (self.pipe && self.selector && delegate) {
        [self.pipe registActionSelector:self.selector block:delegate requirement:self];
        _delegate = delegate;
    }
}

- (id)strongDelegate{
    return _strongDelegate;
}

- (void)setStrongDelegate:(id)strongDelegate{
    Class nsBlock = NSClassFromString(@"NSBlock");
    NSAssert(![strongDelegate isKindOfClass:nsBlock], @"delegate should not be a block.");
    
    if (self.pipe && self.selector && strongDelegate) {
        [self.pipe registActionSelector:self.selector block:strongDelegate requirement:self];
        _strongDelegate = strongDelegate;
    }
}

- (void)setAction:(id)action {
    return;
}
@end
