/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "ORKStepContainerView.h"
#import "ORKTitleLabel.h"
#import "ORKBodyItem.h"
#import "ORKBodyContainerView.h"
#import "ORKSkin.h"
#import "ORKGDPRView.h"
#import "ORKNavigationContainerView_Internal.h"

/**
 
 +---------------------------------------+
 | +-----------------------------------+ |<---_stepContainerView
 | |        _topContentImageView       | |
 | |                                   | |
 | |                                   | |
 | |___________________________________| |
 | +-----------------------------------+ |
 | |    +_________________________+    |<-----_scrollView
 | |    |                         |    | |
 | |    |       +-------+         |<----------_scrollContainerView
 | |    |       | _icon |         |    | |
 | |    |       |       |         |    | |
 | |    |       +-------+         |    | |
 | |    |                         |    | |
 | |    | +---------------------+ |    | |
 | |    | |    _titleLabel      | |    | |
 | |    | |_____________________| |    | |
 | |    |                         |    | |
 | |    | +---------------------+ |    | |
 | |    | |                     |<------------_bodyContainerView: UIstackView
 | |    | | +-----------------+ | |    | |
 | |    | | |                 | | |    | |
 | |    | | |--Title          | | |    | |
 | |    | | |--Text           |<------------- BodyItemStyleText
 | |    | | |--LearnMore      | | |    | |
 | |    | | |_________________| | |    | |
 | |    | |                     | |    | |
 | |    | | +---+-------------+ | |    | |
 | |    | | |   |--Title      | | |    | |
 | |    | | | o |--Text       |<------------- BodyItemStyleBullet
 | |    | | |   |--LearnMore  | | |    | |
 | |    | | |___|_____________| | |    | |
 | |    | |_____________________| |    | |
 | |    |                         |    | |
 | |    | +---------------------+ |    | |
 | |    | |  _CustomContentView | |    | |
 | |    | |_____________________| |    | |
 | |____|_________________________|____| |
 |______|_________________________|______|
        |                         |
        |                         |
        | +---------------------+ |
        | |      _gdprView      | |
        | |_____________________| |
        | +---------------------+ |
        | |  _navigationFooter  | |
        | |_____________________| |
        vvvvvvvvvvvvvvvvvvvvvvvvvvv
 */

static const CGFloat ORKStepContainerIconImageViewDimension = 80.0;
static const CGFloat ORKStepContainerIconImageViewToTitleLabelPadding = 20.0;
static const CGFloat ORKStepContainerIconToBodyTopPaddingStandard = 20.0;
static const CGFloat ORKStepContainerIconToBulletTopPaddingStandard = 20.0;
static const CGFloat ORKStepContainerTopCustomContentPaddingStandard = 20.0;

@interface ORKStepContainerView()<ORKBodyContainerViewDelegate, ORKGDPRViewLearnMoreDelegate>

@end

@implementation ORKStepContainerView {
    
    UIScrollView *_scrollView;
    UIView *_scrollContainerView;
    
    ORKTitleLabel *_titleLabel;
    UIImageView *_topContentImageView;
    UIImageView *_iconImageView;
    ORKBodyContainerView *_bodyContainerView;
    BOOL _isNavigationContainerScrollable;
    
    ORKGDPRView *_gdprView;
    
//    variable constraints:
    NSLayoutConstraint *_scrollViewTopConstraint;
    NSLayoutConstraint *_scrollViewBottomConstraint;
    NSLayoutConstraint *_titleLabelTopConstraint;
    NSLayoutConstraint *_bodyContainerViewTopConstraint;
    NSLayoutConstraint *_customContentViewTopConstraint;
    
    NSLayoutConstraint *_scrollContainerContentSizeConstraint;
    NSArray<NSLayoutConstraint *> *_topContentImageViewConstraints;
    NSArray<NSLayoutConstraint *> *_iconImageViewConstraints;
    
    NSLayoutConstraint *_gdprViewBottomConstraint;
    NSArray<NSLayoutConstraint *> *_navigationContainerViewConstraints;
    
    NSMutableArray<NSLayoutConstraint *> *_updatedConstraints;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupScrollView];
        [self setupScrollContainerView];
        _isNavigationContainerScrollable = YES;
        [self setupConstraints];
        [self setupUpdatedConstraints];
        [self setupNavigationContainerView];
    }
    return self;
}

