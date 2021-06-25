//
//  ZZActionPipe.h
//
//  Created by 曾智 on 2020/5/25.
//

#import <Foundation/Foundation.h>
#import "JDTuple.h"
#import "ActionRequirement.h"
#import "ActionProcess.h"

static const NSInteger zzRequirementStateDefault = -90071;

typedef NS_OPTIONS(NSInteger, JDPipeActionState) {
    k_action_start = 1 << 0,
    k_action_process = 1 << 1,
    k_action_success = 1 << 2,
    k_action_error = 1 << 3,
    k_action_end = 1 << 4
};

#define pipe_createAction(...) ^(SEL selector, ##__VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

@interface ZZActionPipe<T> : NSProxy

+ (instancetype)new;
+ (instancetype)pipe;
+ (ZZActionPipe *)bundlePipes:(NSArray<ZZActionPipe *> *)arrPipes;
+ (T)getRootPipe;

- (ActionRequirement*(^)(SEL))registAction;
- (ZZActionPipe *)addPipe:(ZZActionPipe *)pipe;

- (T(^)(NSInteger))doWithState;
- (T(^)(void))doDirectly;

- (void)retainPipeBy:(id)objc;

- (T(^)(JDTuple *))exTuple;
@end

@interface ZZActionPipe (Class)

- (void)registProtocol:(NSArray<Protocol *> *)protocols delegate:(id)delegate actionRequired:(void(^)(SEL selector, ActionRequirement *requirement))block;
- (void)registProtocol:(NSArray<Protocol *> *)protocols strongDelegate:(id)delegate actionRequired:(void(^)(SEL selector, ActionRequirement *requirement))block;

@end

NS_ASSUME_NONNULL_END
