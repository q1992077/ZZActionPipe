//
//  ZZActionPipe.m
//
//  Created by 曾智 on 2020/5/25.
//

#import "ZZActionPipe+private.h"
#import <objc/message.h>
#import "ActionRequirement+private.h"
#import "ActionProcess+private.h"

//pipeAction
#define pipe_key_signiture          @"signiture"
#define pipe_key_signiture_char     @"signitureChar"
#define pipe_key_block              @"block"
#define pipe_key_identifier         @"identifier"
#define pipe_key_requrement         @"requrement"
#define pipe_key_isClass            @"isClass"

//将pipeAction缓存到NSSignature对象上
#define pipe_key_Methods            @"dicMethod"

//bundle block chain
#define pipe_key_bundleBlockChain   @"bundleBlockChain"

static NSString *_pipeBlockTargetType = @"@?0:";
static NSMutableDictionary<NSString*, NSValue*> *_dicBlockSignatures;

struct JDBlockLiteral {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct block_descriptor {
        unsigned long int reserved;    // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};

enum {
    JDBlockDescriptionFlagsHasCopyDispose = (1 << 25),
    JDBlockDescriptionFlagsHasCtor = (1 << 26), // helpers have C++ code
    JDBlockDescriptionFlagsIsGlobal = (1 << 28),
    JDBlockDescriptionFlagsHasStret = (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    JDBlockDescriptionFlagsHasSignature = (1 << 30)
};
typedef int JDBlockDescriptionFlags;

@interface ZZActionPipe ()

@property (nonatomic, strong) NSMutableDictionary *dicSelector;
@property (nonatomic, weak) ZZActionPipe *rootPipe;
@property (nonatomic, strong) ZZActionPipe *nextPipe;
@property (nonatomic, strong) NSMutableDictionary *pipeActions;

@property (nonatomic, strong) NSMutableDictionary *actionCache; //调用链缓存
@end

@implementation ZZActionPipe

+ (instancetype)alloc {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dicBlockSignatures = [NSMutableDictionary new];
    });
    
