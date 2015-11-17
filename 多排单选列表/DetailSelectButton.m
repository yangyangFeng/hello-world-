//
//  DetailSelectButton.m
//  bjsgecl-simple
//
//  Created by 邴天宇 on 15/7/27.
//  Copyright (c) 2015年 zcbl. All rights reserved.
//

#import "DetailSelectButton.h"
#define DETAILEBUTTON 100
#define DETAOLEICON 200
@interface DetailSelectButton ()

@property (nonatomic, strong) NSMutableArray* arrayIcon;
@end
@implementation DetailSelectButton


- (id)initWithframe:(CGRect)frame ButtonTitles:(NSArray*)buttontitle ItemSize:(CGSize)size
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, (size.height + 15) * buttontitle.count)];
    if (self) {
        _arrayIcon = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < buttontitle.count; i++) {
            UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setTitle:[NSString stringWithFormat:@"   %@",buttontitle[i]] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor whiteColor];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 25, 0, 0);
            [button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
            button.frame = CGRectMake(25, i * 35, size.width - 65, size.height);
            button.tag = DETAILEBUTTON + i;
            [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:(UIControlEventTouchUpInside)];
            UIImageView* Icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_button_select_no"]];
            Icon.frame = CGRectMake(25, i * 35 + 2.5, 15, 15);
            Icon.tag = DETAOLEICON + i;
            [self addSubview:button];
            [self addSubview:Icon];
            [_arrayIcon addObject:Icon];
        }
    }
    return self;
}

- (void)buttonDidClick:(UIButton*)sender
{
    NSInteger tag = sender.tag - DETAILEBUTTON;
    for (UIImageView* imageView in _arrayIcon) {
        imageView.image = [UIImage imageNamed:@"detail_button_select_no"];
    }
    UIImageView* selectImage = (UIImageView*)[self viewWithTag:tag + DETAOLEICON];
    selectImage.image = [UIImage imageNamed:@"detail_button_select_yes"];
    if ([_delegate respondsToSelector:@selector(sendDidClickIndex:)]) {
        [_delegate sendDidClickIndex:tag];
    }
}

@end
