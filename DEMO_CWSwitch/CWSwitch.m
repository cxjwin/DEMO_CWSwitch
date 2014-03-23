//
//  CWSwitch.m
//  DEMO_CWSwitch
//
//  Created by 蔡 雪钧 on 14-3-20.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CWSwitch.h"

static const CGFloat viewWidth = 52.0;
static const CGFloat viewHeight = 32.0;

static const CGFloat edgeGap = 1.5;

static const CGFloat sliderWidth = 29.0;
static const CGFloat sliderHeight = 29.0;
static const CGFloat sliderStretchWidth = 35.0;

static const CGFloat dimViewWidth = 49.0;
static const CGFloat dimViewHeight = 29.0;
static const CGFloat dimViewShrinkWidth = 10.0;
static const CGFloat dimViewShrinkHeight = 5.0;

static const NSTimeInterval animationDuration = 0.25;

#pragma mark - DimView

@interface SliderBaseView : UIView

@property (assign, nonatomic) CGRect largeFrame;

@end

@implementation SliderBaseView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.opaque = NO;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
	CGPathRef imagePath =
	CGPathCreateWithRoundedRect(rect, CGRectGetHeight(rect) * 0.5, CGRectGetHeight(rect) * 0.5, &CGAffineTransformIdentity);
	CGContextAddPath(context, imagePath);
	CGPathRelease(imagePath);
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillPath(context);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGRectEqualToRect(self.frame, self.largeFrame)) {
        [self setNeedsDisplay];
    }
}

@end

#pragma mark - CWSwitch

@interface CWSwitch ()

@property (retain, nonatomic) UIView *slider;

@property (retain, nonatomic) SliderBaseView *baseView;

@property (retain, nonatomic) UIView *backgroundView;

@end

@implementation CWSwitch {
	BOOL _isOn;
    
	// slide side
	BOOL _left;
    
	// has moved over 'edgePointX'
	BOOL _isMoveOver;
    
	// real frame, never change
	CGRect _frame;
    
	BOOL _stretchAnimationFlag;
    
	BOOL _continueFlags[2];
}

- (instancetype)init {
	self = [self initWithFrame:CGRectZero];
	if (self) {
		//
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:_frame];
	if (self) {
		// Initialization code
		_stretchAnimationFlag = NO;
		_continueFlags[0] = NO;
		_continueFlags[1] = NO;
        
		self.backgroundColor = [UIColor clearColor];
        
		[self addSubview:self.backgroundView];
		[self addSubview:self.baseView];
		[self addSubview:self.slider];
    }
	return self;
}

- (void)dealloc {
	[_slider release], _slider = nil;
	[_backgroundView release], _backgroundView = nil;
	[_baseView release], _baseView = nil;
	[super dealloc];
}

#pragma mark - util methods

- (UIColor *)grayBackgroundColor {
	return [UIColor colorWithRed:227 / 255.0 green:227 / 255.0 blue:227 / 255.0 alpha:1.0];
}

- (UIColor *)greenBackgroundColor {
	return [UIColor colorWithRed:75 / 255.0 green:215 / 255.0 blue:99 / 255.0 alpha:1.0];
}

#pragma mark - setters & getters

- (void)setFrame:(CGRect)frame {
	CGRect realFrame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), viewWidth, viewHeight);
    
	_frame = realFrame;
	[super setFrame:realFrame];
}

- (CGRect)frame {
	return _frame;
}

- (UIView *)backgroundView {
	if (!_backgroundView) {
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
		view.userInteractionEnabled = NO;
		view.backgroundColor = [self grayBackgroundColor];
		view.layer.masksToBounds = YES;
		view.layer.cornerRadius = CGRectGetHeight(view.frame) * 0.5;
		_backgroundView = view;
	}
    
	return _backgroundView;
}

- (SliderBaseView *)baseView {
	if (!_baseView) {
		SliderBaseView *view =
		[[SliderBaseView alloc] initWithFrame:CGRectMake(edgeGap, edgeGap, dimViewWidth, dimViewHeight)];
        view.largeFrame = view.frame;
		view.userInteractionEnabled = NO;
		_baseView = view;
	}
	return _baseView;
}

