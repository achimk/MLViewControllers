//
//  MLContactTableViewCell.m
//  ViewControllers
//
//  Created by Joachim Kret on 26/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLContactTableViewCell.h"

#define MARGIN_VERTICAL     5.0f
#define MARGIN_HORIZONTAL   20.0f

#pragma mark - MLContactTableViewCell

@interface MLContactTableViewCell ()

@property (nonatomic, readwrite, strong) UILabel * labelName;
@property (nonatomic, readwrite, strong) UILabel * labelDate;
@property (nonatomic, readwrite, strong) UILabel * labelAbout;

@end

#pragma mark -

@implementation MLContactTableViewCell

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    //!!!: Fix for contentView constraint warnings
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    self.accessoryView = nil;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _labelName = [[UILabel alloc] init];
    _labelName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    _labelName.textColor = [UIColor blackColor];
    _labelName.numberOfLines = 1;
    _labelName.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_labelName];
    
    _labelDate = [[UILabel alloc] init];
    _labelDate.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f];
    _labelDate.textColor = [UIColor blackColor];
    _labelDate.numberOfLines = 1;
    _labelDate.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_labelDate];
    
    _labelAbout = [[UILabel alloc] init];
    _labelAbout.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    _labelAbout.textColor = [UIColor darkGrayColor];
    _labelAbout.numberOfLines = 0;
    _labelAbout.lineBreakMode = NSLineBreakByWordWrapping;
    _labelAbout.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_labelAbout];
    
    //Add Constraints
    NSDictionary * views = @{@"name"    : _labelName,
                             @"date"    : _labelDate,
                             @"about"   : _labelAbout};
    NSDictionary * sizes = @{@"marginH" : @(MARGIN_HORIZONTAL),
                             @"marginV" : @(MARGIN_VERTICAL)};
    
    // Horizontal constraints
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-marginH-[name]-marginH-|" options:0 metrics:sizes views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-marginH-[date]-marginH-|" options:0 metrics:sizes views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-marginH-[about]-marginH-|" options:0 metrics:sizes views:views]];
    
    // Vertical constraints
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-marginV-[name]-marginV-[date]-marginV-[about]-marginV-|" options:0 metrics:sizes views:views]];
    
    [self.contentView setNeedsUpdateConstraints];
    
    // Hugging/compression priorities
    // This is one of the most important aspects of having the cell size
    // itself. setContentCompressionResistancePriority needs to be set
    // for all labels to UILayoutPriorityRequired on the Vertical axis.
    // This prevents the label from shrinking to satisfy constraints and
    // will not cut off any text.
    // Setting setContentCompressionResistancePriority to UILayoutPriorityDefaultLow
    // for Horizontal axis makes sure it will shrink the width where needed.
    [self.labelName setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.labelName setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.labelDate setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.labelDate setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.labelAbout setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.labelAbout setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Set max layout width for all multi-line labels
    // This is required for any multi-line label. If you
    // do not set this, you'll find the auto-height will not work
    // this is because "intrinsicSize" of a label is equal to
    // the minimum size needed to fit all contents. So if you
    // do not have a max width it will not constrain the width
    // of the label when calculating height.
    self.labelAbout.preferredMaxLayoutWidth = self.contentView.bounds.size.width - MARGIN_HORIZONTAL * 2.0f;
}

#pragma mark Prepare For Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.labelName.text = nil;
    self.labelDate.text = nil;
    self.labelAbout.text = nil;
}

#pragma mark Configure

- (void)configureForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath type:(MLTableViewCellConfigureType)type {
    
    self.labelName.text = dataObject[@"name"];
    self.labelDate.text = dataObject[@"registered"];
    self.labelAbout.text = dataObject[@"about"];
}

@end
