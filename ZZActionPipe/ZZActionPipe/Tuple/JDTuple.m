//
//  JDTuple.m
//
//  Created by 曾智 on 2020/6/9.
//

#import "JDTuple.h"
#import <objc/message.h>

__attribute__((overloadable)) id tmp_tuple_unpack_c(id tuple, const char *key, void(^block)(id)) {
    if (!tuple) {
        return nil;
    }
    NSNumber *value = tuple[[NSString stringWithUTF8String:key]];
    if (!value) {
        NSLog(@"JDTuple unpack params _ ” %@ ” _ non-existent", [NSString stringWithUTF8String:key]);
        return nil;
    }
    const char *objCType = value.objCType;
    if (objCType[0] != (@encode(id)[0])) {
        NSString *strObjCType = [NSString stringWithUTF8String:objCType];
        NSLog(@"JDTuple unpack params _ ” %@ ” _ type is not match. %@ != %@", [NSString stringWithUTF8String:key], strObjCType, [NSString stringWithUTF8String:@encode(id)]);
        return nil;
    }
    return [value nonretainedObjectValue];
}
#define jd_unpack_c_overloadable(octype) __attribute__((overloadable)) octype tmp_tuple_unpack_c(id tuple, const char *key, void(^block)(octype)) { \
    if (!tuple) {\
        octype *v = alloca(sizeof(octype));\
        return v[0];\
    }\
    NSNumber *value = tuple[[NSString stringWithUTF8String:key]];\
    if (!value) {\
        NSLog(@"JDTuple unpack params _ “ %@ ” _ non-existent", [NSString stringWithUTF8String:key]);\
        octype *v = alloca(sizeof(octype));\
        return v[0];\
    }\
    const char *objCType = value.objCType;\
    if (objCType[0] != (@encode(octype)[0])) {\
        NSString *strObjCType = [NSString stringWithUTF8String:objCType];\
        NSLog(@"JDTuple unpack params _ “ %@ ” _ type is not match. %@ != %@", [NSString stringWithUTF8String:key], strObjCType, [NSString stringWithUTF8String:@encode(octype)]);\
        octype *v = alloca(sizeof(octype));\
        return v[0];\
}\
    octype p;\
    [value getValue:&p];\
    return p;  \
}
jd_unpack_c_overloadable(int)
jd_unpack_c_overloadable(unsigned int)
jd_unpack_c_overloadable(long)
jd_unpack_c_overloadable(unsigned long)
jd_unpack_c_overloadable(long long)
jd_unpack_c_overloadable(unsigned long long)
jd_unpack_c_overloadable(float)
jd_unpack_c_overloadable(double)
jd_unpack_c_overloadable(short)
jd_unpack_c_overloadable(unsigned short)
//jd_unpack_c_overloadable(_Bool)
jd_unpack_c_overloadable(BOOL)
jd_unpack_c_overloadable(char)
jd_unpack_c_overloadable(unsigned char)
jd_unpack_c_overloadable(CGPoint)
jd_unpack_c_overloadable(CGRect)
jd_unpack_c_overloadable(CGSize)

struct JDBlockLiteral {
    void *isa;
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct block_descriptor {
        unsigned long int reserved;
        unsigned long int size;
        void (*copy_helper)(void *dst, void *src);
        void (*dispose_helper)(void *src);
        const char *signature;
    } *descriptor;
    // imported variables  ...
};

enum {
    JDBlockDescriptionFlagsHasCopyDispose = (1 << 25),
    JDBlockDescriptionFlagsHasCtor = (1 << 26),
    JDBlockDescriptionFlagsIsGlobal = (1 << 28),
    JDBlockDescriptionFlagsHasStret = (1 << 29),
    JDBlockDescriptionFlagsHasSignature = (1 << 30)
};


@interface JDTuple ()

@property (nonatomic, strong) NSMutableArray<__kindof NSValue *> *arrParams;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *dicKeys;
@property (nonatomic, assign) BOOL bLocked;

@property (nonatomic, strong) NSMutableString *paramsDescription;
@property (nonatomic, copy) NSArray *inputKeys;

@end

@implementation JDTuple

- (instancetype)init {
    self = [super init];
    self.arrParams = [NSMutableArray new];
    self.dicKeys = [NSMutableDictionary new];
    self.paramsDescription = [NSMutableString new];
    self.bLocked = NO;
    return self;
}