- (UIView *)slider {
	if (!_slider) {
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(edgeGap, edgeGap, sliderWidth, sliderHeight)];
		view.userInteractionEnabled = NO;
		view.backgroundColor = [UIColor whiteColor];
		view.layer.cornerRadius = CGRectGetHeight(view.frame) * 0.5;
		view.layer.shadowColor = [UIColor grayColor].CGColor;
		view.layer.shadowOffset = CGSizeMake(0, 2);
		view.layer.shadowOpacity = 0.7;
		view.layer.shadowRadius = 2;
		_slider = view;
	}
	return _slider;
}

- (void)setOn:(BOOL)on {
	[self setOn:on animated:NO];
}

- (BOOL)isOn {
	return _isOn;
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
	_isOn = on;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
	if (animated) {
		[self slideAnimationWithStatus:on];
	}
	else {
		[self slideFrameWithStatus:on];
	}
}

// animated == NO
- (void)slideFrameWithStatus:(BOOL)on {
	if (on) {
		self.slider.frame = CGRectMake(CGRectGetWidth(self.frame) - sliderWidth - edgeGap, edgeGap, sliderWidth, sliderHeight);
		self.baseView.frame =
		CGRectMake(CGRectGetWidth(self.frame) * 0.5, (CGRectGetHeight(self.frame) - dimViewShrinkHeight) * 0.5, dimViewShrinkWidth, dimViewShrinkHeight);
		self.backgroundView.backgroundColor = [self greenBackgroundColor];
	}
	else {
		self.slider.frame = CGRectMake(edgeGap, edgeGap, sliderWidth, sliderHeight);
		self.baseView.frame = CGRectMake(edgeGap, edgeGap, dimViewWidth, dimViewHeight);
		self.backgroundView.backgroundColor = [self grayBackgroundColor];
	}
}

// animated == YES
- (void)slideAnimationWithStatus:(BOOL)on {
	void (^animations)() = nil;
	if (on) {
		animations = ^{
			self.slider.frame = CGRectMake(CGRectGetWidth(self.frame) - sliderWidth - edgeGap, edgeGap, sliderWidth, sliderHeight);
			self.backgroundView.backgroundColor = [self greenBackgroundColor];
		};
	}
	else {
		animations = ^{
			self.slider.frame = CGRectMake(edgeGap, edgeGap, sliderWidth, sliderHeight);
			self.baseView.frame = CGRectMake(edgeGap, edgeGap, dimViewWidth, dimViewHeight);
			self.backgroundView.backgroundColor = [self grayBackgroundColor];
		};
	}
	[UIView animateWithDuration:animationDuration
	                      delay:0.0
	                    options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
	                 animations:animations
	                 completion:nil];
}

#pragma mark - override super class methods

// begin
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	NSTimeInterval minInterval = 0.05;
    
	if (_stretchAnimationFlag) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stretchAnimation) object:nil];
	}
	else {
		_stretchAnimationFlag = YES;
	}
    
	// slider is at left or right
	_left = !_isOn;
    
	if (_left) {
		void (^animations)() = ^{
			self.baseView.frame =
			CGRectMake(CGRectGetWidth(self.frame) * 0.5, (CGRectGetHeight(self.frame) - dimViewShrinkHeight) * 0.5, dimViewShrinkWidth, dimViewShrinkHeight);
		};
		[UIView animateWithDuration:animationDuration
		                      delay:0.0
		                    options:UIViewAnimationOptionBeginFromCurrentState
		                 animations:animations
		                 completion:nil];
	}
	// stretch animation
	[self performSelector:@selector(stretchAnimation) withObject:nil afterDelay:minInterval];
    
	return [super beginTrackingWithTouch:touch withEvent:event];
}

