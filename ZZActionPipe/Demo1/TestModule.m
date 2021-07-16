//
//  Testmodule.m
//  JDSHActionPipeDemo
//
//  Created by 曾智 on 2021/6/22.
//  Copyright © 2021 曾智. All rights reserved.
//

#import "TestModule.h"
#import "ViewController.h"
#import "ViewModel.h"
#import "NewCollectionViewCell.h"
#import "NewCollectionViewCell2.h"
#import "ZZActionPipe.h"
#import "MTA.h"

@implementation Testmodule

+ (UIViewController *)viewController {
    ViewController *vc = [ViewController new];
    ZZActionPipe *vmPipe = [ViewModel pipe];
    ZZActionPipe *cellPipe = [ZZActionPipe bundlePipes:@[[NewCollectionViewCell pipe], [NewCollectionViewCell2 pipe]]];
    ZZActionPipe *mtaPipe = [MTA pipe];
    
    [[[vmPipe addPipe:vc.pipe] addPipe:cellPipe] addPipe:mtaPipe];
    [vmPipe retainPipeBy:vc];
    return vc;
}

@end
