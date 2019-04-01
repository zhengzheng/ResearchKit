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


#import "ORKBodyContainerView.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKBodyItem.h"
#import "ORKLearnMoreButton.h"


static const CGFloat ORKBodyToBodyPaddingStandard = 22.0;

static const CGFloat ORKBodyToBulletPaddingStandard = 37.0;
//static const CGFloat ORKBodyToBulletPaddingShort = 22.0;
//
//static const CGFloat ORKBulletToBulletPaddingGenerous = 36.0;
static const CGFloat ORKBulletToBulletPaddingStandard = 26.0;
//static const CGFloat ORKBulletToBulletPaddingShort = 22.0;

static const CGFloat ORKBodyTitleToBodyTextPaddingStandard = 6.0;
static const CGFloat ORKBodyTitleToLearnMoreButtonPaddingStandard = 15.0;
static const CGFloat ORKBodyTextToLearnMoreButtonPaddingStandard = 15.0;

static const CGFloat ORKBulletIconToBodyPadding = 14.0;
static const CGFloat ORKBulletStackLeftRightPadding = 10.0;

static NSString * ORKBulletUniCode = @"\u2981";


@interface ORKBodyItemView: UIStackView

- (instancetype)initWithBodyItem:(ORKBodyItem *)bodyItem;

@property (nonatomic, nonnull) ORKBodyItem *bodyItem;

@end

@implementation ORKBodyItemView

- (instancetype)initWithBodyItem:(ORKBodyItem *)bodyItem {
    self = [super init];
    if (self) {
        self.bodyItem = bodyItem;
        [self setupBodyStyleView];
        
    }
    return self;
}

- (void)setupBodyStyleView {
    if (_bodyItem.bodyItemStyle == ORKBodyItemStyleText) {
        [self setupBodyStyleTextView];
    }
    else {
        [self setupBodyStyleBulletPointView];
    }
}

+ (UIFont *)bodyTitleFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

+ (UIFont *)bodyTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    return [UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

+ (UIFont *)bulletIconFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    descriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitTightLeading | UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:descriptor size:0];
}

+ (UIFont *)bulletTitleFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold | UIFontDescriptorTraitLooseLeading)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

+ (UIFont *)bulletTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitLooseLeading)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
    
}

- (void)setupBodyStyleTextView {
    self.axis = UILayoutConstraintAxisVertical;
    self.distribution = UIStackViewDistributionFill;
    self.alignment = UIStackViewAlignmentLeading;
    UILabel *titleLabel;
    UILabel *textLabel;
    
    if (_bodyItem.title) {
        titleLabel = [UILabel new];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [ORKBodyItemView bodyTitleFont];
        titleLabel.text = _bodyItem.title;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addArrangedSubview:titleLabel];
    }
    if (_bodyItem.text) {
        textLabel = [UILabel new];
        textLabel.numberOfLines = 0;
        textLabel.font = [ORKBodyItemView bodyTextFont];
        textLabel.text = _bodyItem.text;
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addArrangedSubview:textLabel];
        if (titleLabel) {
            [self setCustomSpacing:ORKBodyTitleToBodyTextPaddingStandard afterView:titleLabel];
        }
    }
    if (_bodyItem.learnMoreItem) {
        ORKLearnMoreButton *learnMoreButton = [_bodyItem.learnMoreItem getText] ? [ORKLearnMoreButton learnMoreCustomButtonWithText:[_bodyItem.learnMoreItem getText] infoViewController:_bodyItem.learnMoreItem.infoViewController] : [ORKLearnMoreButton learnMoreDetailDisclosureButtonWithInfoViewController:_bodyItem.learnMoreItem.infoViewController];
        [learnMoreButton.titleLabel setFont:[ORKBodyItemView bodyTextFont]];
        learnMoreButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addArrangedSubview:learnMoreButton];
        if (textLabel) {
            [self setCustomSpacing:ORKBodyTextToLearnMoreButtonPaddingStandard afterView:textLabel];
        }
        else if (titleLabel) {
            [self setCustomSpacing:ORKBodyTitleToLearnMoreButtonPaddingStandard afterView:textLabel];
        }
    }
}

- (void)setupBodyStyleBulletPointView {
    self.axis = UILayoutConstraintAxisHorizontal;
    self.layoutMargins = UIEdgeInsetsMake(0.0, ORKBulletStackLeftRightPadding, 0.0, ORKBulletStackLeftRightPadding);
    [self setLayoutMarginsRelativeArrangement:YES];
    UILabel *bulletIcon = [self bulletIcon];
    [self addArrangedSubview:bulletIcon]; // Stack this in substack for vertical bullet icon.
    [self setCustomSpacing:ORKBulletIconToBodyPadding afterView:bulletIcon];
    [self addSubStackView];
}

