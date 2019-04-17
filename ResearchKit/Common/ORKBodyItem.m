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


#import "ORKBodyItem.h"
#import "ORKLearnMoreInstructionStep.h"
#import "ORKHelpers_Internal.h"


@interface ORKLearnMoreItem()

@property (nonatomic) NSString *text;

@end

@implementation ORKLearnMoreItem

- (instancetype)initWithText:(NSString *)text learnMoreInstructionStep:(ORKLearnMoreInstructionStep *)learnMoreInstructionStep {
    self = [super init];
    if (self) {
        self.text = text;
        self.learnMoreInstructionStep = learnMoreInstructionStep;
    }
    return self;
}

+ (instancetype)learnMoreLinkItemWithText:(NSString *)text learnMoreInstructionStep:(ORKLearnMoreInstructionStep *)learnMoreInstructionStep {
    return [[ORKLearnMoreItem alloc] initWithText:text learnMoreInstructionStep:learnMoreInstructionStep];
}

+ (instancetype)learnMoreDetailDisclosureItemWithLearnMoreInstructionStep:(ORKLearnMoreInstructionStep *)learnMoreInstructionStep {
    return [[ORKLearnMoreItem alloc] initWithText:nil learnMoreInstructionStep:learnMoreInstructionStep];
}

- (NSString *)getText {
    return _text;
}


@end

@implementation ORKBodyItem

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithTitle:(NSString *)title text:(NSString *)text image:(nullable UIImage *)image learnMoreItem:(nullable ORKLearnMoreItem *)learnMoreItem bodyItemStyle:(ORKBodyItemStyle)bodyItemStyle {
    self = [super init];
    if (self) {
        self.title = title;
        self.text = text;
        self.learnMoreItem = learnMoreItem;
        self.bodyItemStyle = bodyItemStyle;
        self.image = image;
    }
    [self validateParameters];
    return self;
}

+ (ORKBodyItem *)bulletPointItemWithTitle:(nullable NSString *)title text:(nullable NSString *)text learnMoreItem:(nullable ORKLearnMoreItem *)learnMoreItem{
    return [[ORKBodyItem alloc] initWithTitle:title text:text image:nil learnMoreItem:learnMoreItem bodyItemStyle:ORKBodyItemStyleBulletPoint];
}

+ (ORKBodyItem *)textItemWithTitle:(nullable NSString *)title text:(nullable NSString *)text learnMoreItem:(nullable ORKLearnMoreItem *)learnMoreItem{
    return [[ORKBodyItem alloc] initWithTitle:title text:text image:nil learnMoreItem:learnMoreItem bodyItemStyle:ORKBodyItemStyleText];
}

+ (ORKBodyItem *)imageItemWithTitle:(nullable NSString *)title text:(nullable NSString *)text image:(nonnull UIImage *)image learnMoreItem:(nullable ORKLearnMoreItem *)learnMoreItem{
     return [[ORKBodyItem alloc] initWithTitle:title text:text image:image learnMoreItem:learnMoreItem bodyItemStyle:ORKBodyItemStyleImage];
}

- (void)validateParameters {
    if (!_title && !_text) {
        NSAssert(NO, @"Parameters title and text cannot be both nil.");
    }
}

@end
