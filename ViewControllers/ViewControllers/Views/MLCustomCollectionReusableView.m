//
//  MLCustomCollectionReusableView.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLCustomCollectionReusableView.h"

#pragma mark - MLCustomCollectionReusableView

@interface MLCustomCollectionReusableView ()

@property (nonatomic, readwrite, strong) IBOutlet UILabel * textLabel;

@end

#pragma mark -

@implementation MLCustomCollectionReusableView

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
        [self addSubview:_textLabel];
        NSDictionary * views = @{@"textLabel" : _textLabel};
        NSDictionary * sizes = @{@"margin" : @(5.0f)};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[textLabel]-margin-|" options:0 metrics:sizes views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[textLabel]-margin-|" options:0 metrics:sizes views:views]];
    }
    
    self.backgroundColor = [UIColor lightGrayColor];
}

#pragma mark Prepare For Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.textLabel.text = nil;
}

@end
