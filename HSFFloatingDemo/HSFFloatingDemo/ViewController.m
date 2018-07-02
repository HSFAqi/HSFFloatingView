//
//  ViewController.m
//  HSFFloatingDemo
//
//  Created by 黄山锋 on 2018/7/2.
//  Copyright © 2018年 黄山锋. All rights reserved.
//

#import "ViewController.h"


#import "HSFFloatingView.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (nonatomic,strong) HSFFloatingView *floatingView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"HSFFloatingDemo";

    
//    [self.view addSubview:self.floatingView];
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    /* 如果是需要全局的，只需要添加到window上就行，但是必须是在页面加载完毕后添加 */
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self.floatingView];
}

#pragma mark 懒加载
-(HSFFloatingView *)floatingView{
    if (!_floatingView) {
        _floatingView = [[HSFFloatingView alloc]initWithFrame:CGRectMake(0, 100, 80, 80)];
        [_floatingView setImageWithName:@"红包"];
        _floatingView.stayMode = STAYMODE_LEFTANDRIGHT;
        _floatingView.stayAlpha = 0.5f;
        _floatingView.stayEdgeDistance = 0.f;
        _floatingView.stayAnimateTime = .2f;
        _floatingView.isDelayHide = YES;
        _floatingView.delayHideTime = 3.f;
        [_floatingView setTapActionWithBlock:^{
            NSLog(@"单击红包");
        }];
    }
    return _floatingView;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