    ZZActionPipe *NewSelf = [super alloc];
    if (NewSelf) {
        NewSelf.rootPipe = NewSelf;
    }
    return  NewSelf;
}

+ (instancetype)new {
    id NewSelf = [[self class] alloc];
    return  NewSelf;
}

+ (instancetype)pipe {
    return [self new];
}

- (void)dealloc {
//    NSLog(@"ZZActionPipe dealloc _ %@", self);
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    
    ZZActionPipe *pipe = self.rootPipe;
    while (pipe) {
        if (pipe.dicSelector[NSStringFromSelector(aSelector)]) {
            return YES;
        }
        pipe = pipe.nextPipe;
    }
    
    return NO;
}


- (ActionRequirement*(^)(SEL))registAction {
    
    return ^(SEL selector){
        ActionRequirement *newRequirement = [ActionRequirement new];
        newRequirement.pipe = self;
        newRequirement.selector = selector;
        return newRequirement;
    };
}

- (BOOL)registActionSelector:(SEL)selector
                       block:(id)actionBlock
                 requirement:(ActionRequirement *)actionRequirement {
    NSString *strIdentifier = NSStringFromSelector(selector);
    if (strIdentifier && actionBlock) {
        return [self registActionIdentifier:strIdentifier selector:selector block:actionBlock requirement:actionRequirement];
    }else {
        return NO;
    }
}

- (BOOL)registActionIdentifier:(NSString *)strIdentifier
                      selector:(SEL)selector
                         block:(id)actionBlock
                   requirement:(ActionRequirement *)actionRequirement{
    if (!actionBlock) {
        return NO;
    }
    
    if (!actionRequirement) {
        actionRequirement = [ActionRequirement new];
    }
    
    if (!self.pipeActions) {
        self.pipeActions = [NSMutableDictionary new];
    }
    
    if (!self.dicSelector) {
        self.dicSelector = [NSMutableDictionary new];
    }
    
    NSMethodSignature *blockSignature = nil;
    Class nsBlock = NSClassFromString(@"NSBlock");
    if (![actionBlock isKindOfClass:nsBlock]) {
        blockSignature = [actionBlock methodSignatureForSelector:selector];
        if (!blockSignature) {
            return  NO;
        }
        
        NSPointerArray *pointerTarget = [NSPointerArray weakObjectsPointerArray];
        [pointerTarget addPointer:(__bridge void * _Nullable)(actionBlock)];
        [self.pipeActions setValue:@{
            pipe_key_signiture:blockSignature,
            pipe_key_block:pointerTarget,
            pipe_key_identifier:strIdentifier,
            pipe_key_requrement:actionRequirement,
        } forKey:strIdentifier];
        [self.dicSelector setObject:@YES forKey:strIdentifier];
        return YES;
    }
    struct JDBlockLiteral *blockRef = (__bridge struct JDBlockLiteral *)actionBlock;
    if (blockRef->flags & JDBlockDescriptionFlagsHasSignature) {
        void *signatureLocation = blockRef->descriptor;
        signatureLocation += sizeof(unsigned long int);
        signatureLocation += sizeof(unsigned long int);

        if (blockRef->flags & JDBlockDescriptionFlagsHasCopyDispose) {
            signatureLocation += sizeof(void(*)(void *dst, void *src));
            signatureLocation += sizeof(void (*)(void *src));
        }

        const char *signature = (*(const char **)signatureLocation);
        NSString *strSignature = [NSString stringWithCString:signature encoding:NSUTF8StringEncoding];
        if (_dicBlockSignatures[strSignature]) {
            const char *newSignature = _dicBlockSignatures[strSignature].pointerValue;
            blockSignature = [NSMethodSignature signatureWithObjCTypes:newSignature];
            if (!blockSignature) {
                return NO;
            }
        }else {
            NSRange rangOfTarget = [strSignature rangeOfString:_pipeBlockTargetType];
            if (rangOfTarget.location == NSNotFound) {
                NSAssert(rangOfTarget.location != NSNotFound, @"you mast use pipe_createAction() to create an action block.");
            }
            NSString *strReturn = [strSignature substringToIndex:rangOfTarget.location];
            NSString *strArgs = [strSignature substringFromIndex:rangOfTarget.location + rangOfTarget.length];
            NSString *newStrSignature = [NSString stringWithFormat:@"%@@8:%@", strReturn, strArgs];
            size_t charSize = strlen(newStrSignature.UTF8String);
            const char *newSignature = malloc(charSize * sizeof(char));
            memcpy((void *)newSignature, newStrSignature.UTF8String, charSize + 1);
            blockSignature = [NSMethodSignature signatureWithObjCTypes:newSignature];
            if (!blockSignature) {
                free((void *)newSignature);
                return NO;
            }else {
                _dicBlockSignatures[strSignature] = [NSValue valueWithPointer:newSignature];
            }
        }
    }else {
        return NO;
    }
    
    [self.pipeActions setValue:@{
        pipe_key_signiture:blockSignature,
        pipe_key_block:actionBlock,
        pipe_key_identifier:strIdentifier,
        pipe_key_requrement:actionRequirement
    } forKey:strIdentifier];
    [self.dicSelector setObject:@YES forKey:strIdentifier];
    return YES;
}

- (ZZActionPipe *)addPipe:(ZZActionPipe *)pipe {
    Class pipeClass = [pipe class];
    while (pipeClass != nil && pipeClass == [ZZTmpRootPipe class]) {
        pipe = pipe.nextPipe;
    }
    
    if ([self class] == [ZZTmpRootPipe class]) {
        self.nextPipe = pipe.rootPipe;
        self.rootPipe = pipe.rootPipe;
        return self;
    }
    
    self.nextPipe = pipe;
    pipe.rootPipe = self.rootPipe;
    return pipe;
}

- (id(^)(NSInteger))doWithState {
    return ^(NSInteger state){
        ZZTmpRootPipe *tmp = [ZZTmpRootPipe new];
        tmp.state = state;
        [tmp addPipe:self.rootPipe];
        return tmp;
    };
}

- (id(^)(void))doDirectly {
    return ^{
        ZZTmpRootPipe *tmp = [ZZTmpRootPipe new];
        tmp.isNotLimit = YES;
        [tmp addPipe:self.rootPipe];
        return tmp;
    };
}

- (id(^)(JDTuple *))exTuple {
    return ^(JDTuple *tuple){
        return self;
    };
}

+ (ZZActionPipe *)bundlePipes:(NSArray<ZZActionPipe *> *)arrPipes {
    NSMutableDictionary *dicActions = [NSMutableDictionary new];
    NSMutableDictionary *dicSelector = [NSMutableDictionary new];
    [arrPipes enumerateObjectsUsingBlock:^(ZZActionPipe * _Nonnull pipe, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([pipe class] == [ZZTmpRootPipe class]) {
            return ;
        }
        [pipe.pipeActions.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!dicActions[key]) {
                [dicActions setObject:pipe.pipeActions[key] forKey:key];
                [dicSelector setObject:@(YES) forKey:key];
            }else {
                //组合block
                id object = dicActions[key];
                id objectBundle = object;
                while (objectBundle) {
                    objectBundle = objc_getAssociatedObject(object, pipe_key_bundleBlockChain);
                    if (objectBundle) {
                        object = objectBundle;
                    }
                }
                id value = pipe.pipeActions[key];
                objc_setAssociatedObject(object, pipe_key_bundleBlockChain, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }];
    }];
    
    ZZActionPipe *newPipe = [ZZActionPipe new];
    newPipe.pipeActions = dicActions;
    newPipe.dicSelector = dicSelector;
    return newPipe;
}

+ (ZZActionPipe *)getRootPipe {
    ActionProcess *tmpProcess = NSThread.currentThread.threadDictionary[pipe_current_process];
    if (!tmpProcess) {
        return nil;
    }
    return tmpProcess.pipe;
}

- (NSDictionary *)findActionWithIdentifier:(NSString *)identifier {
    NSDictionary *dicMethod = self.pipeActions[identifier];
    if (dicMethod) {
        return dicMethod;
    }else {
        return [self.nextPipe findActionWithIdentifier:identifier];
    }
}


- (NSDictionary *)findActionWithSelector:(SEL)selector {
    NSString *strIdentifier = NSStringFromSelector(selector);
    if (strIdentifier) {
        return [self.rootPipe findActionWithIdentifier:strIdentifier];
    }else {
        return nil;
    }
}

- (NSArray *)getActionsWithIdentifier:(NSString *)strIdentifier {
    NSMutableArray *arrActions = [NSMutableArray new];
    ZZActionPipe *pipe = self.rootPipe;
    while (pipe) {
        NSDictionary *dicIdentifierAction = pipe.pipeActions[strIdentifier];
        if (dicIdentifierAction) {
            [arrActions addObject:dicIdentifierAction];
        }
        pipe = pipe.nextPipe;
    }
    
    return arrActions;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSDictionary *dicMethod = [self findActionWithSelector:aSelector];
    if (dicMethod) {
        NSMethodSignature *signature = dicMethod[pipe_key_signiture];
        objc_setAssociatedObject(signature, pipe_key_Methods, dicMethod, OBJC_ASSOCIATION_ASSIGN);
        return signature;
    }else {
        NSLog(@"methodSignatureForSelector error");
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];;
    }
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    //invocation 压栈
    NSInteger state = zzRequirementStateDefault;
    if([self class] == [ZZTmpRootPipe class]) {
        state = ((ZZTmpRootPipe *)self).state;
    }
    ActionProcess *tmpProcess = NSThread.currentThread.threadDictionary[pipe_current_process];
    ActionProcess *newProcess = [[ActionProcess alloc] initWith:state pipe:self.rootPipe invocation:anInvocation];
    [NSThread.currentThread.threadDictionary setObject:newProcess forKey:pipe_current_process];
    
