//
//  HSFFloatingView.m
//  testDemo
//
//  Created by 黄山锋 on 2018/7/2.
//  Copyright © 2018年 黄山锋. All rights reserved.
//

#import "HSFFloatingView.h"

#import <objc/runtime.h>

#define NavBarBottom 64
#define TabBarHeight 49
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

static char kActionHandlerTapBlockKey;
static char kActionHandlerTapGestureKey;



@interface HSFFloatingView ()

@property (nonatomic,assign) BOOL isMoving;//是否在移动
@property (nonatomic,assign) CGFloat timeCountDown;//用于隐藏时的判断，停在边缘时开始倒计时，移动时重置倒计时
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) BOOL isHide;//是否隐藏

@end

@implementation HSFFloatingView

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super initWithImage:image]) {
        self.userInteractionEnabled = YES;
        self.stayEdgeDistance = 5;
        self.stayAnimateTime = 0.3;
        self.delayHideTime = 3;
        self.timeCountDown = self.delayHideTime;
        self.isDelayHide = YES;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCountDownACTION) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer setFireDate:[NSDate distantPast]];
        [self initStayLocation];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.stayEdgeDistance = 5;
        self.stayAnimateTime = 0.3;
        self.delayHideTime = 3;
        self.timeCountDown = self.delayHideTime;
        self.isDelayHide = YES;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCountDownACTION) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer setFireDate:[NSDate distantPast]];
        [self initStayLocation];
    }
    return self;
}

#pragma mark 定时器
-(void)timerCountDownACTION{
    self.timeCountDown--;
    // 这里可以设置过几秒，alpha减小
    if (self.timeCountDown <= 0) {
        if (self.isDelayHide && !self.isMoving && self.alpha == 1) {
            [self facingScreenBorderWhenScrolling];
        }
    }
}

#pragma mark touch
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isMoving = YES;
    self.alpha = 1;
    [self.timer setFireDate:[NSDate distantFuture]];
    
    // 获取手指当前的点
    UITouch * touch = [touches anyObject];
    CGPoint  curPoint = [touch locationInView:self];
    
    CGPoint prePoint = [touch previousLocationInView:self];
    
    // x方向移动的距离
    CGFloat deltaX = curPoint.x - prePoint.x;
    CGFloat deltaY = curPoint.y - prePoint.y;
    CGRect frame = self.frame;
    frame.origin.x += deltaX;
    frame.origin.y += deltaY;
    self.frame = frame;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.isMoving = NO;
    [self moveStay];
}

#pragma mark - 设置浮动图片的初始位置
- (void)initStayLocation
{
    CGRect frame = self.frame;
    CGFloat stayWidth = frame.size.width;
    CGFloat initX = kScreenWidth - self.stayEdgeDistance - stayWidth;
    CGFloat initY = (kScreenHeight - NavBarBottom - TabBarHeight) * (2.0 / 3.0) + NavBarBottom;
    frame.origin.x = initX;
    frame.origin.y = initY;
    self.frame = frame;
}

#pragma mark - 根据 stayModel 来移动悬浮图片
- (void)moveStay
{
    self.isHide = NO;
    bool isLeft = [self judgeLocationIsLeft];
    switch (_stayMode) {
        case STAYMODE_LEFTANDRIGHT:
        {
            [self moveToBorder:isLeft];
        }
            break;
        case STAYMODE_LEFT:
        {
            [self moveToBorder:YES];
        }
            break;
        case STAYMODE_RIGHT:
        {
            [self moveToBorder:NO];
        }
            break;
        default:
            break;
    }
}


