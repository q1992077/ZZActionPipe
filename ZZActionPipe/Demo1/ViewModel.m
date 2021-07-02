//
//  ViewModel.m
//  ZZActionPipeDemo
//
//  Created by 曾智 on 2020/6/18.
//  Copyright © 2020 曾智. All rights reserved.
//

#import "ViewModel.h"
#import "ZZActionPipe.h"
#import "dataModel.h"
#import "ActionProtocol.h"

@interface ViewModel ()

@property (nonatomic, strong) listModel *model;

@end

@implementation ViewModel

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)registAction:(ZZActionPipe *)pipe {
    
    pipe.registAction(@selector(loadData)).state(k_action_start).action = pipe_createAction(){
        ZZActionPipe<PipeActionProtocol> *pipe = [ZZActionPipe<PipeActionProtocol> getRootPipe];
        
        //模拟网络请求
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.model = [listModel new];
            dataModel *model1 = [dataModel new];
            dataModel *model2 = [dataModel new];
            dataModel *model3 = [dataModel new];
            dataModel *model4 = [dataModel new];
            dataModel *model5 = [dataModel new];
            model1.name = @"Jimmy";
            model1.age = @"14";
            model1.sex = 1;
            
            model2.name = @"Jenny";
            model2.age = @"49";
            model2.sex = 2;
            
            model3.name = @"Angle";
            model3.age = @"3";
            model3.sex = 1;
            
            model4.name = @"Cloud";
            model4.age = @"17";
            model4.sex = 1;
            
            model5.name = @"Rose";
            model5.age = @"17";
            model5.sex = 2;
            
            self.model.list = @[model1, model2, model3, model4, model5];
            [pipe.doWithState(k_action_success) loadData];
        });
    };
  
    pipe.registAction(@selector(collectionView:cellForItemAtIndexPath:)).action = pipe_createAction(UICollectionView *collectionView, NSIndexPath *indexPath) {
        ActionProcess *process = ActionProcess.getCurrentActionProcess;
        if (indexPath.row < self.model.list.count) {
            NSInteger cellKey = 0;
            if (indexPath.row % 2 == 0) {
                cellKey = 100;
            }else {
                cellKey = 200;
            }
            NSString *title = self.model.list[indexPath.row].name;
            NSString *sex = self.model.list[indexPath.row].sex == 1 ? @"男" : @"女";
            NSString *subTitle = [NSString stringWithFormat:@"%@ _ %@ _ click _ %ld", self.model.list[indexPath.row].age, sex, self.model.list[indexPath.row].clickTimes];
            process.tmpTuple = jd_tuple(cellKey, title, subTitle);
        }
        
        return [process.getUpStramReturnValue nonretainedObjectValue];
    };
    
    pipe.registAction(@selector(collectionView:numberOfItemsInSection:)).action = pipe_createAction(UICollectionView *collectionView, NSInteger section) {
        return self.model.list.count;
    };
    
    pipe.registAction(@selector(collectionView:layout:sizeForItemAtIndexPath:)).action = pipe_createAction(UICollectionView *collectionView, UICollectionViewLayout*collectionViewLayout, NSIndexPath *indexPath){
        NSInteger cellKey = 0;
        if (indexPath.row % 2 == 0) {
            cellKey = 100;
        }else {
            cellKey = 200;
        }
        
        ActionProcess *process = [ActionProcess getCurrentActionProcess];
        process.tmpTuple = jd_tuple(cellKey);
        return CGSizeZero;
    };
    
    pipe.registAction(@selector(cellaction:)).action = pipe_createAction(NSInteger row) {
        if (row < self.model.list.count) {
            self.model.list[row].clickTimes += 1;
            
            ZZActionPipe<PipeActionProtocol> *rootPipe = [ZZActionPipe<PipeActionProtocol> getRootPipe];
            [rootPipe.doWithState(k_action_success) loadData];
        }
    };
}

+ (ZZActionPipe *)pipe {
    ZZActionPipe *pipe = [ZZActionPipe alloc];
    ViewModel *viewModel = [ViewModel new];
    [viewModel registAction:pipe];
    return pipe;
}

@end
