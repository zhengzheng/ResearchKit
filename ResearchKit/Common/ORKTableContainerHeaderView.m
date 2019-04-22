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


#import "ORKTableContainerHeaderView.h"
#import "ORKTitleLabel.h"
#import "ORKBodyItem.h"
#import "ORKBodyContainerView.h"
#import "ORKSkin.h"
#import "ORKNavigationContainerView_Internal.h"


static const CGFloat ORKTableContainerHeaderIconImageViewDimension = 80.0;
static const CGFloat ORKTableContainerHeaderIconImageViewToTitleLabelPadding = 20.0;
static const CGFloat ORKTableContainerHeaderIconToBodyTopPaddingStandard = 20.0;
static const CGFloat ORKTableContainerHeaderIconToBulletTopPaddingStandard = 20.0;

@interface ORKTableContainerHeaderView()<ORKBodyContainerViewDelegate>

@end

@implementation ORKTableContainerHeaderView {
    
    UIView *_scrollContainerView;
    
    ORKTitleLabel *_titleLabel;
    UIImageView *_topContentImageView;
    UIImageView *_iconImageView;
    ORKBodyContainerView *_bodyContainerView;
    
    //    variable constraints:
    
    NSLayoutConstraint *_scrollContainerTopConstraint;
    
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
        [self updateScrollContainerTopConstraint];
        [self setNeedsUpdateConstraints];
    }
    
    //    2.) First Image; updateConstraints
    if (stepTopContentImage && !_topContentImageView) {
        [self setupTopContentImageView];
        _topContentImageView.image = [self topContentAndAuxiliaryImage];
        [self updateScrollContainerTopConstraint];
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
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
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



- (void)setupScrollContainerView {
    if (!_scrollContainerView) {
        _scrollContainerView = [UIView new];
    }
    [self addSubview:_scrollContainerView];
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
        topPadding = _bodyItems.firstObject.bodyItemStyle == ORKBodyItemStyleText ? ORKTableContainerHeaderIconToBodyTopPaddingStandard : ORKTableContainerHeaderIconToBulletTopPaddingStandard;
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
                                                                constant:ORKTableContainerHeaderIconImageViewDimension],
                                  [NSLayoutConstraint constraintWithItem:_iconImageView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0
                                                                constant:ORKTableContainerHeaderIconImageViewDimension]];
    [_updatedConstraints addObjectsFromArray:_iconImageViewConstraints];
    [self setNeedsUpdateConstraints];
}

- (NSArray<NSLayoutConstraint *> *)scrollContainerStaticConstraints {
    [self setScrollContainerTopConstraint];
    return @[_scrollContainerTopConstraint,
             [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                          attribute:NSLayoutAttributeLeft
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeLeft
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                          attribute:NSLayoutAttributeRight
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeRight
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:self
                                          attribute:NSLayoutAttributeBottom
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_scrollContainerView
                                          attribute:NSLayoutAttributeBottom
                                         multiplier:1.0
                                           constant:0.0]
             ];
}

- (void)setScrollContainerTopConstraint {
    if (_scrollContainerTopConstraint && _scrollContainerTopConstraint.isActive) {
        [NSLayoutConstraint deactivateConstraints:@[_scrollContainerTopConstraint]];
    }
    if (_updatedConstraints && [_updatedConstraints containsObject:_scrollContainerTopConstraint]) {
        [_updatedConstraints removeObject:_scrollContainerTopConstraint];
    }
    _scrollContainerTopConstraint = [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_topContentImageView ? : self
                                                                 attribute:_topContentImageView ? NSLayoutAttributeBottom : NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:0.0];
}

- (void)updateScrollContainerTopConstraint {
    [self setScrollContainerTopConstraint];
    [_updatedConstraints addObject:_scrollContainerTopConstraint];
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
                                                                 constant:_iconImageView ? ORKTableContainerHeaderIconImageViewToTitleLabelPadding : ORKStepContainerFirstItemTopPaddingForWindow(self.window)];
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
    _scrollContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:[self scrollContainerStaticConstraints]];
}

- (void)updateScrollContainerContentSizeConstraint {
    if (_scrollContainerContentSizeConstraint) {
        [NSLayoutConstraint deactivateConstraints:@[_scrollContainerContentSizeConstraint]];
    }
    //    FIXME: set bottom with Min height.
    //    TODO: Optimize.
    id topItem;
    NSLayoutAttribute topItemAttribute;
    if(_bodyContainerView) {
        topItem = _bodyContainerView;
        topItemAttribute = NSLayoutAttributeBottom;
    }
    else if (_titleLabel) {
        topItem = _titleLabel;
        topItemAttribute = NSLayoutAttributeBottom;
    }
    
    else {
        topItem = self;
        topItemAttribute = NSLayoutAttributeTop;
    }
    
    _scrollContainerContentSizeConstraint = [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                                                         attribute:NSLayoutAttributeBottom
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
    [_delegate tableContainerHeaderLearnMoreButtonPressed:learnMoreStep];
}

@end
