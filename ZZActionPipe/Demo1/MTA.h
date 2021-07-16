//
//  MTA.h
//  ZZActionPipe
//
//  Created by 曾智 on 2021/7/15.
//

#import <Foundation/Foundation.h>
#import "ActionProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class ZZActionPipe;
@interface MTA : NSObject

+ (ZZActionPipe *)pipe;

@end

NS_ASSUME_NONNULL_END
