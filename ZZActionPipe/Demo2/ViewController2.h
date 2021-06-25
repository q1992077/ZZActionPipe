//
//  ViewController2.h
//  JDSHActionPipeDemo
//
//  Created by 曾智 on 2021/6/25.
//  Copyright © 2021 曾智. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZZActionPipe;
@interface ViewController2 : UIViewController

@property (nonatomic, strong, readonly) ZZActionPipe *vcPipe;

@end

NS_ASSUME_NONNULL_END
