//
//  test1.m
//  ZZActionPipeDemo
//
//  Created by 曾智 on 2020/6/17.
//  Copyright © 2020 曾智. All rights reserved.
//

#import "test1.h"
#import "ZZActionPipe.h"
#import "JDTuple.h"
#import <UIKit/UIKit.h>

@protocol actionPipeProtocol <NSObject>

//- (CGFloat)someFuncWithNumber:(NSInteger)number object:(id)objc;

//- (void)someFunc2WithNumber:(CGSize)size object:(id)objc;
//- (void)someFunc3;

- (id)someFuncWithNumber:(NSInteger)number object:(id)objc;
@end

@interface testObject : NSObject
- (id)someFuncWithNumber:(NSInteger)number object:(id)objc;
@end

@implementation testObject

- (id)someFuncWithNumber:(NSInteger)number object:(id)objc {
    NSLog(@"%@ , %ld, %@", self, number, objc);
    return [NSObject new];
}
@end

@implementation test1

+ (void)test {
    
//    ZZActionPipe *pipe = [ZZActionPipe new];
//    pipe.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, id objc){
//        NSLog(@"number _ %ld , objc _ %@", number, objc);
//        return 100.0;
//    };
//
//    CGFloat fReturn = [(id<actionPipeProtocol>)pipe someFuncWithNumber:999 object:@[@1, @2, @3]];
//    NSLog(@"result _ %f", fReturn);
    
    
    
    
//    ZZActionPipe *pipe1 = [ZZActionPipe new];
//    ZZActionPipe *pipe2 = [ZZActionPipe new];
//    ZZActionPipe *pipe3 = [ZZActionPipe new];
//
//    pipe1.registAction(@selector(someFunc2WithNumber:object:)).action = pipe_createAction(CGSize size, id objc) {
//        NSLog(@"pipe1 _ called size: %f %f , %@", size.height, size.width, objc);
//    };
//
//    pipe2.registAction(@selector(someFunc2WithNumber:object:)).action = pipe_createAction(CGSize size, id objc) {
//        NSLog(@"pipe2 _ called size: %f %f , %@", size.height, size.width, objc);
//    };
//
//    pipe3.registAction(@selector(someFunc2WithNumber:object:)).action = pipe_createAction(CGSize size, id objc) {
//        NSLog(@"pipe3 _ called size: %f %f , %@", size.height, size.width, objc);
//    };
//
//    pipe2.registAction(@selector(someFunc3)).action = pipe_createAction() {
//        NSLog(@"someFunc3");
//    };
//
//    //pipe 组合 pipe1 -> pipe2 -> pipe3
//    [[pipe1 addPipe:pipe2] addPipe:pipe3];
//
//    [(id<actionPipeProtocol>)pipe3 someFunc2WithNumber:(CGSize){10,20} object:@"hello"];
//    [(id<actionPipeProtocol>)pipe1 someFunc3];
    
    
    
    
//    ZZActionPipe<actionPipeProtocol> *pipe1 = [ZZActionPipe<actionPipeProtocol> new];
//    pipe1.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, id objc) {
//        id returnObjc = nil;
//        if (objc == nil) {
//            NSLog(@"pipe1 _ return nil.");
//        }else if ([objc isKindOfClass:[NSArray class]]) {
//            returnObjc = [NSDate date];
//        }else {
//            returnObjc = [NSObject new];
//        }
//
//        return returnObjc;
//    };
//
//    ZZActionPipe<actionPipeProtocol> *pipe2 = [ZZActionPipe<actionPipeProtocol> new];
//    pipe2.registAction(@selector(someFuncWithNumber:object:))
//        .returnKindOf([[NSDate date] class])
//        .action = pipe_createAction(NSInteger number, id objc) {
//            NSLog(@"pipe2 _ up steam return NSDate.");
//            return nil;
//    };
//
//    ZZActionPipe<actionPipeProtocol> *pipe3 = [ZZActionPipe<actionPipeProtocol> new];
//    pipe3.registAction(@selector(someFuncWithNumber:object:))
//        .returnNotNull()
//        .action = pipe_createAction(NSInteger number, id objc) {
//            NSLog(@"pipe3 _ up steam return not Null.");
//            return nil;
//    };
//
//    [[pipe1 addPipe:pipe2] addPipe:pipe3];
//    [pipe3 someFuncWithNumber:0 object:nil];
//    [pipe2 someFuncWithNumber:0 object:@[@1,@2]];
//    [pipe1 someFuncWithNumber:0 object:@{@"a":@"aa"}];
    
    
    
//    ZZActionPipe<actionPipeProtocol> *pipe1 = [ZZActionPipe<actionPipeProtocol> new];
//    pipe1.registAction(@selector(someFuncWithNumber:object:)).paramKindOf(2, [NSArray class]).action = pipe_createAction(NSInteger number, id objc) {
//        id returnObjc = nil;
//        NSLog(@"pipe1 _ param objc is Array.");
//        return returnObjc;
//    };
//
//    [pipe1 someFuncWithNumber:0 object:@[@1, @2]];
    
    
    
    
//    ZZActionPipe<actionPipeProtocol> *pipe1 = [ZZActionPipe<actionPipeProtocol> new];
//    pipe1.registAction(@selector(someFuncWithNumber:object:)).state(1).action = pipe_createAction(NSInteger number, id objc) {
//        id returnObjc = nil;
//        NSLog(@"pipe1 _ state 1.");
//        return returnObjc;
//    };
//
//    ZZActionPipe<actionPipeProtocol> *pipe2 = [ZZActionPipe<actionPipeProtocol> new];
//    pipe2.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, id objc) {
//        id returnObjc = nil;
//        NSLog(@"pipe1 _ state 10.");
//        return returnObjc;
//    };
//
//    [pipe1 addPipe:pipe2];
//    [pipe1.doWithState(1) someFuncWithNumber:0 object:nil];
//    [pipe1.doWithState(10) someFuncWithNumber:0 object:nil];
//    [pipe1 someFuncWithNumber:0 object:nil];
    
    
    
//    ZZActionPipe<actionPipeProtocol> *pipe1 = [ZZActionPipe<actionPipeProtocol> pipe];
//    pipe1.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, id objc){
//        ActionProcess *process = [ActionProcess getCurrentActionProcess];
//
//        NSDate *date = [NSDate date];
//        NSString *str = [NSString stringWithFormat:@"Robot No.%ld birth day", number];
//        process.tmpTuple = jd_tuple(date, str);
//        return nil;
//    };
//
//    ZZActionPipe<actionPipeProtocol> *pipe2 = [ZZActionPipe<actionPipeProtocol> pipe];
//    pipe2.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, NSArray *arr){
//        ActionProcess *process = [ActionProcess getCurrentActionProcess];
//        JDTuple *tuple = process.tmpTuple;
//        __block id returnObjc = nil;
//        jd_unpack(tuple)^(NSDate *date, NSString *str) {
//            NSLog(@"%@ _ %@", str, date);
//            returnObjc = date;
//        };
//
//        return returnObjc;
//    };
//
//    [pipe1 addPipe:pipe2];
//    id fReturn = [pipe1 someFuncWithNumber:999 object:nil];
//    NSLog(@"result _ %@", fReturn);
    
    
    
    
//    ZZActionPipe<actionPipeProtocol> *pipe1 = [ZZActionPipe<actionPipeProtocol> pipe];
//    pipe1.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, id objc){
//        ActionProcess *process = [ActionProcess getCurrentActionProcess];
//        [process changeArgumentOld:&objc toNew:jd_tuple([NSDate date])];
//        return nil;
//    };
//
//    ZZActionPipe<actionPipeProtocol> *pipe2 = [ZZActionPipe<actionPipeProtocol> pipe];
//    pipe2.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, NSDate *date){
//        id returnObjc = nil;
//        if (date) {
//            returnObjc = date;
//            return returnObjc;
//        }
//        return returnObjc;
//    };
//
//    [pipe1 addPipe:pipe2];
//    id fReturn = [pipe1 someFuncWithNumber:999 object:nil];
//    NSLog(@"result _ %@", fReturn);
    
//    ZZActionPipe<actionPipeProtocol> *pipe1 = [ZZActionPipe<actionPipeProtocol> pipe];
//    pipe1.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, id objc){
//        return @[@1, @2, @3];
//    };
//
//    ZZActionPipe<actionPipeProtocol> *pipe2 = [ZZActionPipe<actionPipeProtocol> pipe];
//    pipe2.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, id objc){
//        ActionProcess *process = [ActionProcess getCurrentActionProcess];
//        id returnObjc = [[process getUpStramReturnValue] nonretainedObjectValue];
//        return returnObjc;
//    };
//
//    [pipe1 addPipe:pipe2];
//    id fReturn = [pipe1 someFuncWithNumber:999 object:nil];
//    NSLog(@"result _ %@", fReturn);

    
    
//    ZZActionPipe *pipe1 = [ZZActionPipe pipe];
//    testObject *delegate = [testObject new];
//    pipe1.registAction(@selector(someFuncWithNumber:object:)).delegate = delegate;
//    id fReturn = [(testObject *)pipe1 someFuncWithNumber:999 object:@"in instance object"];
//    NSLog(@"result _ %@", fReturn);
}

@end