- (void)setStepTopContentImage:(UIImage *)stepTopContentImage {
    
    _stepTopContentImage = stepTopContentImage;
    
    //    1.) nil Image; updateConstraints
    if (!stepTopContentImage && _topContentImageView) {
        [_topContentImageView removeFromSuperview];
        _topContentImageView = nil;
        [self deactivateTopContentImageViewConstraints];
        [self updateScrollViewTopConstraint];
        [self setNeedsUpdateConstraints];
    }
    
    //    2.) First Image; updateConstraints
    if (stepTopContentImage && !_topContentImageView) {
        [self setupTopContentImageView];
        _topContentImageView.image = [self topContentAndAuxiliaryImage];
        [self updateScrollViewTopConstraint];
        [self setNeedsUpdateConstraints];
    }
    
    //    3.) >= second Image;
    if (stepTopContentImage && _topContentImageView) {
        _topContentImageView.image = [self topContentAndAuxiliaryImage];
    }
}

- (void)setAuxiliaryImage:(UIImage *)auxiliaryImage {
    _auxiliaryImage = auxiliaryImage;
    if (_stepTopContentImage) {
        _topContentImageView.image = [self topContentAndAuxiliaryImage];
    }
}

- (UIImage *)topContentAndAuxiliaryImage {
    if (!_auxiliaryImage) {
        return _stepTopContentImage;
    }
    CGSize size = _auxiliaryImage.size;
    UIGraphicsBeginImageContext(size);
    
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    
    [_auxiliaryImage drawInRect:rect];
    [_stepTopContentImage drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setStepTitle:(NSString *)stepTitle {
    _stepTitle = stepTitle;
    if (!_titleLabel) {
        [self setupTitleLabel];
        [self updateBodyContainerViewTopConstraint];
        [self updateCustomContentViewTopConstraint];
        [self setNeedsUpdateConstraints];
    }
    [_titleLabel setText:stepTitle];
}

- (void)setTitleIconImage:(UIImage *)titleIconImage {
    _titleIconImage = titleIconImage;
    if (!titleIconImage && _iconImageView) {
        [_iconImageView removeFromSuperview];
        _iconImageView = nil;
        [self deactivateIconImageViewConstraints];
        [self updateTitleLabelTopConstraint];
        [self updateBodyContainerViewTopConstraint];
        [self updateCustomContentViewTopConstraint];
        [self setNeedsUpdateConstraints];
    }
    if (titleIconImage && !_iconImageView) {
        [self setupIconImageView];
        _iconImageView.image = titleIconImage;
        [self updateTitleLabelTopConstraint];
        [self updateBodyContainerViewTopConstraint];
        [self updateCustomContentViewTopConstraint];
        [self setNeedsUpdateConstraints];
    }
    if (titleIconImage && _iconImageView) {
        _iconImageView.image = titleIconImage;
    }
}

- (void)setBodyItems:(NSArray<ORKBodyItem *> *)bodyItems {
    _bodyItems = bodyItems;
    if (!_bodyContainerView) {
        [self setupBodyContainerView];
        [self updateCustomContentViewTopConstraint];
        [self setNeedsUpdateConstraints];
    }
    else {
        _bodyContainerView.bodyItems = _bodyItems;
    }
}

- (void)setupScrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    _scrollView.showsVerticalScrollIndicator = _showScrollIndicator;
    [self addSubview:_scrollView];
}

- (void)setShowScrollIndicator:(BOOL)showScrollIndicator {
    _showScrollIndicator = showScrollIndicator;
    _scrollView.showsVerticalScrollIndicator = showScrollIndicator;
}

- (void)addGDPRViewWithIconImage:(UIImage *)iconImage text:(NSString *)text
                   learnMoreText:(NSString *)learnMoreText
        learnMoreInstructionStep:(ORKLearnMoreInstructionStep *)learnMoreInstructionStep {
    
    if (!_gdprView) {
        _gdprView = [[ORKGDPRView alloc] initWithIconImage:iconImage
                                                      text:text
                                             learnMoreItem:[ORKLearnMoreItem learnMoreLinkItemWithText:learnMoreText
                                                                              learnMoreInstructionStep:learnMoreInstructionStep]];
    }
    _gdprView.delegate = self;
    [_scrollContainerView addSubview:_gdprView];
    [self addGDPRViewConstraints];
    [self setNeedsUpdateConstraints];
}

- (void)deactivateGDPRViewBottomConstraint {
    if (_gdprViewBottomConstraint) {
        [NSLayoutConstraint deactivateConstraints:@[_gdprViewBottomConstraint]];
        if ([_updatedConstraints containsObject:_gdprViewBottomConstraint]) {
            [_updatedConstraints removeObject:_gdprViewBottomConstraint];
        }
    }
}

- (void)setGDPRViewBottomConstraint {
    _gdprViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_gdprView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_isNavigationContainerScrollable ? _navigationFooterView : _scrollContainerView
                                                             attribute:_isNavigationContainerScrollable ? NSLayoutAttributeTop : NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:0.0];
}

