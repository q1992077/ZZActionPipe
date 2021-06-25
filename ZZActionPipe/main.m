//
//  main.m
//  ZZActionPipeDemo
//
//  Created by 曾智 on 2020/6/17.
//  Copyright © 2020 曾智. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ZZActionPipe.h"
#import "test1.h"
#import <mach/mach.h>
#include <sys/mman.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
//        @autoreleasepool {
//            [test1 test];
//        }
//        [[NSRunLoop currentRunLoop] run];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    return 0;
}
