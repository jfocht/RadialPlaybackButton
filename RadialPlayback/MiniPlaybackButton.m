//
//  MiniPlaybackButton.m
//  RadialPlayback
//
//  Created by Jordan Focht on 3/5/15.
//  Copyright (c) 2015 Jordan Focht. All rights reserved.
//

#import "MiniPlaybackButton.h"
#import <QuartzCore/QuartzCore.h>

@interface ProgressLayer : CALayer

@property (nonatomic) CGFloat percent;
@property (nonatomic) CGFloat width;
@end

@interface LoadingLayer : CALayer {
    BOOL animatingLoad;
}

-(void)startLoadAnimation;
@end

@interface MiniPlaybackButton () {
    BOOL _loading;
    CGFloat _value;
    CGFloat _maximumValue;
    CGFloat _minimumValue;
}

@property (nonatomic) LoadingLayer* radialLayer;
@property (nonatomic) ProgressLayer* progressLayer;
@property (strong,nonatomic) UIImage* normalImage;
@end


@implementation MiniPlaybackButton

-(void)didMoveToSuperview {
    if (self.layer.sublayers.count == 0) {
        [self addTarget:self action:@selector(didTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];

        self.normalImage = [self imageForState:UIControlStateNormal];

        self.radialLayer = [LoadingLayer new];
        self.radialLayer.contentsScale = [UIScreen mainScreen].scale;
        self.radialLayer.frame = self.bounds;
        [self.radialLayer setNeedsDisplay];
        [self.layer addSublayer:self.radialLayer];
        self.progressLayer = [ProgressLayer new];
        self.progressLayer.contentsScale = [UIScreen mainScreen].scale;
        self.progressLayer.frame = self.bounds;
        [self.progressLayer setNeedsDisplay];
        [self.layer addSublayer:self.progressLayer];

        [self.radialLayer startLoadAnimation];
        self.progressLayer.hidden = _loading;
        self.radialLayer.hidden = !_loading;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];

    self.radialLayer.frame = self.bounds;
    [self.radialLayer setNeedsDisplay];
}


-(BOOL)loading {
    return _loading;
}

-(CGFloat)maximumValue {
    return _maximumValue;
}

-(CGFloat)minimumValue {
    return _minimumValue;
}

-(CGFloat)value {
    return _value;
}

-(void)setLoading:(BOOL)loading {
    _loading = loading;

    self.progressLayer.hidden = loading;
    self.radialLayer.hidden = !loading;
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    UIImage* selectedImage = selected ? [self imageForState:UIControlStateSelected] : self.normalImage;
    if (selectedImage) {
        [self setImage:selectedImage forState:UIControlStateNormal];
    }
}

-(void)setMaximumValue:(CGFloat)maximumValue  {
    _maximumValue = maximumValue;
    [self updateProgress];
}

-(void)setMinimumValue:(CGFloat)minimumValue  {
    _minimumValue = minimumValue;
    [self updateProgress];
}

-(void)setValue:(CGFloat)value  {
    _value = value;
    [self updateProgress];
}

-(void)updateProgress {
    if (_maximumValue < _minimumValue) {
        _maximumValue = _minimumValue;
    }
    if (_value > _maximumValue) {
        _value = _maximumValue;
    }
    if (_value < _minimumValue) {
        _value = _minimumValue;
    }
    CGFloat percent = (_value - _minimumValue) / (_maximumValue - _minimumValue);
    percent = MAX(0, MIN(1, percent));
    NSLog(@"value = %f; minimumValue = %f; maximumValue = %f; percent = %f", _value, _minimumValue, _maximumValue, percent);
    [self.progressLayer setPercent:percent];
    [self.progressLayer setNeedsDisplay];
}

-(void)didTouchUpInside:(UIButton*)sender {
    sender.selected = !sender.selected;
}

@end


@implementation ProgressLayer

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    return [@"percent" isEqualToString:key] || [super needsDisplayForKey:key];
}

-(void)drawInContext:(CGContextRef)context {
    CGFloat midX = CGRectGetMidX(self.frame);
    CGPoint centerPoint = CGPointMake(midX, CGRectGetMidY(self.frame));
    CGFloat radius = (self.frame.size.height / 2 - 5);
    CGFloat startAngle = 2 * M_PI * self.percent - M_PI / 2;
    CGFloat endAngle = 0 - M_PI / 2;
    CGFloat lineWidth = 2.5;

    CGColorRef color = [UIColor colorWithRed:0 green:121/255.0f blue:1.0f alpha:1.0f].CGColor;

    CGMutablePathRef outerArc = CGPathCreateMutable();
    CGPathAddArc(outerArc, NULL,
                 centerPoint.x, centerPoint.y,
                 radius,
                 2 * M_PI,
                 0 - M_PI / 2,
                 YES);
    CGPathRef outerStrokedArc =
    CGPathCreateCopyByStrokingPath(outerArc, NULL,
                                   1,
                                   kCGLineCapSquare,
                                   kCGLineJoinBevel,
                                   0);
    CGContextAddPath(context, outerStrokedArc);
    CGContextSetFillColorWithColor(context, color);
    CGContextDrawPath(context, kCGPathFill);

    CGMutablePathRef arc = CGPathCreateMutable();
    CGPathAddArc(arc, NULL,
                 centerPoint.x, centerPoint.y,
                 radius - 1.5,
                 startAngle,
                 endAngle,
                 YES);
    CGPathRef strokedArc =
    CGPathCreateCopyByStrokingPath(arc, NULL,
                                   lineWidth,
                                   kCGLineCapSquare,
                                   kCGLineJoinBevel,
                                   0);
    CGContextAddPath(context, strokedArc);
    CGContextSetFillColorWithColor(context, color);
    CGContextDrawPath(context, kCGPathFill);
}

@end

@implementation LoadingLayer

-(void)startLoadAnimation {
    animatingLoad = YES;
    self.speed = 1.0;
    [self setNeedsDisplay];
    CABasicAnimation* loadingAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    loadingAnimation.repeatCount = CGFLOAT_MAX;
    loadingAnimation.duration = 0.75;
    loadingAnimation.fromValue = [NSNumber numberWithFloat:0];
    loadingAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    loadingAnimation.removedOnCompletion = false;
    loadingAnimation.fillMode = kCAFillModeForwards;
    [self addAnimation:loadingAnimation forKey:@"transform.rotation"];
}

-(void)drawInContext:(CGContextRef)context {
    CGFloat midX = CGRectGetMidX(self.frame);
    CGPoint centerPoint = CGPointMake(midX, CGRectGetMidY(self.frame));
    CGFloat radius = (self.frame.size.height / 2 - 5);

    CGColorRef color = [UIColor colorWithRed:0 green:121/255.0f blue:1.0f alpha:1.0f].CGColor;

    CGMutablePathRef outerArc = CGPathCreateMutable();
    CGPathAddArc(outerArc, NULL,
                 centerPoint.x, centerPoint.y,
                 radius,
                 2 * M_PI,
                 M_PI / 8,
                 YES);
    CGPathRef outerStrokedArc =
    CGPathCreateCopyByStrokingPath(outerArc, NULL,
                                   1,
                                   kCGLineCapSquare,
                                   kCGLineJoinBevel,
                                   0);
    CGContextAddPath(context, outerStrokedArc);
    CGContextSetFillColorWithColor(context, color);
    CGContextDrawPath(context, kCGPathFill);
}


@end