- (void)addGDPRViewConstraints {
    _gdprView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self setGDPRViewBottomConstraint];
    
    [_updatedConstraints addObjectsFromArray:@[
                                               [NSLayoutConstraint constraintWithItem:_gdprView
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollContainerView
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1.0
                                                                             constant:0.0],
                                               [NSLayoutConstraint constraintWithItem:_gdprView
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollContainerView
                                                                            attribute:NSLayoutAttributeRight
                                                                           multiplier:1.0
                                                                             constant:0.0],
                                               _gdprViewBottomConstraint
                                               ]];
}

- (void)setupScrollContainerView {
    if (!_scrollContainerView) {
        _scrollContainerView = [UIView new];
    }
    [_scrollView addSubview:_scrollContainerView];
}

- (void)setupUpdatedConstraints {
    _updatedConstraints = [[NSMutableArray alloc] init];
}

- (void)setupTopContentImageView {
    if (!_topContentImageView) {
        _topContentImageView = [UIImageView new];
    }
    _topContentImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_topContentImageView setBackgroundColor:ORKColor(ORKTopContentImageViewBackgroundColorKey)];
    [self addSubview:_topContentImageView];
    [self setTopContentImageViewConstraints];
}

- (void)setupTitleLabel {
    if (!_titleLabel) {
        _titleLabel = [ORKTitleLabel new];
    }
    [_scrollContainerView addSubview:_titleLabel];
    [self setupTitleLabelConstraints];
}

- (void)setupIconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
    }
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollContainerView addSubview:_iconImageView];
    [self setIconImageViewConstraints];
}

- (void)setupBodyContainerView {
    __weak id<ORKBodyContainerViewDelegate> weakSelf = self;
    if (!_bodyContainerView) {
        _bodyContainerView = [[ORKBodyContainerView alloc] initWithBodyItems:_bodyItems
                                                                    delegate:weakSelf];
    }
    [_scrollContainerView addSubview:_bodyContainerView];
    [self setupBodyContainerViewConstraints];
}

- (void)setCustomContentView:(UIView *)customContentView {
    _customContentView = customContentView;
    [_scrollContainerView addSubview:_customContentView];
    [self setupCustomContentViewConstraints];
}

- (void)setupNavigationContainerView {
    if (!_navigationFooterView) {
        _navigationFooterView = [ORKNavigationContainerView new];
    }
    [_navigationFooterView removeStyling];
    [self placeNavigationContainerView];
}

- (void)removeNavigationFooterView {
    [_navigationFooterView removeFromSuperview];
    if (_navigationContainerViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:_navigationContainerViewConstraints];
        for (NSLayoutConstraint *constraint in _navigationContainerViewConstraints) {
            if ([_updatedConstraints containsObject:constraint]) {
                [_updatedConstraints removeObject:constraint];
            }
        }
        _navigationContainerViewConstraints = nil;
    }
}

- (void)placeNavigationContainerView {
    [self removeNavigationFooterView];
    if (_isNavigationContainerScrollable) {
        [_scrollContainerView addSubview:_navigationFooterView];
    }
    else {
        [self addSubview:_navigationFooterView];
    }
    [self setupNavigationContainerViewConstraints];
}

- (void)setupNavigationContainerViewConstraints {
    _navigationFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _navigationContainerViewConstraints = @[
                                              [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_isNavigationContainerScrollable ? _scrollContainerView : self
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                                                           attribute:NSLayoutAttributeLeft
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_isNavigationContainerScrollable ? _scrollContainerView : self
                                                                           attribute:NSLayoutAttributeLeft
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_isNavigationContainerScrollable ? _scrollContainerView : self
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0
                                                                            constant:0.0]];
    [_updatedConstraints addObjectsFromArray:_navigationContainerViewConstraints];

    if (!_isNavigationContainerScrollable) {
        [NSLayoutConstraint deactivateConstraints:@[_scrollViewBottomConstraint]];
        if ([_updatedConstraints containsObject:_scrollViewBottomConstraint]) {
            [_updatedConstraints removeObject:_scrollViewBottomConstraint];
        }
        _scrollViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_scrollView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_navigationFooterView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:0.0];
        [_updatedConstraints addObject:_scrollViewBottomConstraint];
    }
    if (_gdprView) {
        [self deactivateGDPRViewBottomConstraint];
        [self setGDPRViewBottomConstraint];
        [_updatedConstraints addObject:_gdprViewBottomConstraint];
    }
    
    [self setNeedsUpdateConstraints];
}

