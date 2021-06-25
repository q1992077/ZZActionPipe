//
//  ActionProcess.m
//  JDSHActionPipeDemo
//
//  Created by 曾智 on 2021/6/16.
//  Copyright © 2021 曾智. All rights reserved.
//

#import "ActionProcess+private.h"
#import "ActionRequirement+private.h"
#import "ZZActionPipe+private.h"
#import "JDTuple.h"

@interface ActionProcess () {
    NSInteger _state;
    ZZActionPipe *_pipe;
    __strong NSInvocation *_currentInvocation;
}

@end

@implementation ActionProcess

+ (ActionProcess *)getCurrentActionProcess {
    ActionProcess *tmpProcess = NSThread.currentThread.threadDictionary[pipe_current_process];
    return tmpProcess;
}

- (NSInteger)state {
    return _state;
}

- (NSValue *)getUpStramReturnValue {
    JDTuple *tuple = nil;
    if (self.currentInvocation) {
        const char *returnType = self.currentInvocation.methodSignature.methodReturnType;
        const char *idType = @encode(id);
        if (returnType[0] == idType[0]) {
            __unsafe_unretained id returnObjc;
            [self.currentInvocation getReturnValue:&returnObjc];
            id upStramReturnValue = returnObjc;
            return jd_tuple(upStramReturnValue)[0];
        }
        #define else_if_upStramReturnValue(type) else if (strcmp(returnType, @encode(type)) == 0) {\
            type upStramReturnValue;\
            [self.currentInvocation getReturnValue:&upStramReturnValue];\
            tuple = jd_tuple(upStramReturnValue);\
        }
        else_if_upStramReturnValue(int)
        else_if_upStramReturnValue(unsigned int)
        else_if_upStramReturnValue(long)
        else_if_upStramReturnValue(unsigned long)
        else_if_upStramReturnValue(long long)
        else_if_upStramReturnValue(unsigned long long)
        else_if_upStramReturnValue(float)
        else_if_upStramReturnValue(double)
        else_if_upStramReturnValue(short)
        else_if_upStramReturnValue(unsigned short)
        else_if_upStramReturnValue(BOOL)
        else_if_upStramReturnValue(char)
        else_if_upStramReturnValue(unsigned char)
        else_if_upStramReturnValue(CGFloat)
        else_if_upStramReturnValue(CGPoint)
        else_if_upStramReturnValue(CGRect)
        else_if_upStramReturnValue(CGSize)
    }
    return tuple[0];
}

- (BOOL)changeArgumentOld:(void *)oldArg toNew:(JDTuple *)newArgTuple {
    if (self.currentInvocation) {
        for (NSInteger index = 1; index < self.currentInvocation.methodSignature.numberOfArguments; index++) {
            void *arg = &arg;
            void **oldArgPorint = oldArg;
            [self.currentInvocation getArgument:&arg atIndex:index];
            const char *argType = [self.currentInvocation.methodSignature getArgumentTypeAtIndex:index];
            if (*oldArgPorint == arg) {
                if (strstr(argType, @encode(id))) {
                     id newArg = [newArgTuple[0] nonretainedObjectValue];
                    [self.currentInvocation setArgument:&newArg atIndex:index];
                    [self.currentInvocation retainArguments];
                }else if (strstr(argType, @encode(BOOL))) {
                    BOOL newArg  = [newArgTuple[0] boolValue];
                    [self.currentInvocation setArgument:&newArg atIndex:index];
                }
                #define else_if_changeArgument(type, func)  else if (strstr(argType, @encode(type))) {\
                    type newArg = [newArgTuple[0] func];\
                    [self.currentInvocation setArgument:&newArg atIndex:index];\
                }
                else_if_changeArgument(int, intValue)
                else_if_changeArgument(unsigned int, unsignedIntValue)
                else_if_changeArgument(long, longValue)
                else_if_changeArgument(unsigned long, unsignedLongValue)
                else_if_changeArgument(long long, longLongValue)
                else_if_changeArgument(unsigned long long, unsignedLongLongValue)
                else_if_changeArgument(float, floatValue)
                else_if_changeArgument(double, doubleValue)
                else_if_changeArgument(short, shortValue)
                else_if_changeArgument(unsigned short, unsignedShortValue)
                else_if_changeArgument(char, charValue)
                else_if_changeArgument(unsigned char, unsignedCharValue)
                else_if_changeArgument(CGFloat, floatValue)
                else_if_changeArgument(CGPoint, CGPointValue)
                else_if_changeArgument(CGRect, CGRectValue)
                else_if_changeArgument(CGSize, CGSizeValue)
                break;
            }else if (strstr(argType, @encode(BOOL))) {
                BOOL boolOldPoint = *oldArgPorint;
                BOOL boolPoint = arg;
                if (boolOldPoint == boolPoint) {
                    BOOL newArg;
                    [newArgTuple[0] getValue:&newArg];
                    [self.currentInvocation setArgument:&newArg atIndex:index];
                }
            }
        }
    }
    return NO;
}
@end

@implementation ActionProcess (Processprivate)

- (instancetype)initWith:(NSInteger)state pipe:(ZZActionPipe *)pipe invocation:(NSInvocation *)invocation {
    self = [super init];
    if (self) {
        _state = state;
        _pipe = pipe;
        _currentInvocation = invocation;
    }
    return self;
}

- (NSInvocation *)currentInvocation {
    return _currentInvocation;
}

- (ZZActionPipe *)pipe {
    ZZTmpRootPipe *tmpPipe = [ZZTmpRootPipe pipe];
    [tmpPipe addPipe:_pipe];
    tmpPipe.state = zzRequirementStateDefault;
    return tmpPipe;
}
@end
