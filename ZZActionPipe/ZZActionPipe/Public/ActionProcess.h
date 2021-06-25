//
//  ActionProcess.h
//  JDSHActionPipeDemo
//
//  Created by 曾智 on 2021/6/16.
//  Copyright © 2021 曾智. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@class JDTuple;
@interface ActionProcess : NSObject

@property (nonatomic, strong) JDTuple *tmpTuple;

+ (ActionProcess *)getCurrentActionProcess;

- (NSInteger)state;
- (BOOL)changeArgumentOld:(void *_Nonnull)oldArg toNew:(JDTuple *)newArg;
- (__kindof NSValue*)getUpStramReturnValue;

@end

NS_ASSUME_NONNULL_END
