//
//  JDTupleHelpe.h
//  ZZActionPipeDemo
//
//  Created by 曾智 on 2020/9/24.
//  Copyright © 2020 曾智. All rights reserved.
//
#define tmp_tuple_unpack_c_extern(octype) extern octype __attribute__((overloadable)) tmp_tuple_unpack_c(id tuple, const char *key, void(^block)(octype));
tmp_tuple_unpack_c_extern(id)
tmp_tuple_unpack_c_extern(int)
tmp_tuple_unpack_c_extern(unsigned int)
tmp_tuple_unpack_c_extern(long)
tmp_tuple_unpack_c_extern(unsigned long)
tmp_tuple_unpack_c_extern(long long)
tmp_tuple_unpack_c_extern(unsigned long long)
tmp_tuple_unpack_c_extern(float)
tmp_tuple_unpack_c_extern(double)
tmp_tuple_unpack_c_extern(short)
tmp_tuple_unpack_c_extern(unsigned short)
tmp_tuple_unpack_c_extern(BOOL)
//tmp_tuple_unpack_c_extern(_Bool)
tmp_tuple_unpack_c_extern(char)
tmp_tuple_unpack_c_extern(unsigned char)
tmp_tuple_unpack_c_extern(CGPoint)
tmp_tuple_unpack_c_extern(CGRect)
tmp_tuple_unpack_c_extern(CGSize)

#define FL_INTERNAL_ARG_COUNT_PRIVATE(\
_0,  _1,  _2,  _3,  _4,  _5,  _6,  _7,  _8,  _9, \
_10, _11, _12, _13, _14, _15, _16, _17, _18, \
N, ...) N

#define  EXTAND_ARGS(args) args

static const char *jd_tuple_end = "JD_TUPLE_END";
#define jd_tuple_add_end jd_tuple_end
#define jd_tuple_add_1(param) @encode(typeof(param)), param, jd_tuple_add_end
#define jd_tuple_add_2(param, ...) @encode(typeof(param)), param,     jd_tuple_add_1(__VA_ARGS__)
#define jd_tuple_add_3(param, ...) @encode(typeof(param)), param,     jd_tuple_add_2(__VA_ARGS__)
#define jd_tuple_add_4(param, ...) @encode(typeof(param)), param,     jd_tuple_add_3(__VA_ARGS__)
#define jd_tuple_add_5(param, ...) @encode(typeof(param)), param,     jd_tuple_add_4(__VA_ARGS__)
#define jd_tuple_add_6(param, ...) @encode(typeof(param)), param,     jd_tuple_add_5(__VA_ARGS__)
#define jd_tuple_add_7(param, ...) @encode(typeof(param)), param,     jd_tuple_add_6(__VA_ARGS__)
#define jd_tuple_add_8(param, ...) @encode(typeof(param)), param,     jd_tuple_add_7(__VA_ARGS__)
#define jd_tuple_add_9(param, ...) @encode(typeof(param)), param,     jd_tuple_add_8(__VA_ARGS__)
#define jd_tuple_add_10(param, ...) @encode(typeof(param)), param,    jd_tuple_add_9(__VA_ARGS__)
#define jd_tuple_add_11(param, ...) @encode(typeof(param)), param,    jd_tuple_add_10(__VA_ARGS__)
#define jd_tuple_add_12(param, ...) @encode(typeof(param)), param,    jd_tuple_add_11(__VA_ARGS__)
#define jd_tuple_add_13(param, ...) @encode(typeof(param)), param,    jd_tuple_add_12(__VA_ARGS__)
#define jd_tuple_add_14(param, ...) @encode(typeof(param)), param,    jd_tuple_add_13(__VA_ARGS__)
#define jd_tuple_add_15(param, ...) @encode(typeof(param)), param,    jd_tuple_add_14(__VA_ARGS__)
#define jd_tuple_add_16(param, ...) @encode(typeof(param)), param,    jd_tuple_add_15(__VA_ARGS__)
#define jd_tuple_add_17(param, ...) @encode(typeof(param)), param,    jd_tuple_add_16(__VA_ARGS__)
#define jd_tuple_add_18(param, ...) @encode(typeof(param)), param,    jd_tuple_add_17(__VA_ARGS__)

