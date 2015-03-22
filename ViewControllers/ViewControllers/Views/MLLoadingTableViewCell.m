//
//  MLLoadingTableViewCell.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLLoadingTableViewCell.h"

#pragma mark - MLLoadingTableViewCell

@interface MLLoadingTableViewCell ()

@property (nonatomic, readonly, strong) UIActivityIndicatorView * indicatorView;

@end

#pragma mark -

@implementation MLLoadingTableViewCell

+ (UITableViewCellStyle)defaultTableViewCellStyle {
    return UITableViewCellStyleDefault;
}

- (void)finishInitialize {
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
    self.accessoryType = UITableViewCellAccessoryNone;
    
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
    
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
    self.accessoryType = UITableViewCellAccessoryNone;
    
    if (!self.indicatorView.isAnimating) {
        [self.indicatorView startAnimating];
    }
}

@end
