//
//  MLButtonCollectionViewCell.h
//  ViewControllers
//
//  Created by Joachim Kret on 31.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLCollectionViewCell.h"

@interface MLButtonCollectionViewCell : MLCollectionViewCell

@property (nonatomic, readonly, strong) IBOutlet UILabel * textLabel;
@property (nonatomic, readonly, strong) IBOutlet UIButton * removeButton;

@end