#pragma mark - 移动到屏幕边缘
- (void)moveToBorder:(BOOL)isLeft
{
    CGRect frame = self.frame;
    CGFloat destinationX;
    if (isLeft) {
        destinationX = self.stayEdgeDistance;
    }
    else {
        CGFloat stayWidth = frame.size.width;
        destinationX = kScreenWidth - self.stayEdgeDistance - stayWidth;
    }
    frame.origin.x = destinationX;
    frame.origin.y = [self moveSafeLocationY];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:self.stayAnimateTime animations:^{
        __strong typeof(self) pThis = weakSelf;
        pThis.frame = frame;
        pThis.alpha = 1.0;
    }completion:^(BOOL finished) {
        weakSelf.timeCountDown = self.delayHideTime;
        [weakSelf.timer setFireDate:[NSDate distantPast]];
    }];
}

#pragma mark - 设置悬浮图片不高于屏幕顶端，不低于屏幕底端
- (CGFloat)moveSafeLocationY
{
    CGRect frame = self.frame;
    CGFloat stayHeight = frame.size.height;
    // 当前view的y值
    CGFloat curY = self.frame.origin.y;
    CGFloat destinationY = frame.origin.y;
    // 悬浮图片的最顶端Y值
    CGFloat stayMostTopY = NavBarBottom + _stayEdgeDistance;
    if (curY <= stayMostTopY) {
        destinationY = stayMostTopY;
    }
    // 悬浮图片的底端Y值
    CGFloat stayMostBottomY = kScreenHeight - TabBarHeight - _stayEdgeDistance - stayHeight;
    if (curY >= stayMostBottomY) {
        destinationY = stayMostBottomY;
    }
    return destinationY;
}

#pragma mark -  判断当前view是否在父界面的左边
- (bool)judgeLocationIsLeft
{
    // 手机屏幕中间位置x值
    CGFloat middleX = [UIScreen mainScreen].bounds.size.width / 2.0;
    // 当前view的x值
    CGFloat curX = self.frame.origin.x;
    if (curX <= middleX) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - 当滚动的时候悬浮图片居中在屏幕边缘
- (void)facingScreenBorderWhenScrolling
{
    bool isLeft = [self judgeLocationIsLeft];
    [self moveStayToMiddleInScreenBorder:isLeft];
}

// 悬浮图片居中在屏幕边缘
- (void)moveStayToMiddleInScreenBorder:(BOOL)isLeft
{
    CGRect frame = self.frame;
    CGFloat stayWidth = frame.size.width;
    CGFloat destinationX;
    if (isLeft == YES) {
        destinationX = - stayWidth/2;
    }
    else {
        destinationX = kScreenWidth - stayWidth + stayWidth/2;
    }
    frame.origin.x = destinationX;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        __strong typeof(self) pThis = weakSelf;
        pThis.frame = frame;
        pThis.alpha = pThis.stayAlpha;
    }completion:^(BOOL finished) {
        weakSelf.isHide = YES;
        self.timeCountDown = self.delayHideTime;
        [self.timer setFireDate:[NSDate distantFuture]];
    }];
}

#pragma mark -  设置简单的轻点 block事件
- (void)setTapActionWithBlock:(void (^)(void))block
{
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &kActionHandlerTapGestureKey);
    
    if (!gesture)
    {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__handleActionForTapGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kActionHandlerTapGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    objc_setAssociatedObject(self, &kActionHandlerTapBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)__handleActionForTapGesture:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized)
    {
        void(^action)(void) = objc_getAssociatedObject(self, &kActionHandlerTapBlockKey);
        if (action)
        {
            if (self.isHide) {
                // 先让悬浮图片的alpha为1
                self.alpha = 1;
                self.isMoving = NO;
                [self moveStay];
            }else{
                action();
                self.isMoving = NO;
                __weak typeof(self) weakSelf = self;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.timeCountDown = self.delayHideTime;
                    [weakSelf.timer setFireDate:[NSDate distantPast]];
                });
            }
        }
    }
}

#pragma mark - getter / setter
- (void)setStayAlpha:(CGFloat)stayAlpha
{
    if (stayAlpha <= 0) {
        stayAlpha = 1;
    }
    _stayAlpha = stayAlpha;
}


- (void)setImageWithName:(NSString *)imageName
{
    self.image = [UIImage imageNamed:imageName];
}




@end