    NSDictionary *dicMethod = objc_getAssociatedObject(anInvocation.methodSignature, pipe_key_Methods);
    if (!dicMethod) {
        return ;
    }
    
    //获取block chain
    NSArray *arrActionsFormCache = self.rootPipe.actionCache[dicMethod[pipe_key_identifier]];
    if (!arrActionsFormCache) {
        arrActionsFormCache = [self getActionsWithIdentifier:dicMethod[pipe_key_identifier]];
        ZZActionPipe *rootPipe = self.rootPipe;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [rootPipe.actionCache setObject:arrActionsFormCache forKey:dicMethod[pipe_key_identifier]];
        });
    }
    
    //是否携带状态
    BOOL hasState = NO;
    if ([self class] == [ZZTmpRootPipe class]) {
        hasState = ![(ZZTmpRootPipe *)self isNotLimit];
    }
    
    for (NSInteger i = 0; i < arrActionsFormCache.count; i++) {
        NSDictionary *dicMethod = arrActionsFormCache[i];
        id target = dicMethod;
        while (target) {
            if ([self goToNextDirectly:newProcess.currentInvocation checkState:hasState requirement:target[pipe_key_requrement]]) {
                target = objc_getAssociatedObject(target, pipe_key_bundleBlockChain);
                continue;
            }
            id __unsafe_unretained setTarget = target[pipe_key_block];
            Class nsBlock = NSClassFromString(@"NSBlock");
            if ([setTarget isKindOfClass:nsBlock]) {
                [newProcess.currentInvocation setTarget:setTarget];
            }else {
                if ([(ActionRequirement *)target[pipe_key_requrement] isUpReturnToBeTarget]) {
                    __unsafe_unretained id returnObjc;
                    [newProcess.currentInvocation getReturnValue:&returnObjc];
                    id strongObjc = returnObjc;
                    [newProcess.currentInvocation setTarget:strongObjc];
                }else {
                    NSPointerArray __unsafe_unretained *pointerArray = setTarget;
                    id objcTarget = [pointerArray pointerAtIndex:0];
                    [newProcess.currentInvocation setTarget:objcTarget];
                }
            }
            
            [newProcess.currentInvocation invoke];
            target = objc_getAssociatedObject(target, pipe_key_bundleBlockChain);
        }
        
    }
    
    //invocation 出栈
    if (tmpProcess) {
        [NSThread.currentThread.threadDictionary setObject:tmpProcess forKey:pipe_current_process];
    }else {
        [NSThread.currentThread.threadDictionary removeObjectForKey:pipe_current_process];
    }
    
}