- (void)pinNavigationContainerToBottom {
    _isNavigationContainerScrollable = NO;
    [self placeNavigationContainerView];
}

- (void)setupCustomContentViewConstraints {
    _customContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setCustomContentViewTopConstraint];
    [_updatedConstraints addObjectsFromArray:@[
                                               _customContentViewTopConstraint,
                                               [NSLayoutConstraint constraintWithItem:_customContentView
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollContainerView
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1.0
                                                                             constant:0.0],
                                               [NSLayoutConstraint constraintWithItem:_customContentView
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollContainerView
                                                                            attribute:NSLayoutAttributeRight
                                                                           multiplier:1.0
                                                                             constant:0.0]
                                               ]];
    [self setNeedsUpdateConstraints];
}

- (void)setCustomContentViewTopConstraint {
    id topItem;
    NSLayoutAttribute attribute;
    
    if (_bodyContainerView) {
        topItem = _bodyContainerView;
        attribute = NSLayoutAttributeBottom;
    }
    else if (_titleLabel) {
        topItem = _titleLabel;
        attribute = NSLayoutAttributeBottom;
    }
    else if (_iconImageView) {
        topItem = _iconImageView;
        attribute = NSLayoutAttributeBottom;
    }
    else {
        topItem = _scrollContainerView;
        attribute = NSLayoutAttributeTop;
    }
    
    _customContentViewTopConstraint = [NSLayoutConstraint constraintWithItem:_customContentView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:topItem
                                                                   attribute:attribute
                                                                  multiplier:1.0
                                                                    constant:ORKStepContainerTopCustomContentPaddingStandard];
}

- (void)updateCustomContentViewTopConstraint {
    if (_customContentView) {
        if (_customContentViewTopConstraint && _customContentViewTopConstraint.isActive) {
            [NSLayoutConstraint deactivateConstraints:@[_customContentViewTopConstraint]];
        }
        if ([_updatedConstraints containsObject:_customContentViewTopConstraint]) {
            [_updatedConstraints removeObject:_customContentViewTopConstraint];
        }
        [self setCustomContentViewTopConstraint];
        if (_customContentViewTopConstraint) {
            [_updatedConstraints addObject:_customContentViewTopConstraint];
        }
    }
}

- (void)setBodyContainerViewTopConstraint {
    id topItem;
    CGFloat topPadding;
    NSLayoutAttribute attribute;
    
    if (_titleLabel) {
        topItem = _titleLabel;
        topPadding = _bodyItems.firstObject.bodyItemStyle == ORKBodyItemStyleText ? ORKStepContainerTitleToBodyTopPaddingForWindow(self.window) : ORKStepContainerTitleToBulletTopPaddingForWindow(self.window);
        attribute = NSLayoutAttributeBottom;
    }
    else if (_iconImageView) {
        topItem = _iconImageView;
        topPadding = _bodyItems.firstObject.bodyItemStyle == ORKBodyItemStyleText ? ORKStepContainerIconToBodyTopPaddingStandard : ORKStepContainerIconToBulletTopPaddingStandard;
        attribute = NSLayoutAttributeBottom;
    }
    else {
        topItem = _scrollContainerView;
        topPadding = ORKStepContainerFirstItemTopPaddingForWindow(self.window);
        attribute = NSLayoutAttributeTop;
    }
    
    
    _bodyContainerViewTopConstraint = [NSLayoutConstraint constraintWithItem:_bodyContainerView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:topItem
                                                                   attribute:attribute
                                                                  multiplier:1.0
                                                                    constant:topPadding];
}

- (void)updateBodyContainerViewTopConstraint {
    if (_bodyContainerView) {
        if (_bodyContainerViewTopConstraint && _bodyContainerViewTopConstraint.isActive) {
            [NSLayoutConstraint deactivateConstraints:@[_bodyContainerViewTopConstraint]];
        }
        if ([_updatedConstraints containsObject:_bodyContainerViewTopConstraint]) {
            [_updatedConstraints removeObject:_bodyContainerViewTopConstraint];
        }
        [self setBodyContainerViewTopConstraint];
        if (_bodyContainerViewTopConstraint) {
            [_updatedConstraints addObject:_bodyContainerViewTopConstraint];
        }
    }
}