- (UILabel *)bulletIcon {
    UILabel *bulletIconLabel = [UILabel new];
    bulletIconLabel.numberOfLines = 1;
    bulletIconLabel.font = [ORKBodyItemView bulletIconFont];
    [bulletIconLabel setText:ORKBulletUniCode];
    bulletIconLabel.translatesAutoresizingMaskIntoConstraints = NO;
    return bulletIconLabel;
}

- (void)addSubStackView {
    UIStackView *subStackView = [[UIStackView alloc] init];
    subStackView.axis = UILayoutConstraintAxisVertical;
    subStackView.distribution = UIStackViewDistributionFill;
    subStackView.alignment = UIStackViewAlignmentLeading;
    subStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addArrangedSubview:subStackView];
    UILabel *titleLabel;
    UILabel *textLabel;
    
    if (_bodyItem.title) {
        titleLabel = [UILabel new];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [ORKBodyItemView bulletTitleFont];
        titleLabel.text = _bodyItem.title;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [subStackView addArrangedSubview:titleLabel];
    }
    if (_bodyItem.text) {
        textLabel = [UILabel new];
        textLabel.numberOfLines = 0;
        textLabel.font = [ORKBodyItemView bulletTextFont];
        textLabel.text = _bodyItem.text;
        [textLabel setTextColor:ORKColor(ORKBulletItemTextColorKey)];
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [subStackView addArrangedSubview:textLabel];
    }
    if (_bodyItem.learnMoreItem) {
        ORKLearnMoreButton *learnMoreButton = [_bodyItem.learnMoreItem getText] ? [ORKLearnMoreButton learnMoreCustomButtonWithText:[_bodyItem.learnMoreItem getText] infoViewController:_bodyItem.learnMoreItem.infoViewController] : [ORKLearnMoreButton learnMoreDetailDisclosureButtonWithInfoViewController:_bodyItem.learnMoreItem.infoViewController];
        [learnMoreButton.titleLabel setFont:[ORKBodyItemView bulletTextFont]];
        learnMoreButton.translatesAutoresizingMaskIntoConstraints = NO;
        [subStackView addArrangedSubview:learnMoreButton];
    }
}


@end


@implementation ORKBodyContainerView

- (instancetype)initWithBodyItems:(NSArray<ORKBodyItem *> *)bodyItems {
    if (bodyItems && bodyItems.count <= 0) {
        NSAssert(NO, @"Body Items array cannot be empty");
    }
    self = [super init];
    if (self) {
        self.bodyItems = bodyItems;
        self.axis = UILayoutConstraintAxisVertical;
        self.distribution = UIStackViewDistributionFill;
        [self addBodyItemViews];
    }
    return self;
}

- (void)addBodyItemViews {
    NSArray<ORKBodyItemView *> *views = [ORKBodyContainerView bodyItemViewsWithBodyItems:_bodyItems];
    for (NSInteger i = 0; i < views.count; i++) {
        [self addArrangedSubview:views[i]];
        if (i < views.count - 1) {
            
            CGFloat padding = [self spacingWithAboveStyle:_bodyItems[i].bodyItemStyle belowStyle:_bodyItems[i + 1].bodyItemStyle];
            
            [self setCustomSpacing:padding afterView:views[i]];
        }
    }
}

- (CGFloat)spacingWithAboveStyle:(ORKBodyItemStyle )aboveStyle belowStyle:(ORKBodyItemStyle )belowStyle {
    if (aboveStyle == ORKBodyItemStyleText) {
        return belowStyle == ORKBodyItemStyleText ? ORKBodyToBodyPaddingStandard : ORKBodyToBulletPaddingStandard;
    }
    else {
        return belowStyle == ORKBodyItemStyleText ? ORKBodyToBulletPaddingStandard : ORKBulletToBulletPaddingStandard;
    }
}

+ (NSArray<ORKBodyItemView *> *)bodyItemViewsWithBodyItems:(NSArray<ORKBodyItem *> *)bodyItems {
    NSMutableArray<ORKBodyItemView *> *viewsArray = [[NSMutableArray alloc] init];
    [bodyItems enumerateObjectsUsingBlock:^(ORKBodyItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ORKBodyItemView *itemView = [[ORKBodyItemView alloc] initWithBodyItem:obj];
        itemView.translatesAutoresizingMaskIntoConstraints = NO;
        [viewsArray addObject:itemView];
    }];
    return [viewsArray copy];
}

@end
