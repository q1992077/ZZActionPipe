//
//  dataModel.h
//  ZZActionPipeDemo
//
//  Created by 曾智 on 2020/7/10.
//  Copyright © 2020 曾智. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class dataModel;
@interface listModel : NSObject

@property (nonatomic, strong) NSArray<dataModel *> *list;

@end

@interface dataModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *age;
@property (nonatomic, assign) NSInteger sex;
@property (nonatomic, assign) NSInteger clickTimes;
@end

NS_ASSUME_NONNULL_END
