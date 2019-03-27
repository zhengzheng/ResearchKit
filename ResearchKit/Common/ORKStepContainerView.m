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

#import "ORKSkin.h"


@implementation ORKStepContainerView {
    
    UIView *_scrollableContainerView;
    UIView *_staticContainerView;
    
    ORKTitleLabel *_titleLabel;
    UIImageView *_topContentImageView;
    
//    variable constraints:
    NSLayoutConstraint *_scrollableContainerTopConstraint;
    NSArray<NSLayoutConstraint *> *_topContentImageViewConstraints;
    NSMutableArray<NSLayoutConstraint *> *_updatedConstraints;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupScrollableContainerView];
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
        [self updateScrollableContainerTopConstraint];
        [self setNeedsUpdateConstraints];
    }
    
    //    2.) First Image; updateConstraints
    if (stepTopContentImage && !_topContentImageView) {
        [self setupTopContentImageView];
        _topContentImageView.image = stepTopContentImage;
        [self updateScrollableContainerTopConstraint];
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
    }
    [_titleLabel setText:stepTitle];
}

- (void)setupScrollableContainerView {
    if (!_scrollableContainerView) {
        _scrollableContainerView = [[UIScrollView alloc] init];
    }
    [self addSubview:_scrollableContainerView];
}

- (void)setupUpdatedConstraints {
    _updatedConstraints = [[NSMutableArray alloc] init];
}

- (void)setupTopContentImageView {
    if (!_topContentImageView) {
        _topContentImageView = [UIImageView new];
    }
    [self addSubview:_topContentImageView];
    [self setTopContentImageViewConstraints];
}

- (void)setupTitleLabel {
    if (!_titleLabel) {
        _titleLabel = [ORKTitleLabel new];
    }
    [_scrollableContainerView addSubview:_titleLabel];
    [self setupTitleLabelConstraints];
}

- (void)setupTitleLabelConstraints {
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_updatedConstraints addObjectsFromArray:@[
                                               [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollableContainerView
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0
                                                                             constant:ORKStepContainerTitleLabelTopPaddingForWindow(self.window)],
                                               [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollableContainerView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1.0
                                                                             constant:0.0],
                                               [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollableContainerView
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.0
                                                                             constant:0.0]
                                               ]];
    [self setNeedsUpdateConstraints];
}

- (NSArray<NSLayoutConstraint *> *)scrollableContainerStaticConstraints {
    CGFloat leftRightPadding = ORKStepContainerLeftRightPaddingForWindow(self.window);
    return @[
             [NSLayoutConstraint constraintWithItem:_scrollableContainerView
                                          attribute:NSLayoutAttributeLeft
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeLeft
                                         multiplier:1.0
                                           constant:leftRightPadding],
             [NSLayoutConstraint constraintWithItem:_scrollableContainerView
                                          attribute:NSLayoutAttributeRight
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeRight
                                         multiplier:1.0
                                           constant:-leftRightPadding],
             [NSLayoutConstraint constraintWithItem:_scrollableContainerView
                                          attribute:NSLayoutAttributeCenterX
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeCenterX
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollableContainerView
                                          attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeHeight
                                         multiplier:1.0
                                           constant:0.0]
             ];
}

- (void)setScrollableContainerTopConstraint {
    _scrollableContainerTopConstraint = [NSLayoutConstraint constraintWithItem:_scrollableContainerView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_topContentImageView ? : self
                                                                     attribute:_topContentImageView ? NSLayoutAttributeBottom : NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:_topContentImageView ? 0.0 : ORKStepContainerTopPaddingForWindow(self.window)];
}

- (void)updateScrollableContainerTopConstraint {
    if (_scrollableContainerTopConstraint) {
        [NSLayoutConstraint deactivateConstraints:@[_scrollableContainerTopConstraint]];
    }
    [self setScrollableContainerTopConstraint];
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
    _scrollableContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self setScrollableContainerTopConstraint];
    NSMutableArray<NSLayoutConstraint *> *scrollableContainerConstraints = [[NSMutableArray alloc] initWithArray:[self scrollableContainerStaticConstraints]];
    [scrollableContainerConstraints addObject:_scrollableContainerTopConstraint];
    [NSLayoutConstraint activateConstraints:scrollableContainerConstraints];
}

- (void)updateContainerConstraints {
    
    if (_topContentImageViewConstraints) {
        [_updatedConstraints addObjectsFromArray:_topContentImageViewConstraints];
    }
    [_updatedConstraints addObject:_scrollableContainerTopConstraint];
    [NSLayoutConstraint activateConstraints:_updatedConstraints];
    [_updatedConstraints removeAllObjects];
}

- (void)updateConstraints {
    [self updateContainerConstraints];
    [super updateConstraints];
}

@end
