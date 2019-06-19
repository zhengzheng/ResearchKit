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

#import "ORKTaskReviewViewController.h"
#import "ORKStepView_Private.h"
#import "ORKTableContainerView.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepContentView_Private.h"
#import "ORKStep.h"
#import "ORKFormStep.h"
#import "ORKQuestionStep.h"
#import "ORKCollectionResult.h"
#import "ORKQuestionResult_Private.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKSurveyCardHeaderView.h"
#import "ORKChoiceViewCell_Internal.h"
#import "ORKSkin.h"

@interface ORKReviewItem : NSObject
@property (nonatomic) NSString *question;
@property (nonatomic, nullable) NSString *answer;
@end

@implementation ORKReviewItem
@end

@interface ORKReviewSection : NSObject
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *stepIdentifier;
@property (nonatomic) NSArray <ORKReviewItem *> *items;
@end

@implementation ORKReviewSection
@end

@interface ORKReviewCell : UITableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier question:(NSString *)question answer:(NSString *) answer;
@end

@implementation ORKReviewCell {
    NSString *_question;
    NSString *_answer;
    
    UILabel *_questionLabel;
    UILabel *_answerLabel;
    
    UIView *_containerView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier question:(NSString *)question answer:(NSString *)answer {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _question = question;
        _answer = answer;
        [self setupContainerView];
        [self setupLabels];
        [self setupConstraints];
        [self setBackgroundColor:UIColor.clearColor];
    }
    return self;
}

- (void)setupContainerView {
    if (!_containerView) {
        _containerView = [UIView new];
    }
    _containerView.backgroundColor = UIColor.whiteColor;
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_containerView];
}

- (void)setupLabels {
    if (!_questionLabel) {
        _questionLabel = [UILabel new];
    }
    if (!_answerLabel) {
        _answerLabel = [UILabel new];
    }
    _questionLabel.numberOfLines = 0;
    _questionLabel.textAlignment = NSTextAlignmentLeft;
    
    _answerLabel.numberOfLines = 0;
    _answerLabel.textAlignment = NSTextAlignmentRight;
    
    _questionLabel.text = _question;
    _answerLabel.text = _answer;
    if (!_answer) {
        _answerLabel.textColor = UIColor.lightGrayColor;
        //        TODO: Localize
        _answerLabel.text = @"Skipped";
    }
    
    [_containerView addSubview:_questionLabel];
    [_containerView addSubview:_answerLabel];
    _questionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _answerLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setupConstraints {
    [[_containerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0.5] setActive:YES];
    [[_containerView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:ORKCardLeftRightMarginForWindow(self.window)] setActive:YES];
    [[_containerView.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:-ORKCardLeftRightMarginForWindow(self.window)] setActive:YES];
    
    [[_questionLabel.topAnchor constraintEqualToAnchor:_containerView.topAnchor constant:ORKSurveyItemMargin] setActive:YES];
    [[_questionLabel.leadingAnchor constraintEqualToAnchor:_containerView.leadingAnchor constant:ORKSurveyItemMargin] setActive:YES];
    [[_questionLabel.widthAnchor constraintEqualToAnchor:_containerView.widthAnchor multiplier:0.5] setActive:YES];

    [[_answerLabel.topAnchor constraintEqualToAnchor:_containerView.topAnchor constant:ORKSurveyItemMargin] setActive:YES];
    [[_answerLabel.trailingAnchor constraintEqualToAnchor:_containerView.trailingAnchor constant:-ORKSurveyItemMargin] setActive:YES];
    [[_answerLabel.widthAnchor constraintEqualToAnchor:_containerView.widthAnchor multiplier:0.5] setActive:YES];
    
    [[_containerView.bottomAnchor constraintGreaterThanOrEqualToAnchor:_questionLabel.bottomAnchor constant:ORKSurveyItemMargin] setActive:YES];
    [[_containerView.bottomAnchor constraintGreaterThanOrEqualToAnchor:_answerLabel.bottomAnchor constant:ORKSurveyItemMargin] setActive:YES];
    
    [[self.contentView.bottomAnchor constraintEqualToAnchor:_containerView.bottomAnchor] setActive:YES];
}

@end

@interface ORKReviewSectionFooter : UIView
@property (nonatomic) UIButton *button;
@end

@implementation ORKReviewSectionFooter {
    UIView *_containerView;
    UIView *_roundedView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupContainerView];
        [self setupRoundedView];
        [self setupButton];
        [self setupConstraints];
    }
    return self;
}

- (void)setupContainerView {
    if (!_containerView) {
        _containerView = [UIView new];
    }
    
    _containerView.backgroundColor = UIColor.whiteColor;
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:_containerView];
}

- (void)setupRoundedView {
    if (!_roundedView) {
        _roundedView = [UIView new];
    }
    _roundedView.backgroundColor = _containerView.backgroundColor;
    _roundedView.translatesAutoresizingMaskIntoConstraints = NO;
    _roundedView.layer.cornerRadius = ORKCardDefaultCornerRadii;
    [_containerView addSubview:_roundedView];
}

