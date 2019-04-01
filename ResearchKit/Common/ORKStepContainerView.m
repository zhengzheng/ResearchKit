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


static const CGFloat ORKStepContainerIconImageViewDimension = 80.0;
static const CGFloat ORKStepContainerIconImageViewToTitleLabelPadding = 20.0;
static const CGFloat ORKStepContainerIconToBodyTopPaddingStandard = 20.0;
static const CGFloat ORKStepContainerIconToBulletTopPaddingStandard = 20.0;

@implementation ORKStepContainerView {
    
    UIScrollView *_scrollView;
    UIView *_scrollContainerView;
    
    ORKTitleLabel *_titleLabel;
    UIImageView *_topContentImageView;
    UIImageView *_iconImageView;
    ORKBodyContainerView *_bodyContainerView;
    
//    variable constraints:
    NSLayoutConstraint *_scrollViewTopConstraint;
    NSLayoutConstraint *_titleLabelTopConstraint;
    NSLayoutConstraint *_bodyContainerViewTopConstraint;
    
    NSLayoutConstraint *_scrollContainerContentSizeConstraint;
    NSArray<NSLayoutConstraint *> *_topContentImageViewConstraints;
    NSArray<NSLayoutConstraint *> *_iconImageViewConstraints;
    
    NSMutableArray<NSLayoutConstraint *> *_updatedConstraints;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupScrollView];
        [self setupScrollContainerView];
        [self setupConstraints];
        [self setupUpdatedConstraints];
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
        _topContentImageView.image = stepTopContentImage;
        [self updateScrollViewTopConstraint];
        [self setNeedsUpdateConstraints];
    }
    
    //    3.) >= second Image;
    if (stepTopContentImage && _topContentImageView) {
        _topContentImageView.image = stepTopContentImage;
    }
}

- (void)setStepTitle:(NSString *)stepTitle {
    _stepTitle = stepTitle;
    if (!_titleLabel) {
        [self setupTitleLabel];
        [self updateBodyContainerViewTopConstraint];
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
        [self setNeedsUpdateConstraints];
    }
    if (titleIconImage && !_iconImageView) {
        [self setupIconImageView];
        _iconImageView.image = titleIconImage;
        [self updateTitleLabelTopConstraint];
        [self updateBodyContainerViewTopConstraint];
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
    if (!_bodyContainerView) {
        _bodyContainerView = [[ORKBodyContainerView alloc] initWithBodyItems:_bodyItems];
    }
    [_scrollContainerView addSubview:_bodyContainerView];
    [self setupBodyContainerViewConstraints];
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
             [NSLayoutConstraint constraintWithItem:_scrollView
                                          attribute:NSLayoutAttributeBottom
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeBottom
                                         multiplier:1.0
                                           constant:0.0]
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
}

- (void)updateScrollViewTopConstraint {
    if (_scrollViewTopConstraint) {
        [NSLayoutConstraint deactivateConstraints:@[_scrollViewTopConstraint]];
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
    //    FIXME: set bottom Instead of height.
    _scrollContainerContentSizeConstraint = [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1.0
                                                                          constant:3000.0];
}

- (void)updateContainerConstraints {
    
    if (_topContentImageViewConstraints) {
        [_updatedConstraints addObjectsFromArray:_topContentImageViewConstraints];
    }
    [_updatedConstraints addObject:_scrollViewTopConstraint];
    [self updateScrollContainerContentSizeConstraint];
    [_updatedConstraints addObject:_scrollContainerContentSizeConstraint];
    [NSLayoutConstraint activateConstraints:_updatedConstraints];
    [_updatedConstraints removeAllObjects];
}

- (void)updateConstraints {
    [self updateContainerConstraints];
    [super updateConstraints];
}

@end
