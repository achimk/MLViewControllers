//
//  MLTableViewCell.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLTableViewCell.h"

#pragma mark - MLTableViewCell

@implementation MLTableViewCell

+ (UITableViewCellStyle)defaultTableViewCellStyle {
    return UITableViewCellStyleDefault;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

+ (NSString *)nibName {
    return nil;
}

+ (void)registerCellWithTableView:(UITableView *)tableView {
    NSParameterAssert(tableView);
    
    if ([self nibName]) {
        NSBundle * bundle = [NSBundle bundleForClass:[self class]];
        UINib * nib = [UINib nibWithNibName:[self nibName] bundle:bundle];
        [tableView registerNib:nib forCellReuseIdentifier:[self reuseIdentifier]];
    }
    else {
        [tableView registerClass:[self class] forCellReuseIdentifier:[self reuseIdentifier]];
    }
}

+ (id)cellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(tableView);
    UITableViewCell * cell = nil;
    
    if (indexPath) {
        cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier] forIndexPath:indexPath];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier]];
    }
    
    return cell;
}

#pragma mark Initialize

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:[[self class] defaultTableViewCellStyle] reuseIdentifier:reuseIdentifier]) {
        [self finishInitialize];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self finishInitialize];
}

- (void)finishInitialize {
    // Subclasses can override this method
}

#pragma mark Accessors

- (UITableView *)tableView {
    return (UITableView *)[self findResponderForClass:[UITableView class] responder:self];
}

- (UIViewController *)viewController {
    return (UIViewController *)[self findResponderForClass:[UIViewController class] responder:self];
}

#pragma mark Configure Cell 

- (void)configureWithObject:(id)anObject context:(id)context {
    // Subclasses can override this method
}

#pragma mark Private Methods

- (UIResponder *)findResponderForClass:(Class)class responder:(UIResponder *)responder {
    NSParameterAssert(responder);
    
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:class]) {
            return responder;
        }
    }
    
    return nil;
}

@end