- (JDTuple *(^)(const char *OCType, ...))addArg {
    return ^(const char *OCType, ...) {
        if (self.bLocked) {
            return self;
        }
        
        NSInteger iIndex = 1;
        va_list valist;
        va_start(valist, OCType);
        while (iIndex != -1) {
            @autoreleasepool {
                if (iIndex % 2 == 0) {
                    OCType = va_arg(valist, const char*);
                    if (OCType == NULL || &OCType[0] == &jd_tuple_end[0]) {
                        iIndex = -1;
                    }else {
                        iIndex ++;
                    }
                    continue;
                }else {
                    iIndex ++;
                }
                
                NSValue *newValue = nil;
                if (strstr(OCType, "=#}") || strstr(OCType, "@?") || strcmp(OCType, @encode(id)) == 0 || strcmp(OCType, @encode(typeof(nil))) == 0) {
                    __unsafe_unretained id<NSObject> p = va_arg(valist, id);
                    newValue = [[NSValue alloc]initWithBytes:&p objCType:OCType];
                    if (p) {
                        objc_setAssociatedObject(newValue, @"TupleObjctClassValue", p, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        [self.paramsDescription insertString:[NSString stringWithFormat:@"%@ ;\n", p.description] atIndex:self.paramsDescription.length];
                    }else {
                        [self.paramsDescription insertString:[NSString stringWithFormat:@"nil ;\n"] atIndex:self.paramsDescription.length];
                    }
                }else if (strcmp(OCType, @encode(BOOL)) == 0) {
                    BOOL p = va_arg(valist, int);
                    newValue = [[NSValue alloc]initWithBytes:&p objCType:OCType];
                    [self.paramsDescription insertString:[NSString stringWithFormat:@"%@ ;\n", p?@"YES":@"NO"] atIndex:self.paramsDescription.length];
                }
                
#define tuple_va_arg_number(oc_type, arg_type, arg_func) else if (strcmp(OCType, @encode(oc_type)) == 0) {\
oc_type p = va_arg(valist, arg_type);\
newValue = [NSNumber numberWith##arg_func:p];\
[self.paramsDescription insertString:[NSString stringWithFormat:@"%@ ;\n", newValue.description] atIndex:self.paramsDescription.length];\
}
                tuple_va_arg_number(NSInteger, NSInteger, Integer)
                tuple_va_arg_number(NSUInteger, NSUInteger, UnsignedInteger)
                tuple_va_arg_number(CGFloat, double, Double)
                tuple_va_arg_number(int, int, Int)
                tuple_va_arg_number(long, long, Long)
                tuple_va_arg_number(long long, long long, LongLong)
                tuple_va_arg_number(unsigned long long, unsigned long long, UnsignedLongLong)
                tuple_va_arg_number(double, double, Double)
#define tuple_va_arg_struct(oc_type) else if (strcmp(OCType, @encode(oc_type)) == 0) {\
oc_type p = va_arg(valist, oc_type);\
newValue = [[NSValue alloc]initWithBytes:&p objCType:OCType];\
[self.paramsDescription insertString:[NSString stringWithFormat:@"%@ ;\n", newValue.description] atIndex:self.paramsDescription.length];\
}
                tuple_va_arg_struct(CGSize)
                tuple_va_arg_struct(CGRect)
                tuple_va_arg_struct(CGPoint)
                tuple_va_arg_struct(CGVector)
                if (newValue) {
                    [self.arrParams addObject:newValue];
                }else {
                    arg_ph v = (arg_ph){};
                    [self.arrParams addObject:[[NSValue alloc] initWithBytes:&v objCType:OCType]];
                }
            }
        }
        va_end(valist);
        return self;
    };
}

- (void)tupleInputKeys:(const char *)keys {
    NSString *inputKeys = [NSString stringWithUTF8String:keys];
    
    [[inputKeys componentsSeparatedByString:@","] enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];
        [self.dicKeys setObject:@(idx) forKey:key];
    }];
}

- (void)setUnpackStrict:(id)unpackStrict {
    [self setUnpack:unpackStrict];
}

