//
//  NewCollectionViewCell2.m
//  JDSHActionPipeDemo
//
//  Created by 曾智 on 2021/6/22.
//  Copyright © 2021 曾智. All rights reserved.
//

#import "NewCollectionViewCell2.h"
#import "ZZActionPipe.h"
#import "ActionProtocol.h"

@interface NewCollectionViewCell2 ()

@property (nonatomic, strong) UILabel *labTitle;
@property (nonatomic, strong) UILabel *labSubtitle;

@property (nonatomic, strong) void(^actionBlock)(void);
@end

@implementation NewCollectionViewCell2

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.labTitle = ({
        UILabel *lab = [UILabel new];
        lab.textColor = [UIColor whiteColor];
        lab.font = [UIFont boldSystemFontOfSize:20];
        lab;
    });
    self.labSubtitle = ({
        UILabel *lab = [UILabel new];
        lab.textColor = [UIColor whiteColor];
        lab;
    });
    
    [self addSubview:self.labTitle];
    [self addSubview:self.labSubtitle];
    self.labSubtitle.frame = (CGRect){0,50, self.labSubtitle.frame.size};
    
    self.backgroundColor = [UIColor redColor];
    
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
    JD_TUPLE(arg_ph, NSString *, NSString *) tmp = proceess.tmpTuple;
    jd_unpack_strict(tmp)^(arg_ph empty, NSString *title, NSString *subTitle){
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
    if (cellKey == 200) {
        return (CGSize){400, 200};
    }else {
        return [[process getUpStramReturnValue] CGSizeValue];
    }
}

+ (ZZActionPipe *)pipe {
    ZZActionPipe *pipe = [ZZActionPipe pipe];
    [pipe registProtocol:@[@protocol(UICollectionViewDataSource), @protocol(UICollectionViewDelegateFlowLayout)] strongDelegate:[NewCollectionViewCell2 new] actionRequired:^(SEL  _Nonnull selector, ActionRequirement * _Nonnull requirement) {
        if(selector == @selector(collectionView:cellForItemAtIndexPath:)) {
            requirement.upReturnToBeTarget().returnKindOf([NewCollectionViewCell2 class]);
        }
    }];
    return pipe;
}
@end