- (BOOL)goToNextDirectly:(NSInvocation *)invocation checkState:(BOOL)bCheckState requirement:(ActionRequirement *)actionRequirement{
    if (actionRequirement && invocation) {
        if (bCheckState) {
            ZZTmpRootPipe __unsafe_unretained *tmp = (ZZTmpRootPipe *)self;
            //状态不相等 跳过
            if (tmp.state != zzRequirementStateDefault &&
                [actionRequirement getState] != zzRequirementStateDefault &&
                (tmp.state & [actionRequirement getState]) == 0) {
                return YES;
            }
        }
        
        //返回值不相等 跳过
        BOOL reurnTypeisObjc = ('@' == invocation.methodSignature.methodReturnType[0]);
        if (reurnTypeisObjc && [actionRequirement isReturnNotNull]) {
            id __unsafe_unretained returnObjc = nil;
            Class returnClass = [actionRequirement returnClass];
            [invocation getReturnValue:&returnObjc];
            if (returnObjc == nil) {
                return YES;
            }else if(returnClass && [returnObjc isKindOfClass:returnClass]) {
                return YES;
            }
        }
        
        
        //参数值不相等 跳过
        NSDictionary *notNullParams = [actionRequirement notNullParams];
        NSDictionary *dicParamKindOf = [actionRequirement dicParamKindOf];
        if (notNullParams && notNullParams.count > 0) {
            id __unsafe_unretained param = nil;
            NSNumber *key = nil;
            for (NSInteger i = 0; i < notNullParams.count; i++) {
                key = notNullParams.allKeys[i];
                [invocation getArgument:&param atIndex:[key intValue] + 1];
                if (!param) {
                    return YES;
                }else if(dicParamKindOf[key]){
                    Class paramClass = dicParamKindOf[key];
                    if (![param isKindOfClass:paramClass]) {
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

- (NSMutableDictionary *)actionCache {
    if (!_actionCache) {
        _actionCache = [NSMutableDictionary new];
    }
    return _actionCache;
}

- (void)retainPipeBy:(id)objc {
    objc_setAssociatedObject(objc, &objc, self, OBJC_ASSOCIATION_RETAIN);
}
@end

@implementation ZZActionPipe (Class)

- (void)registProtocol:(NSArray<Protocol *> *)protocols strongDelegate:(id)delegate actionRequired:(void(^)(SEL selector, ActionRequirement *requirement))block{
    [self registProtocol:protocols delegate:delegate isRetain:YES actionRequired:block];
}
- (void)registProtocol:(NSArray<Protocol *> *)protocols delegate:(id)delegate actionRequired:(void(^)(SEL selector, ActionRequirement *requirement))block{
    [self registProtocol:protocols delegate:delegate isRetain:NO actionRequired:block];
}

- (void)registProtocol:(NSArray<Protocol *> *)protocols delegate:(id)delegate isRetain:(BOOL)bRetain actionRequired:(void(^)(SEL selector, ActionRequirement *requirement))block{
    [protocols enumerateObjectsUsingBlock:^(Protocol * _Nonnull protocol, NSUInteger idx, BOOL * _Nonnull stop) {
        unsigned int count = 0;
        BOOL isRequiredMethod = YES;
        BOOL isInstanceMethod = YES;
        BOOL end = NO;
        while (!end) {
            struct objc_method_description *methodDescriptionList = protocol_copyMethodDescriptionList(protocol, isRequiredMethod, isInstanceMethod, &count);
            while (count > 0) {
                struct objc_method_description methodDes = methodDescriptionList[count - 1];
                if ([[delegate class] instancesRespondToSelector:methodDes.name]) {
                    ActionRequirement *requierment = self.registAction(methodDes.name);
                    if (block) {
                        block(methodDes.name, requierment);
                    }
                    if (bRetain) {
                        requierment.strongDelegate = delegate;
                    }else {
                        requierment.delegate = delegate;
                    }
                }
                count--;
            }
            
            if (isRequiredMethod) {
                isRequiredMethod = NO;
            }else if (isInstanceMethod) {
                isInstanceMethod = NO;
            }else {
                end = YES;
            }
            free(methodDescriptionList);
        }

    }];
}

@end

@implementation ZZTmpRootPipe
+ (instancetype)alloc {
    ZZTmpRootPipe *pipe = [super alloc];
    pipe.state = zzRequirementStateDefault;
    return pipe;
}

- (BOOL)registActionSelector:(SEL)selector
                       block:(id)actionBlock
                 requirement:(ActionRequirement * _Nullable)actionRequirement {
    return NO;
}

@end
