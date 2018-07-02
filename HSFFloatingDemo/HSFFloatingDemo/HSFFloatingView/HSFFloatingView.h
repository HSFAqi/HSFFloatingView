//
//  HSFFloatingView.h
//  testDemo
//
//  Created by 黄山锋 on 2018/7/2.
//  Copyright © 2018年 黄山锋. All rights reserved.
//

#import <UIKit/UIKit.h>


// 停留方式
typedef NS_ENUM(NSInteger, StayMode) {
    // 停靠左右两侧
    STAYMODE_LEFTANDRIGHT = 0,
    // 停靠左侧
    STAYMODE_LEFT = 1,
    // 停靠右侧
    STAYMODE_RIGHT = 2
};

@interface HSFFloatingView : UIImageView

/** 悬浮图片停留的方式(默认为STAYMODE_LEFTANDRIGHT) */
@property (nonatomic, assign) StayMode stayMode;

/** 悬浮图片停留时的透明度（stayAlpha >= 0，1：不透明，默认为不透明） */
@property (nonatomic, assign) CGFloat stayAlpha;

/** 悬浮图片左右边距(默认5)*/
@property (nonatomic, assign) CGFloat stayEdgeDistance;

/** 悬浮图片停靠的动画事件(默认0.3秒)*/
@property (nonatomic, assign) CGFloat stayAnimateTime;

/** 悬浮图片停靠后，是否延时隐藏(默认：是)*/
@property (nonatomic,assign) BOOL isDelayHide;

/** 悬浮图片停靠后，延时隐藏的时间(默认3秒)*/
@property (nonatomic, assign) CGFloat delayHideTime;




/** 设置简单的轻点 block事件 */
- (void)setTapActionWithBlock:(void (^)(void))block;

/** 根据 imageName 改变FloatView的image */
- (void)setImageWithName:(NSString *)imageName;

/** 当滚动的时候悬浮图片居中在屏幕边缘 */
- (void)facingScreenBorderWhenScrolling;
@end
