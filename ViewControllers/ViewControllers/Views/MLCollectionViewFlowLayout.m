//
//  MLCollectionViewFlowLayout.m
//  ViewControllers
//
//  Created by Joachim Kret on 31.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLCollectionViewFlowLayout.h"

@implementation MLCollectionViewFlowLayout

- (instancetype)init {
    if (self = [super init]) {
        self.itemSize = CGSizeMake(200.0f, 200.0f);
        self.minimumInteritemSpacing = 10.0f;
        self.minimumLineSpacing = 10.0f;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.sectionInset = UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 0.0f);
    }
    
    return self;
}

@end
