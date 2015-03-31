//
//  MLButtonCollectionViewCell.m
//  ViewControllers
//
//  Created by Joachim Kret on 31.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLButtonCollectionViewCell.h"

#pragma mark - MLButtonCollectionViewCell

@interface MLButtonCollectionViewCell ()

@property (nonatomic, readwrite, strong) IBOutlet UILabel * textLabel;
@property (nonatomic, readwrite, strong) IBOutlet UIButton * removeButton;

@end

#pragma mark -

@implementation MLButtonCollectionViewCell

#pragma mark Init

- (void)finishInitialize {
    if (!_textLabel && !_removeButton) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.numberOfLines = 0;
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_textLabel];
        
        _removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_removeButton setTitle:@"Delete" forState:UIControlStateNormal];
        [_removeButton setBackgroundImage:[UIImage ml_imageWithColor:[UIColor flatBlueColor]] forState:UIControlStateNormal];
        [_removeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _removeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_removeButton];
        
        NSDictionary * views = @{@"textLabel"       : _textLabel,
                                 @"button"          : _removeButton};
        NSDictionary * sizes = @{@"textMargin"      : @(5.0f),
                                 @"buttonMargin"    : @(20.0f)};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-textMargin-[textLabel]-textMargin-|"
                                                                                 options:0
                                                                                 metrics:sizes
                                                                                   views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-buttonMargin-[button]-buttonMargin-|"
                                                                                 options:0
                                                                                 metrics:sizes
                                                                                   views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-buttonMargin-[textLabel]-textMargin-[button]-buttonMargin-|"
                                                                                 options:0
                                                                                 metrics:sizes
                                                                                   views:views]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_removeButton
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0f
                                                                      constant:20.0f]];
    }
    
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [UIColor lightGrayColor];
}

#pragma mark Prepare For Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.textLabel.text = nil;
}

#pragma mark Private Methods

- (IBAction)buttonTapped:(id)sender {
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:self];
    NSString * selectorString = @"removeCellAtIndexPath:";
    SEL selector = NSSelectorFromString(selectorString);
    id target = self.viewController;
    
    if ([target respondsToSelector:selector]) {
        NSMethodSignature * signature = [target methodSignatureForSelector:selector];
        NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = target;
        invocation.selector = selector;
        [invocation setArgument:&indexPath atIndex:2];
        [invocation invoke];
    }
}

@end
