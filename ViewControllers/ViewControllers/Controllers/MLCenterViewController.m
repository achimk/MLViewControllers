//
//  MLCenterViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 14/04/15.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLCenterViewController.h"

static const char __alphabet[] =
"0123456789"
"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz";

@interface MLCenterViewController ()

@property (nonatomic, readwrite, weak) IBOutlet UIImageView * imageView;
@property (nonatomic, readwrite, weak) IBOutlet UILabel * label1;
@property (nonatomic, readwrite, weak) IBOutlet UILabel * label2;

@end

@implementation MLCenterViewController

+ (NSString *)randomString:(NSInteger)length {
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    u_int32_t alphabetLength = (u_int32_t)strlen(__alphabet);
    for (NSInteger i = 0; i < length; i++) {
        [randomString appendFormat:@"%c", __alphabet[arc4random_uniform(alphabetLength)]];
    }
    return randomString;
}

+ (NSInteger)randLength {
    NSInteger lowerBound = 20;
    NSInteger upperBound = 100;
    return lowerBound + arc4random() % (upperBound - lowerBound);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"Rand" style:UIBarButtonItemStyleBordered target:self action:@selector(customizeLabels)];
    self.navigationItem.rightBarButtonItem = item;
    
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    [self customizeLabels];
}

- (void)customizeLabels {
    NSLayoutConstraint * heightConstraint = nil;
    
    self.label1.hidden = ([[self class] randLength] % 2);
    self.label2.hidden = ([[self class] randLength] % 2);

    self.label1.text = (self.label1.hidden) ? nil : [[self class] randomString:[[self class] randLength]];
    self.label2.text = (self.label2.hidden) ? nil : [[self class] randomString:[[self class] randLength]];

    UIColor * color = ([[self class] randLength] % 2) ? [UIColor redColor] : [UIColor greenColor];
    self.imageView.image = [UIImage ml_imageWithColor:color];
    self.imageView.hidden = ([[self class] randLength] % 2);

    heightConstraint = [self heightConstraintInView:self.imageView];
    heightConstraint.constant = (self.imageView.hidden) ? 0.0f : 100.0f;

    
    [self.view setNeedsUpdateConstraints];
}

- (NSLayoutConstraint *)heightConstraintInView:(UIView *)view {
    NSParameterAssert(view);
    
    __block NSLayoutConstraint * heightConstraint = nil;
    [self.imageView.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint * obj, NSUInteger idx, BOOL *stop) {
        if (obj.firstAttribute == NSLayoutAttributeHeight || obj.secondAttribute == NSLayoutAttributeHeight) {
            heightConstraint = obj;
            *stop = YES;
        }
    }];
    
    return heightConstraint;
}

@end