- (void)setUnpack:(id)block {
    NSMethodSignature *methodSignature = nil;
    struct JDBlockLiteral *blockRef = (__bridge struct JDBlockLiteral *)block;
    if (blockRef->flags & JDBlockDescriptionFlagsHasSignature) {
        void *signatureLocation = blockRef->descriptor;
        signatureLocation += sizeof(unsigned long int);
        signatureLocation += sizeof(unsigned long int);
        
        if (blockRef->flags & JDBlockDescriptionFlagsHasCopyDispose) {
            signatureLocation += sizeof(void(*)(void *dst, void *src));
            signatureLocation += sizeof(void (*)(void *src));
        }
        
        const char *signature = (*(const char **)signatureLocation);
        methodSignature = [NSMethodSignature signatureWithObjCTypes:signature];
    }else {
        return ;
    }

    if (methodSignature) {
        NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [blockInvocation retainArguments];
        for (NSInteger idx = 0; idx < methodSignature.numberOfArguments - 1; idx++) {
            if (idx >= self.arrParams.count) {
                break;
            }
            NSValue *param = self.arrParams[idx];
            const char *objCType = param.objCType;
            const char *objCTypeInSignature = [methodSignature getArgumentTypeAtIndex:idx + 1];
            
            if (strstr(objCType, @encode(arg_ph)) || strstr(objCTypeInSignature, @encode(arg_ph))) {
                continue;
            }
            
            if (objCType[0] != objCTypeInSignature[0]) {
                NSString *strObjCType = [NSString stringWithUTF8String:objCType];
                NSString *strObjCTypeInSignature = [NSString stringWithUTF8String:objCTypeInSignature];
                NSLog(@"JDTuple unpack params _ %ld _ type is not match. %@ != %@", (long)idx, strObjCType, strObjCTypeInSignature);
                continue;
            }
                        
            
            if (strstr(objCType, "@?") || strstr(objCType, "=#}") || strcmp(objCType, @encode(id)) == 0) {
                __unsafe_unretained id p;
                [param getValue:&p];
                [blockInvocation setArgument:&p atIndex:idx + 1];
            }
#define setArgument(oc_type) else if (strcmp(objCType, @encode(oc_type)) == 0){\
oc_type p;\
[param getValue:&p];\
[blockInvocation setArgument:&p atIndex:idx + 1];\
}
            setArgument(BOOL)
            setArgument(NSInteger)
            setArgument(NSUInteger)
            setArgument(CGFloat)
            setArgument(CGSize)
            setArgument(CGRect)
            setArgument(CGPoint)
            setArgument(CGVector)
            setArgument(int)
            setArgument(long)
            setArgument(long long)
            setArgument(unsigned long long)
            setArgument(double)
        }
        
        [blockInvocation setTarget:block];
        [blockInvocation invoke];
    }
}

- (JDTuple *)lock {
    self.bLocked = YES;
    return self;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    if (idx < self.arrParams.count) {
        NSNumber *value = (NSNumber *)self.arrParams[idx];
        return value;
    }
    return nil;
}

- (id)objectForKeyedSubscript:(NSString *)key{
    if (key) {
        key = [key componentsSeparatedByString:@" "].lastObject;
        NSUInteger location = [key rangeOfString:@"*"].location;
        if (location != NSNotFound) {
            key = [key substringFromIndex:location + 1];
        }

        key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSNumber *keyToIndex = self.dicKeys[key];
        if (keyToIndex && self.arrParams.count > keyToIndex.unsignedLongValue) {
            NSNumber *value = (NSNumber *)self.arrParams[keyToIndex.unsignedLongValue];
            return value;
        }
    }
    return nil;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(NSString *key, id obj, BOOL *stop))block {
    
}

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block {
    
}

- (NSString *)description {
    NSMutableString *strDescription = [NSMutableString new];
    if (self.arrParams.count == 0) {
        [strDescription setString:@"no Argument yet."];
    }else {
        [strDescription insertString:@"JDTuple Argument Type: \n" atIndex:strDescription.length];
        [self.arrParams enumerateObjectsUsingBlock:^(NSValue * _Nonnull value, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *strOCType = [NSString stringWithUTF8String:value.objCType];
            if ([strOCType isEqualToString:@"@"]) {
                __unsafe_unretained id realValue = nil;
                [value getValue:&realValue];
                strOCType = NSStringFromClass([realValue class]);
            }else if ([strOCType isEqualToString:@"q"]) {
                strOCType = @"integer";
            }else if ([strOCType isEqualToString:@"f"]) {
                strOCType = @"float";
            }else if ([strOCType isEqualToString:@"d"]) {
                strOCType = @"double";
            }
            
            strOCType = [NSString stringWithFormat:@"arg type %ld : %@ \n", (long)idx, strOCType];
            [strDescription insertString:strOCType atIndex:strDescription.length];
        }];
    }
    
    [strDescription insertString:@"\nJDTuple Argument : \n" atIndex:strDescription.length];
    [strDescription insertString:self.paramsDescription atIndex:strDescription.length];
    
    return strDescription.copy;
}

- (NSString *)debugDescription {
    
    return [self description];
}
@end

#undef jd_unpack_c_overloadable
#undef tuple_va_arg_number
#undef tuple_va_arg_struct
#undef setArgument