- (void)setupButton {
    if(!_button) {
        _button = [[UIButton alloc] init];
    }
    //    TODO: Localize
    [_button setTitle:@"Edit Answer" forState:UIControlStateNormal];
    [_button setTitleColor:self.tintColor forState:UIControlStateNormal];
    
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    [_containerView addSubview:_button];
}

- (void)setupConstraints {
    //    TODO: replace padding constants
    [[_containerView.topAnchor constraintEqualToAnchor:self.topAnchor constant:1.0] setActive:YES];
    [[_containerView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:ORKSurveyItemMargin+2.0] setActive:YES];
    [[_containerView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-ORKSurveyItemMargin-2.0] setActive:YES];
    [[_button.topAnchor constraintEqualToAnchor:_containerView.topAnchor constant:ORKSurveyItemMargin] setActive:YES];
    [[_button.centerXAnchor constraintEqualToAnchor:_containerView.centerXAnchor] setActive:YES];
    [[_containerView.bottomAnchor constraintEqualToAnchor:_button.bottomAnchor constant:ORKSurveyItemMargin] setActive:YES];
    [[_roundedView.heightAnchor constraintEqualToConstant:2*ORKCardDefaultCornerRadii] setActive:YES];
    [[_roundedView.centerYAnchor constraintEqualToAnchor:_containerView.bottomAnchor] setActive:YES];
    [[_roundedView.leftAnchor constraintEqualToAnchor:_containerView.leftAnchor] setActive:YES];
    [[_roundedView.rightAnchor constraintEqualToAnchor:_containerView.rightAnchor] setActive:YES];
    
    
    [[self.bottomAnchor constraintEqualToAnchor:_containerView.bottomAnchor constant:50.0] setActive:YES];
}



@end

@interface ORKTaskReviewViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, nonnull) ORKTableContainerView *tableContainerView;
@property (nonatomic) NSMutableArray<ORKReviewSection *> *reviewSections;
@property (nonatomic) id<ORKTaskResultSource> resultSource;
@property (nonatomic, nonnull) NSArray<ORKStep *> *steps;

@end

@implementation ORKTaskReviewViewController {
    ORKNavigationContainerView *_navigationFooterView;
}

- (instancetype)initWithResultSource:(id<ORKTaskResultSource>)resultSource forSteps:(NSArray<ORKStep *> *)steps {
    self = [super init];
    if (self) {
        _steps = steps;
        _resultSource = resultSource;
        [self createReviewSectionsWithDefaultResultSource:resultSource];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableContainerView];
    [self setupNavigationFooterView];
    _tableContainerView.stepTitle = @"Medical History";
    _tableContainerView.stepContentView.stepText = @"These questions detail your current and historical medical conditions. The answers on this list are shared as a whole with a study that you share it with.";
    [_tableContainerView setNeedsLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_tableContainerView sizeHeaderToFit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableContainerView layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_tableContainerView sizeHeaderToFit];
    [self.view layoutSubviews];
}

