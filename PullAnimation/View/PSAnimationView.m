//
//  PSAnimationView.m
//  PullAnimation
//
//  Created by Lois_pan on 16/7/5.
//  Copyright © 2016年 Lois_pan. All rights reserved.
//

#import "PSAnimationView.h"


#define HEIGHT_MIN   100

#define pScreenWidth   [UIScreen mainScreen].bounds.size.width
#define pScreenHeight   [UIScreen mainScreen].bounds.size.height
#define CURVEWIDTH   3

@interface PSAnimationView()

@property (nonatomic, assign) CGFloat pHeight; // 手势移动
@property (nonatomic, assign) CGFloat curveX;
@property (nonatomic, assign) CGFloat curveY;
@property (nonatomic, strong) UIView * curveView;
@property (nonatomic, strong) CAShapeLayer * shapeLayer;
@property (nonatomic, strong) CADisplayLink * displayLink;
@property (nonatomic, assign) BOOL isAnimating;


@end

@implementation PSAnimationView

static  NSString * KVCX = @"curveX";
static  NSString * KVCY = @"curveY";

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addObserver:self forKeyPath:KVCX options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:KVCY options:NSKeyValueObservingOptionNew context:nil];
        [self initShaper];
        [self initCurveView];
        [self initSEL];

    }
    return self;
}
- (void)dealloc {
    [self removeObserver:self forKeyPath:KVCX];
    [self removeObserver:self forKeyPath:KVCY];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:KVCX] || [keyPath isEqualToString:KVCY]) {

        [self updateLayerPath];
    }
    
}

- (void)initSEL
{
    _pHeight = 100;
    _isAnimating = NO;
    
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
    
    //CAD 比计时器 优势的地方 就是可以每秒 60秒刷新 苹果的 规定
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(calculatePath)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    _displayLink.paused = YES;
}


- (void)initShaper
{
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.fillColor = [UIColor colorWithRed:57/255.0 green:67/255.0 blue:89/255.0 alpha:1.0].CGColor;
    [self.layer addSublayer:_shapeLayer];
}

- (void)initCurveView
{
    self.curveX = pScreenWidth/2.0;       // r5点x坐标
    self.curveY = HEIGHT_MIN;                 // r5点y坐标
    _curveView = [[UIView alloc] initWithFrame:CGRectMake(_curveX, _curveY, 3, 3)];
    _curveView.backgroundColor = [UIColor redColor];
    [self addSubview:_curveView];

}

- (void)panAction:(UIPanGestureRecognizer *)pan
{
    if (!_isAnimating) {
        if (pan.state == UIGestureRecognizerStateChanged) {
            CGPoint point = [pan translationInView:self];
            _pHeight = point.y*0.7 + HEIGHT_MIN;
            self.curveX = pScreenWidth/2 + point.x;
            self.curveY = _pHeight > HEIGHT_MIN ? _pHeight : HEIGHT_MIN;
            self.curveView.frame = CGRectMake(self.curveX, self.curveY, CURVEWIDTH, CURVEWIDTH);
        }
        else if (pan.state == UIGestureRecognizerStateCancelled ||
                 pan.state == UIGestureRecognizerStateEnded||
                 pan.state == UIGestureRecognizerStateFailed){
        
            _isAnimating = YES;
            _displayLink.paused = NO;//只有在开启的时候才能计算
            [UIView animateWithDuration:1.0
                                  delay:0.0
                 usingSpringWithDamping:0.5
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 _curveView.frame = CGRectMake(pScreenWidth/2.0, HEIGHT_MIN, CURVEWIDTH, CURVEWIDTH);
                             } completion:^(BOOL finished) {
                                 if (finished) {
                                     _displayLink.paused = YES;
                                     _isAnimating = NO;
                                 }
                                 
            }];
            
        }
    }
}

- (void)calculatePath
{
    CALayer * layer = _curveView.layer.presentationLayer;
    self.curveX = layer.position.x;
    self.curveY = layer.position.y;
}

- (void)updateLayerPath
{
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, 0)];
    [bezierPath addLineToPoint:CGPointMake(pScreenWidth, 0)];
    [bezierPath addLineToPoint:CGPointMake(pScreenWidth, HEIGHT_MIN)];

    [bezierPath addQuadCurveToPoint:CGPointMake(0, HEIGHT_MIN)
                       controlPoint:CGPointMake(self.curveX, self.curveY)];
    [bezierPath closePath];
    _shapeLayer.path = bezierPath.CGPath;
    _shapeLayer.fillColor = [UIColor colorWithRed:57/255.0 green:67/255.0 blue:89/255.0 alpha:1.0].CGColor;

}


@end





















