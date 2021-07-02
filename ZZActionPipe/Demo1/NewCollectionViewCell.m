//
//  NewCollectionViewCell.m
//  ZZActionPipeDemo
//
//  Created by 曾智 on 2020/7/10.
//  Copyright © 2020 曾智. All rights reserved.
//

#import "NewCollectionViewCell.h"
#import "ZZActionPipe.h"
#import "ActionProtocol.h"

@interface NewCollectionViewCell ()

@property (nonatomic, strong) UILabel *labTitle;
@property (nonatomic, strong) UILabel *labSubtitle;

@property (nonatomic, strong) void(^actionBlock)(void);
@end

@implementation NewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.labTitle = ({
        UILabel *lab = [UILabel new];
        lab;
    });
    self.labSubtitle = ({
        UILabel *lab = [UILabel new];
        lab;
    });
    
    [self addSubview:self.labTitle];
    [self addSubview:self.labSubtitle];
    self.labSubtitle.frame = (CGRect){0,200, self.labSubtitle.frame.size};
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(action)];
    [self addGestureRecognizer:tap];
    return self;
}

- (void)action {
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ActionProcess *proceess = [ActionProcess getCurrentActionProcess];
    jd_unpack(proceess.tmpTuple)^(arg_ph empty, NSString *title, NSString *subTitle){
        self.labTitle.text = title;
        self.labSubtitle.text = subTitle;
        [self.labTitle sizeToFit];
        [self.labSubtitle sizeToFit];
    };

    NSInteger iRow = indexPath.row;
    ZZActionPipe<PipeActionProtocol> *rootPipe = [ZZActionPipe<PipeActionProtocol> getRootPipe];
    self.actionBlock = ^{
        [rootPipe cellaction:iRow];
    };
    return self;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ActionProcess *process = [ActionProcess getCurrentActionProcess];
    NSInteger cellKey = [process.tmpTuple[0] integerValue];
    if (cellKey == 100) {
        return (CGSize){400, 300};
    }else {
        return [[process getUpStramReturnValue] CGSizeValue];
    }
}

+ (ZZActionPipe *)pipe {
    ZZActionPipe *pipe = [ZZActionPipe new];
    [pipe registProtocol:@[@protocol(UICollectionViewDataSource), @protocol(UICollectionViewDelegateFlowLayout)] strongDelegate:[NewCollectionViewCell new] actionRequired:^(SEL  _Nonnull selector, ActionRequirement * _Nonnull requirement) {
        if(selector == @selector(collectionView:cellForItemAtIndexPath:)) {
            requirement.upReturnToBeTarget().returnKindOf([NewCollectionViewCell class]);
        }
    }];
    return pipe;
}
@end
