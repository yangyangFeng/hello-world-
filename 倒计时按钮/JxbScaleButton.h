//
//  JxbScaleButton.h
//  JxbScaleButton
//
//  Created by Peter on 15/8/7.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JxbScaleSetting : NSObject
@property(nonatomic,strong)NSString     *strCommon;//按钮可用时的文本
@property(nonatomic,strong)NSString     *strPrefix;//倒计时前缀
@property(nonatomic,strong)NSString     *strSuffix;//倒计时后缀
@property(nonatomic,assign)int          indexStart;//开始从几倒计时
@property(nonatomic,strong)UIColor      *colorDisable;//倒计时的背景颜色
@property(nonatomic,strong)UIColor      *colorCommon;//按钮可用时的背景颜色
@property(nonatomic,strong)UIColor      *colorTitle;//文本颜色
@end

@interface JxbScaleButton : UIButton
/* 调用
- (void)viewDidLoad {
    [super viewDidLoad];
    
    JxbScaleButton* btn = [[JxbScaleButton alloc] initWithFrame:CGRectMake(100, 200, 100, 44)];
    btn.layer.cornerRadius = 5;
    btn.layer.masksToBounds = YES;
    
    [self.view addSubview:btn];
    
    [self btnAction:btn];
    
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnAction:(id)sender {
    NSLog(@"click");
    JxbScaleButton* btn = (JxbScaleButton*)sender;
    JxbScaleSetting* setting = [[JxbScaleSetting alloc] init];
    setting.strPrefix = @"";
    setting.strSuffix = @"秒";
    setting.strCommon = @"重新发送";
    setting.indexStart = 10;
    [btn startWithSetting:setting];
}
*/
/**
 *  开始倒计时，此时按钮disable
 *
 *  @param setting 设置
 */
- (void)startWithSetting:(JxbScaleSetting*)setting;
@end
