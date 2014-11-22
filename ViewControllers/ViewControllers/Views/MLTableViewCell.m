//
//  MLTableViewCell.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLTableViewCell.h"

#define DEFAULT_TABLE_VIEW_CELL_HEIGHT      44.0f

@implementation MLTableViewCell

+ (UITableViewCellStyle)defaultTableViewCellStyle {
    return UITableViewCellStyleDefault;
}

+ (NSString *)defaultTableViewCellIdentifier {
    return NSStringFromClass([self class]);
}

+ (NSString *)defaultTableViewCellNibName {
    return nil;
}

+ (UINib *)defaultNib {
    if ([self defaultTableViewCellNibName]) {
        NSBundle * bundle = [NSBundle bundleForClass:[self class]];
        return [UINib nibWithNibName:[self defaultTableViewCellNibName] bundle:bundle];
    }
    
    return nil;
}

+ (CGFloat)defaultTableViewCellHeight {
    NSString * nibName = [self defaultTableViewCellNibName];
    
    if (nibName) {
        static NSMutableDictionary * dictionaryOfCellHeights = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dictionaryOfCellHeights = [[NSMutableDictionary alloc] init];
        });
        
        NSNumber * height = [dictionaryOfCellHeights objectForKey:nibName];
        
        if (!height) {
            NSArray * nibObjects = [[self defaultNib] instantiateWithOwner:nil options:nil];
            NSAssert2([nibObjects count] > 0 && [[nibObjects objectAtIndex:0] isKindOfClass:[self class]], @"Nib '%@' doesn't appear to contain a valid %@", [self defaultTableViewCellNibName], [self class]);
            UITableViewCell * cell = (UITableViewCell *)[nibObjects objectAtIndex:0];
            height = @(cell.bounds.size.height);
            [dictionaryOfCellHeights setObject:height forKey:nibName];
        }
        
        return height.floatValue;
    }
    
    return DEFAULT_TABLE_VIEW_CELL_HEIGHT;
}

+ (void)registerCellWithTableView:(UITableView *)tableView {
    NSParameterAssert(tableView);
    
    if ([self defaultTableViewCellNibName]) {
        [tableView registerNib:[self defaultNib] forCellReuseIdentifier:[self defaultTableViewCellNibName]];
    }
    else if ([self defaultTableViewCellIdentifier]) {
        [tableView registerClass:[self class] forCellReuseIdentifier:[self defaultTableViewCellIdentifier]];
    }
    else {
        NSAssert(NO, @"Can't register cell '%@' without nib name or cell identifier", [self class]);
    }
}

+ (id)cellForTableView:(UITableView *)tableView {
    return [self cellForTableView:tableView indexPath:nil];
}

+ (id)cellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(tableView);
    
    NSString * cellIdentifier = ([self defaultTableViewCellNibName]) ? [self defaultTableViewCellNibName] : [self defaultTableViewCellIdentifier];
    UITableViewCell * cell = nil;
    
    if (cellIdentifier) {
        if (indexPath) {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
    }
    else {
        NSAssert(NO, @"Can't dequeue cell '%@' without nib name or cell identifier", [self class]);
    }
    
    return cell;
}

#pragma mark Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:[[self class] defaultTableViewCellStyle] reuseIdentifier:reuseIdentifier]) {
        [self finishInitialize];
    }
    
    return self;
}

#pragma mark Awake

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self finishInitialize];
}

#pragma mark Subclass Methods

- (void)finishInitialize {
}

- (void)configureForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
}

@end
