//
//  ViewController.h
//  ZZActionPipeDemo
//
//  Created by 曾智 on 2020/6/17.
//  Copyright © 2020 曾智. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionProtocol.h"

@class ZZActionPipe;
@interface ViewController : UIViewController

@property (nonatomic, strong, readonly) ZZActionPipe<PipeActionProtocol> *pipe;

@end