- (void)setupBodyContainerViewConstraints {
    _bodyContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setBodyContainerViewTopConstraint];
    [_updatedConstraints addObjectsFromArray:@[
                                               _bodyContainerViewTopConstraint,
                                               [NSLayoutConstraint constraintWithItem:_bodyContainerView
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollContainerView
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1.0
                                                                             constant:0.0],
                                               [NSLayoutConstraint constraintWithItem:_bodyContainerView
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollContainerView
                                                                            attribute:NSLayoutAttributeRight
                                                                           multiplier:1.0
                                                                             constant:0.0]
                                               ]];
    [self setNeedsUpdateConstraints];
}

- (void)setupTitleLabelConstraints {
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self setTitleLabelTopConstraint];
    [_updatedConstraints addObjectsFromArray:@[
                                               _titleLabelTopConstraint,
                                               [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollContainerView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1.0
                                                                             constant:0.0],
                                               [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollContainerView
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.0
                                                                             constant:0.0]
                                               ]];
    [self setNeedsUpdateConstraints];
}

- (void)setIconImageViewConstraints {
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _iconImageViewConstraints = @[
                                  [NSLayoutConstraint constraintWithItem:_iconImageView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_scrollContainerView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:ORKStepContainerFirstItemTopPaddingForWindow(self.window)],
                                  [NSLayoutConstraint constraintWithItem:_iconImageView
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_scrollContainerView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0],
                                  [NSLayoutConstraint constraintWithItem:_iconImageView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0
                                                                constant:ORKStepContainerIconImageViewDimension],
                                  [NSLayoutConstraint constraintWithItem:_iconImageView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0
                                                                constant:ORKStepContainerIconImageViewDimension]];
    [_updatedConstraints addObjectsFromArray:_iconImageViewConstraints];
    [self setNeedsUpdateConstraints];
}

- (NSArray<NSLayoutConstraint *> *)scrollViewStaticConstraints {
    CGFloat leftRightPadding = ORKStepContainerLeftRightPaddingForWindow(self.window);
    _scrollViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_scrollView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0
                                                                constant:0.0];
    return @[
             [NSLayoutConstraint constraintWithItem:_scrollView
                                          attribute:NSLayoutAttributeLeft
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeLeft
                                         multiplier:1.0
                                           constant:leftRightPadding],
             [NSLayoutConstraint constraintWithItem:_scrollView
                                          attribute:NSLayoutAttributeRight
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeRight
                                         multiplier:1.0
                                           constant:-leftRightPadding],
             _scrollViewBottomConstraint
             ];
}

- (NSArray<NSLayoutConstraint *> *)scrollContainerStaticConstraints {
    return @[
             [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_scrollView
                                          attribute:NSLayoutAttributeTop
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                          attribute:NSLayoutAttributeLeft
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_scrollView
                                          attribute:NSLayoutAttributeLeft
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                          attribute:NSLayoutAttributeRight
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_scrollView
                                          attribute:NSLayoutAttributeRight
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                          attribute:NSLayoutAttributeBottom
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_scrollView
                                          attribute:NSLayoutAttributeBottom
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                          attribute:NSLayoutAttributeCenterX
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_scrollView
                                          attribute:NSLayoutAttributeCenterX
                                         multiplier:1.0
                                           constant:0.0]
             ];
}

- (void)setScrollViewTopConstraint {
    _scrollViewTopConstraint = [NSLayoutConstraint constraintWithItem:_scrollView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_topContentImageView ? : self
                                                                     attribute:_topContentImageView ? NSLayoutAttributeBottom : NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:_topContentImageView ? 0.0 : ORKStepContainerTopPaddingForWindow(self.window)];
    [_updatedConstraints addObject:_scrollViewTopConstraint];
}

- (void)updateScrollViewTopConstraint {
    if (_scrollViewTopConstraint) {
        [NSLayoutConstraint deactivateConstraints:@[_scrollViewTopConstraint]];
    }
    if ([_updatedConstraints containsObject:_scrollViewTopConstraint]) {
        [_updatedConstraints removeObject:_scrollViewTopConstraint];
    }
    [self setScrollViewTopConstraint];
}

- (void)deactivateIconImageViewConstraints {
    if (_iconImageViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:_iconImageViewConstraints];
    }
}

