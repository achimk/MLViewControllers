//
//  MLLoadingCollectionViewCell.m
//  ViewControllers
//
//  Created by Joachim Kret on 24.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLLoadingCollectionViewCell.h"

#pragma mark - MLLoadingCollectionViewCell

@interface MLLoadingCollectionViewCell ()

@property (nonatomic, readonly, strong) UIActivityIndicatorView * indicatorView;

@end

#pragma mark -

@implementation MLLoadingCollectionViewCell

- (void)finishInitialize {
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_indicatorView];
    
    NSDictionary * views = @{@"indicator"   : _indicatorView};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[indicator]-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[indicator]-|" options:0 metrics:nil views:views]];
    [_indicatorView startAnimating];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    if (!self.indicatorView.isAnimating) {
        [self.indicatorView startAnimating];
    }
}

@end
