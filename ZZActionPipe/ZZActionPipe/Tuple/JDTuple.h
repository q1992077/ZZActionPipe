//
//  JDTuple.h
//
//  Created by 曾智 on 2020/6/9.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JDTupleHelpe.h"

NS_ASSUME_NONNULL_BEGIN

/**
 定义tuple中的元素
 */
#define JD_TUPLE(...) JDTuple<NSValue *, void(^)(__VA_ARGS__)>*

/**
 tuple create   构造一个tuple
 JDTuple *tuple = jd_tuple(a,b,c,...);
 */
#define jd_tuple(...) \
        ___tuple(__VA_ARGS__)

/**
 tuple value 获取单个元素
 */
#define jd_tuple_value(tuple, ocType, index_or_key) \
        __jd_tuple_value(tuple, ocType, index_or_key)

/**
 tuple unpack 解构一个tuple  (根据入参顺序)
 jd_unpack(tuple)^(NSObject *a, NSInteger i, CGReact frame, ...){ };
 */
#define jd_unpack(tuple) tuple.unpack =
#define jd_unpack_strict(tuple) tuple.unpackStrict =

/**
tuple unpack 解构一个tuple，(根据key值)
 unpackWithkey(NSObject *name1, NSInteger name2, CGReact name3, ...) = tuple;
*/
#define jd_unpackWithkey(...) \
        __unpackWithkey(,__VA_ARGS__)

#define jd_unpackWithkeyMore(name, ...) \
        __unpackWithkey(name, __VA_ARGS__)
/**
 tuple argument placeholder
 */
typedef struct jd_tuple_argument_placeholder{
    int *i;
}arg_ph;
#define jd_arg_ph (arg_ph){}

@interface JDTuple<__contravariant objectType, deconstructType> : NSObject
@property (nonatomic, copy) id unpack;
@property (nonatomic, copy) deconstructType unpackStrict;

- (JDTuple *(^)(const char *OCType, ...))addArg;
- (void)tupleInputKeys:(const char *)keys;
- (JDTuple *)lock;

- (objectType)objectAtIndexedSubscript:(NSUInteger)idx;
- (objectType)objectForKeyedSubscript:(NSString *)key;
- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(NSString *key, objectType obj, BOOL *stop))block;
- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(objectType obj, NSUInteger idx, BOOL *stop))block;

@end

NS_ASSUME_NONNULL_END

