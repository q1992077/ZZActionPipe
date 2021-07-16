//
//  MTA.m
//  ZZActionPipe
//
//  Created by 曾智 on 2021/7/15.
//

#import "MTA.h"
#import "ZZActionPipe.h"

@implementation MTA

+ (ZZActionPipe *)pipe {
    __block BOOL bDidScroll = YES;
    ZZActionPipe *pipe = [ZZActionPipe alloc];
    pipe.registAction(@selector(viewDidAppear:)).action = pipe_createAction(BOOL animated) {
        NSLog(@"ViewController viewDidAppear 曝光");
    };
    
    pipe.registAction(@selector(cellaction:)).action = pipe_createAction(NSInteger row) {
        NSLog(@"cell %ld 点击上报", row);
    };
    
    pipe.registAction(@selector(scrollViewDidScroll:)).action = pipe_createAction(UIScrollView *view) {
        bDidScroll = YES;
    };
        
    pipe.registAction(@selector(scrollViewDidEndDragging:willDecelerate:)).action = pipe_createAction(UIScrollView *view, BOOL decelerate) {
        if (!decelerate) {
            bDidScroll = NO;
        }
    };

    pipe.registAction(@selector(scrollViewDidEndDecelerating:)).action = pipe_createAction(UIScrollView *view) {
        bDidScroll = NO;
    };
    
    pipe.registAction(@selector(collectionView:willDisplayCell:forItemAtIndexPath:)).action = pipe_createAction(UICollectionView *collectionView, UICollectionViewCell *cell, NSIndexPath*indexPath) {
        if (bDidScroll) {
            NSLog(@"cell %ld 曝光上报", indexPath.row);
        }
    };
    return pipe;
}

@end
