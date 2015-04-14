//
//  MLCenterView.m
//  ViewControllers
//
//  Created by Joachim Kret on 14/04/15.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLCenterView.h"

#define MARGIN  0.0f

@interface MLCenterView ()

@property (nonatomic, readwrite, weak) IBOutlet UILabel * label1;
@property (nonatomic, readwrite, weak) IBOutlet UILabel * label2;

@end

@implementation MLCenterView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.label1.preferredMaxLayoutWidth = self.bounds.size.width - MARGIN * 2.0f;
    self.label2.preferredMaxLayoutWidth = self.bounds.size.width - MARGIN * 2.0f;
}

@end