- (void)setupTableContainerView {
    if (!_tableContainerView) {
        _tableContainerView = [ORKTableContainerView new];
        _tableContainerView.tableView.dataSource = self;
        _tableContainerView.tableView.delegate = self;
        _tableContainerView.tableView.clipsToBounds = YES;
        _tableContainerView.tableView.rowHeight = UITableViewAutomaticDimension;
        _tableContainerView.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        _tableContainerView.tableView.sectionFooterHeight = UITableViewAutomaticDimension;
        _tableContainerView.tableView.estimatedRowHeight = ORKGetMetricForWindow(ORKScreenMetricTableCellDefaultHeight, self.view.window);
        _tableContainerView.tableView.estimatedSectionHeaderHeight = 30.0;
        _tableContainerView.tableView.estimatedSectionFooterHeight = 30.0;
        _tableContainerView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    }
    [self.view addSubview:_tableContainerView];
    _tableContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [[_tableContainerView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[_tableContainerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    [[_tableContainerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
    [[_tableContainerView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
}

- (void)setupNavigationFooterView {
    _navigationFooterView = _tableContainerView.navigationFooterView;
    [_navigationFooterView removeStyling];
    _navigationFooterView.skipButtonItem = nil;
    _navigationFooterView.continueEnabled = YES;
    //    TODO: Localize
    _navigationFooterView.continueButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped)];
}

- (void)createReviewSectionsWithDefaultResultSource:(id<ORKTaskResultSource>)defaultResultSource {
    _reviewSections = nil;
    _reviewSections = [[NSMutableArray alloc] init];
    for (ORKStep *step in _steps) {
        if ([step isKindOfClass:[ORKFormStep class]]) {
            ORKFormStep *formStep = (ORKFormStep *)step;
            ORKStepResult *result = [defaultResultSource stepResultForStepIdentifier:formStep.identifier];
            if (result) {
                [_reviewSections addObject:[self reviewSectionForFormStep:formStep withResult:result]];
            }
        }
        else if ([step isKindOfClass:[ORKQuestionStep class]]) {
            ORKQuestionStep *questionStep = (ORKQuestionStep *)step;
            ORKStepResult *result = [defaultResultSource stepResultForStepIdentifier:questionStep.identifier];
            if (result) {
                [_reviewSections addObject:[self reviewSectionForQuestionStep:questionStep withResult:result]];
            }
        }
    }
}

- (ORKReviewSection *)reviewSectionForFormStep:(ORKFormStep *)formStep withResult:(ORKStepResult *)result {
    if (formStep && formStep.formItems && result) {
        NSMutableArray <ORKReviewItem *> *formReviewItems = [[NSMutableArray alloc] init];
        for (ORKFormItem *formItem in formStep.formItems) {
            if (formItem.answerFormat) {
                ORKResult *formItemResult = [result resultForIdentifier:formItem.identifier];
                ORKReviewItem *formReviewItem = [[ORKReviewItem alloc] init];
                formReviewItem.question = formItem.text;
                formReviewItem.answer = [self answerStringForFormItem:formItem withFormItemResult:formItemResult];
                [formReviewItems addObject:formReviewItem];
            }
            else {
                // Use this for grouping form items without answer formats.
            }
        }
        ORKReviewSection *section = [[ORKReviewSection alloc] init];
        section.title = formStep.title;
        section.text = formStep.text;
        section.stepIdentifier = formStep.identifier;
        section.items = [formReviewItems copy];
        
        return section;
    }
    return nil;
}

- (NSString *)answerStringForFormItem:(ORKFormItem *)formItem withFormItemResult:(ORKResult *)formItemResult {
    NSString *answerString = nil;
    if (formItem && formItemResult && [formItemResult isKindOfClass:[ORKQuestionResult class]]) {
        ORKQuestionResult *questionResult = (ORKQuestionResult *)formItemResult;
        if (formItem.answerFormat && [questionResult isKindOfClass:formItem.answerFormat.questionResultClass] && questionResult.answer) {
            answerString = [formItem.answerFormat stringForAnswer:questionResult.answer];
        }
    }
    return answerString;
}

- (ORKReviewSection *)reviewSectionForQuestionStep:(ORKQuestionStep *)questionStep withResult:(ORKStepResult *)result {
    ORKReviewItem *item = [[ORKReviewItem alloc] init];
    item.question = questionStep.question;
    if (result.firstResult && [result.firstResult isKindOfClass:[ORKQuestionResult class]]) {
        ORKQuestionResult *questionResult = (ORKQuestionResult *)result.firstResult;
        item.answer = [self answerStringForQuestionStep:questionStep withQuestionResult:questionResult];
    }
    ORKReviewSection *section = [[ORKReviewSection alloc] init];
    section.title = questionStep.title;
    section.text = questionStep.text;
    section.stepIdentifier = questionStep.identifier;
    section.items = @[item];
    
    return section;
    
}

- (NSString *)answerStringForQuestionStep:(ORKQuestionStep *)questionStep withQuestionResult:(ORKQuestionResult *)questionResult {
    NSString *answerString = nil;
    if (questionStep && questionResult && questionStep.answerFormat && [questionResult isKindOfClass:questionStep.answerFormat.questionResultClass] && questionResult.answer) {
        answerString = [questionStep.answerFormat stringForAnswer:questionResult.answer];
    }
    return answerString;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _reviewSections ? _reviewSections.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _reviewSections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        ORKReviewCell *reviewCell = [[ORKReviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" question:_reviewSections[indexPath.section].items[indexPath.row].question answer:_reviewSections[indexPath.section].items[indexPath.row].answer];
        cell = reviewCell;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ORKSurveyCardHeaderView *cardHeaderView = (ORKSurveyCardHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@(section).stringValue];

    if (cardHeaderView == nil) {
        ORKReviewSection *reviewSection = _reviewSections[section];
        cardHeaderView = [[ORKSurveyCardHeaderView alloc] initWithTitle:reviewSection.title detailText:reviewSection.text learnMoreView:nil progressText:[NSString stringWithFormat:@"Page %@", @(section + 1).stringValue]];
    }
    
    return cardHeaderView;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ORKReviewSectionFooter *sectionFooter = (ORKReviewSectionFooter *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:[NSString stringWithFormat:@"Footer%@", @(section).stringValue]];
    if (!sectionFooter) {
        sectionFooter = [ORKReviewSectionFooter new];
        sectionFooter.button.tag = section;
        [sectionFooter.button addTarget:self action:@selector(footerButtonTappedForSection:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return sectionFooter;
}

- (nullable ORKStep *)stepForIdentifier:(NSString *)identifier {
    for (ORKStep *step in _steps) {
        return [step.identifier isEqualToString:identifier] ? step : nil;
    }
    return nil;
}

- (void)footerButtonTappedForSection:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(editAnswerTappedForStepWithIdentifier:)]) {
        [self.delegate editAnswerTappedForStepWithIdentifier:_reviewSections[button.tag].stepIdentifier];
    }
}

- (void)doneButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(doneButtonTappedWithResultSource:)]) {
        [self.delegate doneButtonTappedWithResultSource:_resultSource];
    }
}

#pragma mark - UItableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