- (void)setTitleLabelTopConstraint {
    if (_titleLabel) {
        _titleLabelTopConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_iconImageView ? : _scrollContainerView
                                                                attribute:_iconImageView ? NSLayoutAttributeBottom : NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:_iconImageView ? ORKStepContainerIconImageViewToTitleLabelPadding : ORKStepContainerFirstItemTopPaddingForWindow(self.window)];
    }
}

- (void)updateTitleLabelTopConstraint {
    if (_titleLabelTopConstraint && _titleLabelTopConstraint.isActive) {
        [NSLayoutConstraint deactivateConstraints:@[_titleLabelTopConstraint]];
    }
    if ([_updatedConstraints containsObject:_titleLabelTopConstraint]) {
        [_updatedConstraints removeObject:_titleLabelTopConstraint];
    }
    [self setTitleLabelTopConstraint];
    if (_titleLabelTopConstraint) {
        [_updatedConstraints addObject:_titleLabelTopConstraint];
    }
}

- (void)setTopContentImageViewConstraints {
    _topContentImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _topContentImageViewConstraints = @[
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:ORKStepContainerTopContentHeightForWindow(self.window)]
                                        ];
    [_updatedConstraints addObjectsFromArray:_topContentImageViewConstraints];
}

- (void)deactivateTopContentImageViewConstraints {
    if (_topContentImageViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:_topContentImageViewConstraints];
    }
    _topContentImageViewConstraints = nil;
}

- (void)setupConstraints {
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self setScrollViewTopConstraint];
    NSMutableArray<NSLayoutConstraint *> *staticConstraints = [[NSMutableArray alloc] initWithArray:[self scrollViewStaticConstraints]];
    [staticConstraints addObject:_scrollViewTopConstraint];
    [staticConstraints addObjectsFromArray:[self scrollContainerStaticConstraints]];
    [NSLayoutConstraint activateConstraints:staticConstraints];
}

- (void)updateScrollContainerContentSizeConstraint {
    if (_scrollContainerContentSizeConstraint) {
        [NSLayoutConstraint deactivateConstraints:@[_scrollContainerContentSizeConstraint]];
    }
    //    FIXME: set bottom with Min height.
    //    TODO: Optimize.
    id topItem;
    id bottomItem;
    NSLayoutAttribute topItemAttribute;
    NSLayoutAttribute bottomItemAttribute;
    if (_customContentView) {
        topItem = _customContentView;
        topItemAttribute = NSLayoutAttributeBottom;
    }
    else if(_bodyContainerView) {
        topItem = _bodyContainerView;
        topItemAttribute = NSLayoutAttributeBottom;
    }
    else {
        topItem = _titleLabel;
        topItemAttribute = NSLayoutAttributeBottom;
    }
    
    if (_gdprView) {
        bottomItem = _gdprView;
        bottomItemAttribute = NSLayoutAttributeTop;
    }
    else if(_navigationFooterView) {
        bottomItem = _navigationFooterView;
        bottomItemAttribute = NSLayoutAttributeTop;
    }
    else {
        bottomItem = _scrollContainerView;
        bottomItemAttribute = NSLayoutAttributeBottom;
    }
    
    
    _scrollContainerContentSizeConstraint = [NSLayoutConstraint constraintWithItem:bottomItem
                                                                         attribute:bottomItemAttribute
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:topItem
                                                                         attribute:topItemAttribute
                                                                        multiplier:1.0
                                                                          constant:0.0];
}

- (void)updateContainerConstraints {
    [self updateScrollContainerContentSizeConstraint];
    [_updatedConstraints addObject:_scrollContainerContentSizeConstraint];
    [NSLayoutConstraint activateConstraints:_updatedConstraints];
    [_updatedConstraints removeAllObjects];
}

- (void)updateConstraints {
    [self updateContainerConstraints];
    [super updateConstraints];
}

#pragma mark - ORKBodyContainerViewDelegate

- (void)bodyContainerLearnMoreButtonPressed:(ORKLearnMoreInstructionStep *)learnMoreStep {
    [_delegate stepContainerLearnMoreButtonPressed:learnMoreStep];
}

#pragma mark - ORKGDPRViewLearnMoreDelegate

- (void)gdprViewLearnMoreButtonPressed:(ORKLearnMoreInstructionStep *)learnMoreStep {
    [_delegate stepContainerLearnMoreButtonPressed:learnMoreStep];
}

@end