#define jd_tuple_arg_count(...) EXTAND_ARGS(FL_INTERNAL_ARG_COUNT_PRIVATE(0, __VA_ARGS__,\
    jd_tuple_add_18,  jd_tuple_add_17,  jd_tuple_add_16,  jd_tuple_add_15,  jd_tuple_add_14,  jd_tuple_add_13,  jd_tuple_add_12,  jd_tuple_add_11,  jd_tuple_add_10,\
    jd_tuple_add_9,  jd_tuple_add_8,  jd_tuple_add_7,  jd_tuple_add_6,  jd_tuple_add_5,  jd_tuple_add_4,  jd_tuple_add_3,  jd_tuple_add_2,  jd_tuple_add_1,  0))

#define ___tuple_add(...) jd_tuple_arg_count(__VA_ARGS__)(__VA_ARGS__)

#define ___tuple(...) ({JDTuple *tuple = [JDTuple new]; [tuple tupleInputKeys:#__VA_ARGS__]; tuple.addArg(___tuple_add(__VA_ARGS__)); tuple.lock;})


#define help_tuple_unpack_set1(tuple, value) value = tmp_tuple_unpack_c(tuple, #value ,^(value){});
#define help_tuple_unpack_set2(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set1(tuple, __VA_ARGS__);
#define help_tuple_unpack_set3(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set2(tuple, __VA_ARGS__);
#define help_tuple_unpack_set4(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set3(tuple, __VA_ARGS__);
#define help_tuple_unpack_set5(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set4(tuple, __VA_ARGS__);
#define help_tuple_unpack_set6(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set5(tuple, __VA_ARGS__);
#define help_tuple_unpack_set7(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set6(tuple, __VA_ARGS__);
#define help_tuple_unpack_set8(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set7(tuple, __VA_ARGS__);
#define help_tuple_unpack_set9(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set8(tuple, __VA_ARGS__);
#define help_tuple_unpack_set10(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set9(tuple, __VA_ARGS__);
#define help_tuple_unpack_set11(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set10(tuple, __VA_ARGS__);
#define help_tuple_unpack_set12(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set11(tuple, __VA_ARGS__);
#define help_tuple_unpack_set13(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set12(tuple, __VA_ARGS__);
#define help_tuple_unpack_set14(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set13(tuple, __VA_ARGS__);
#define help_tuple_unpack_set15(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set14(tuple, __VA_ARGS__);
#define help_tuple_unpack_set16(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set15(tuple, __VA_ARGS__);
#define help_tuple_unpack_set17(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set16(tuple, __VA_ARGS__);
#define help_tuple_unpack_set18(tuple, value, ...) value = tmp_tuple_unpack_c(tuple, #value ,^(value){}); help_tuple_unpack_set17(tuple, __VA_ARGS__);
      
#define jd_tuple_arg_count_key(...) EXTAND_ARGS(FL_INTERNAL_ARG_COUNT_PRIVATE(0, __VA_ARGS__, help_tuple_unpack_set18, help_tuple_unpack_set17, help_tuple_unpack_set16, help_tuple_unpack_set15, help_tuple_unpack_set14, help_tuple_unpack_set13, help_tuple_unpack_set12, help_tuple_unpack_set11, help_tuple_unpack_set10, help_tuple_unpack_set9, help_tuple_unpack_set8, help_tuple_unpack_set7, help_tuple_unpack_set6, help_tuple_unpack_set5, help_tuple_unpack_set4, help_tuple_unpack_set3, help_tuple_unpack_set2, help_tuple_unpack_set1, 0))
        
#define __unpackWithkey(name, ...) \
            id tmp__tupleUnpack_##name = nil;\
JDTTupleUnpack_after_##name:;\
            jd_tuple_arg_count_key(__VA_ARGS__)(tmp__tupleUnpack_##name, __VA_ARGS__)\
            if (tmp__tupleUnpack_##name != nil)tmp__tupleUnpack_##name = @"";\
            while (![ tmp__tupleUnpack_##name isKindOfClass:[NSString class]])\
            if (tmp__tupleUnpack_##name) {if ([ tmp__tupleUnpack_##name isKindOfClass:[JDTuple class]]) {\
            goto JDTTupleUnpack_after_##name;}else {break;}}else if ( tmp__tupleUnpack_##name == nil) tmp__tupleUnpack_##name\


