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


#import "ORKGDPRView.h"
#import "ORKLearnMoreView.h"
#import "ORKSkin.h"

static const CGFloat IconImageViewWidth = 50.0;
static const CGFloat IconImageViewHeight = 40.0;
static const CGFloat IconImageToTextPadding = 6.0;

@interface ORKGDPRView()<ORKLearnMoreViewDelegate>

@end

@implementation ORKGDPRView {
    UIImageView *_iconImageView;
    UILabel *_textLabel;
    ORKLearnMoreView *_learnMoreView;
    
}

- (id)initWithIconImage:(UIImage *)iconImage
                   text:(nonnull NSString *)text
          learnMoreItem:(nonnull ORKLearnMoreItem *)learnMoreItem {
    self = [super init];
    if (self) {
        self.iconImage = iconImage;
        self.text = text;
        self.learnMoreItem = learnMoreItem;
    }
    self.axis = UILayoutConstraintAxisVertical;
    self.alignment = UIStackViewAlignmentCenter;
    [self setupIconImageView];
    [self setupTextlabel];
    [self setupLearnMoreView];
    [self addViews];
    return self;
}

- (void)setupIconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
    }
    _iconImageView.image = _iconImage;
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self setupIconImageViewConstraints];
}

- (void)setupIconImageViewConstraints {
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [NSLayoutConstraint constraintWithItem:_iconImageView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:IconImageViewHeight],
                                              [NSLayoutConstraint constraintWithItem:_iconImageView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:IconImageViewWidth]
                                              ]];
}

+ (UIFont *)textFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCaption2];
    return [UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
    
}

- (void)setupTextlabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
    }
    _textLabel.text = _text;
    _textLabel.font = [ORKGDPRView textFont];
    [_textLabel setTextColor:ORKColor(ORKBulletItemTextColorKey)];
    _textLabel.numberOfLines = 0;
    _textLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setupLearnMoreView {
    if (!_learnMoreView) {
        _learnMoreView = [ORKLearnMoreView learnMoreViewWithItem:_learnMoreItem];
    }
    _learnMoreView.delegate = self;
}

- (void)addViews {
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _learnMoreView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addArrangedSubview:_iconImageView];
    [self addArrangedSubview:_textLabel];
    [self addArrangedSubview:_learnMoreView];
    
    [self setCustomSpacing:IconImageToTextPadding afterView:_iconImageView];
}

#pragma mark - ORKLearnMoreViewDelegate

- (void)learnMoreButtonPressedWithStep:(ORKLearnMoreInstructionStep *)learnMoreStep {
    [_delegate gdprViewLearnMoreButtonPressed:learnMoreStep];
}

@end
