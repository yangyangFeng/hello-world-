//
//  DetailSelectButton.h
//  bjsgecl-simple
//
//  Created by 邴天宇 on 15/7/27.
//  Copyright (c) 2015年 zcbl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailSelectButtonDelegate <NSObject>

- (void)sendDidClickIndex:(NSInteger)index;

@end

@interface DetailSelectButton : UIView

@property (nonatomic, assign) id<DetailSelectButtonDelegate> delegate;

- (id)initWithframe:(CGRect)frame ButtonTitles:(NSArray*)buttontitle ItemSize:(CGSize)size;
@end