// stretch the slider
- (void)stretchAnimation {
	// if user is touch screen too quickly (time interval < minInterval), _stretchAnimationFlag == NO
	// don't stretch the slider
	if (_stretchAnimationFlag) {
		void (^animations)() = ^{
			if (_isOn) {
				self.slider.frame = CGRectMake(CGRectGetWidth(self.frame) - sliderStretchWidth - edgeGap, edgeGap, sliderStretchWidth, sliderHeight);
			}
			else {
				self.slider.frame = CGRectMake(edgeGap, edgeGap, sliderStretchWidth, sliderHeight);
				self.baseView.frame =
				CGRectMake(CGRectGetWidth(self.frame) * 0.5, (CGRectGetHeight(self.frame) - dimViewShrinkHeight) * 0.5, dimViewShrinkWidth, dimViewShrinkHeight);
			}
		};
		[UIView animateWithDuration:animationDuration
		                      delay:0.0
		                    options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
		                 animations:animations
		                 completion:nil];
	}
}

// move
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint location = [touch locationInView:self.backgroundView];
	BOOL left = _left;
    
	// first time is left edge or right edge
	// then every time is middle
	// UISwitch's logic is not easy to understand, it's my own logic.
	CGFloat edgePointX;
    
	if (left) {
		edgePointX = CGRectGetMaxX(self.backgroundView.frame);
	}
	else {
		edgePointX = CGRectGetMinX(self.backgroundView.frame);
	}
    
	if (_isOn) {                             // open
		if (_continueFlags[0]) {             // left edge
			if (_continueFlags[1]) {         // middle
				edgePointX = CGRectGetMidX(self.backgroundView.frame);
			}
			else {
				if (location.x > CGRectGetMidX(self.backgroundView.frame)) {
					// secend time or after
					_continueFlags[1] = YES;
				}
			}
		}
		else {
			if (location.x < 0) {
				// first time
				_continueFlags[0] = YES;
			}
		}
	}
	else {                                   // close
		if (_continueFlags[0]) {             // right edge
			if (_continueFlags[1]) {         // middle
				edgePointX = CGRectGetMidX(self.backgroundView.frame);
			}
			else {
				if (location.x < CGRectGetMidX(self.backgroundView.frame)) {
					// secend time or after
					_continueFlags[1] = YES;
				}
			}
		}
		else {
			if (location.x > CGRectGetMaxX(self.backgroundView.frame)) {
				// first time
				_continueFlags[0] = YES;
			}
		}
	}
    
	// real left or right to set animation
	if (location.x > edgePointX) {
		_left = NO;
	}
	else {
		_left = YES;
	}
    
	//
	if (_continueFlags[0] || _continueFlags[1]) {
		_isMoveOver = YES;
	}
	else {
		_isMoveOver = NO;
	}
    
	void (^animations)() = ^{
		if (_left) {
			CGRect sliderFrame = CGRectMake(edgeGap, edgeGap, sliderStretchWidth, sliderHeight);
			if (!CGRectEqualToRect(self.slider.frame, sliderFrame)) {
				self.slider.frame = sliderFrame;
			}
		}
		else {
			CGRect sliderFrame = CGRectMake(CGRectGetWidth(self.frame) - sliderStretchWidth - edgeGap, edgeGap, sliderStretchWidth, sliderHeight);
			if (!CGRectEqualToRect(self.slider.frame, sliderFrame)) {
				self.slider.frame = sliderFrame;
			}
		}
	};
	[UIView animateWithDuration:animationDuration
	                      delay:0.0
	                    options:UIViewAnimationOptionBeginFromCurrentState
	                 animations:animations
	                 completion:nil];
    
	return [super continueTrackingWithTouch:touch withEvent:event];
}

// end
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	_stretchAnimationFlag = NO;
	_continueFlags[0] = NO;
	_continueFlags[1] = NO;
    
	BOOL on;
	if (_isMoveOver) {
		on = !_left;
		_isMoveOver = NO;
	}
	else {
		on = !_isOn;
	}
    
	[self setOn:on animated:YES];
	[super endTrackingWithTouch:touch withEvent:event];
}

// cancel
// backup status
- (void)cancelTrackingWithEvent:(UIEvent *)event {
	[self setOn:_isOn animated:YES];
	[super cancelTrackingWithEvent:event];
}

@end
