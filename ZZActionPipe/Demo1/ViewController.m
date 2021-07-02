//
//  ViewController.m
//  ZZActionPipeDemo
//
//  Created by 曾智 on 2020/6/17.
//  Copyright © 2020 曾智. All rights reserved.
//

#import "ViewController.h"
#import "ZZActionPipe.h"

@interface ViewController () {
    UICollectionView *_collectionView;
    ZZActionPipe<PipeActionProtocol> *_pipe;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _collectionView = [[UICollectionView alloc]initWithFrame:(CGRect){0,0, 400, 500} collectionViewLayout:[UICollectionViewFlowLayout new]];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:NSClassFromString(@"NewCollectionViewCell") forCellWithReuseIdentifier:@"NewCollectionViewCell"];
    [_collectionView registerClass:NSClassFromString(@"NewCollectionViewCell2") forCellWithReuseIdentifier:@"NewCollectionViewCell2"];
    _collectionView.delegate = (id<UICollectionViewDelegate>)self.pipe;
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self.pipe;
    [self.view addSubview:_collectionView];
    [self.pipe.doWithState(k_action_start) loadData];
}

- (void)loadData {
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ActionProcess *process = [ActionProcess getCurrentActionProcess];
    jd_unpackWithkey(NSInteger cellKey) = process.tmpTuple;
    UICollectionViewCell *cell = nil;
    if (cellKey == 100) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewCollectionViewCell" forIndexPath:indexPath];
    }else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewCollectionViewCell2" forIndexPath:indexPath];
    }
    
    return cell;
}

- (ZZActionPipe<PipeActionProtocol> *)pipe {
    if (!_pipe) {
        _pipe = (ZZActionPipe<PipeActionProtocol> *)[ZZActionPipe new];
        [_pipe registProtocol:@[@protocol(PipeActionProtocol),
                                        @protocol(UICollectionViewDataSource),
                                        @protocol(UICollectionViewDelegateFlowLayout)]
                     delegate:self
               actionRequired:^(SEL  _Nonnull selector, ActionRequirement * _Nonnull requirement) {
            
            if (selector == @selector(loadData)) {
                requirement.state(k_action_success);
            }
        }];
    }
    return _pipe;
}

@end
