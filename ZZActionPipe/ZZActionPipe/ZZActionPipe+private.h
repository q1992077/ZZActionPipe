//
//  ZZActionPipe+private.h
//  JDSHActionPipeDemo
//
//  Created by 曾智 on 2021/6/18.
//  Copyright © 2021 曾智. All rights reserved.
//
#import "ZZActionPipe.h"

@interface ZZActionPipe (pipePrivate)

- (BOOL)registActionSelector:(SEL _Nonnull )selector
                       block:(id _Nullable )actionBlock
                 requirement:(ActionRequirement * _Nullable)actionRequirement;
@end

@interface ZZTmpRootPipe : ZZActionPipe

@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) BOOL isNotLimit;
@end

