//
//  ActionProtocol.h
//  ZZActionPipeDemo
//
//  Created by 曾智 on 2020/7/10.
//  Copyright © 2020 曾智. All rights reserved.
//


@protocol PipeActionProtocol

- (void)loadData;   //发起网络请求
- (void)cellaction:(NSInteger)row;     //cell点击

@end
