//
//  TestDemoModule.m
//  JDSHActionPipeDemo
//
//  Created by 曾智 on 2021/6/25.
//  Copyright © 2021 曾智. All rights reserved.
//

#import "TestDemoModule.h"
#import "ZZActionPipe.h"
#import "ViewController2.h"
#import "ViewMoel2.h"

@implementation TestDemoModule
+ (UIViewController *)viewController {
    
    ViewController2 *vc = [ViewController2 new];
    ZZActionPipe *vmPipe = [ViewMoel2 pipe];
    [vmPipe addPipe:vc.vcPipe];
    [vmPipe retainPipeBy:vc];
    return vc;
}
@end
