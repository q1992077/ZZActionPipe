//
//  ViewMoel2.m
//  JDSHActionPipeDemo
//
//  Created by 曾智 on 2021/6/25.
//  Copyright © 2021 曾智. All rights reserved.
//

#import "ViewMoel2.h"
#import "ZZActionPipe.h"

@protocol pipeActionProtocol

- (void)filterLoginWithName:(NSString *)strName passWord:(NSString *)strPassWord faild:(BOOL)bFaild;
- (void)loginAction;

@end

@interface ViewMoel2 ()

//model
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *passWord;

@end

@implementation ViewMoel2

- (void)registerPipe:(ZZActionPipe *)vmPipe {
    vmPipe.registAction(@selector(filterLoginWithName:passWord:faild:)).action = pipe_createAction(NSString *strName, NSString *strPassWord, BOOL bFaild) {
        self.name = strName;
        self.passWord = strPassWord;
        ActionProcess *process = [ActionProcess getCurrentActionProcess];
        if ((strName && strName.length > 0) && (strPassWord && strPassWord.length > 6)) {
            NSLog(@"%@",strPassWord);
            [process changeArgumentOld:&bFaild toNew:jd_tuple(NO)];
        }
    };
    
    vmPipe.registAction(@selector(loginAction)).state(k_action_start).action = pipe_createAction(){
        
        ZZActionPipe<pipeActionProtocol> *rootPipe = [ZZActionPipe<pipeActionProtocol> getRootPipe];
        
        //模拟接口请求
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.passWord isEqualToString:@"00000000"]) {
                [rootPipe.doWithState(k_action_success) loginAction];
            }else {
                [rootPipe.doWithState(k_action_error) loginAction];
            }
        });
    };
}

+ (ZZActionPipe *)pipe {
    ZZActionPipe *pipe = [ZZActionPipe new];
    ViewMoel2 *vm = [ViewMoel2 new];
    [vm registerPipe:pipe];
    return pipe;
}

@end
