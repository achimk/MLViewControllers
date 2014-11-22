//
//  MLCustomCollectionViewCell.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLCustomCollectionViewCell.h"

#pragma mark - MLCustomCollectionViewCell

@interface MLCustomCollectionViewCell ()

@property (nonatomic, readwrite, strong) IBOutlet UILabel * textLabel;

@end

#pragma mark -

@implementation MLCustomCollectionViewCell

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.numberOfLines = 1;
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_textLabel];
        NSDictionary * views = @{@"textLabel" : _textLabel};
        NSDictionary * sizes = @{@"margin" : @(5.0f)};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[textLabel]-margin-|" options:0 metrics:sizes views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[textLabel]-margin-|" options:0 metrics:sizes views:views]];
    }
    
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [UIColor lightGrayColor];
}

#pragma mark Prepare For Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.textLabel.text = nil;
}

@end
