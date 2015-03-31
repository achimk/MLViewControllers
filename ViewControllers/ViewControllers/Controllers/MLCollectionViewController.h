//
//  MLCollectionViewController.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLViewController.h"

@interface MLCollectionViewController : MLViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, readwrite, strong) IBOutlet UICollectionView * collectionView;
@property (nonatomic, readonly, strong) UICollectionViewLayout * collectionViewLayout;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnViewWillAppear;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnReloadData;
@property (nonatomic, readwrite, assign) BOOL reloadOnCurrentLocaleChange;
@property (nonatomic, readwrite, assign) BOOL reloadOnAppearsFirstTime;
@property (nonatomic, readwrite, assign) BOOL showsBackgroundView;

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout;

- (void)setNeedsReload;
- (BOOL)needsReload;

- (void)reloadIfNeeded;
- (void)reloadIfVisible;
- (void)reloadData;

@end

@interface MLCollectionViewController (MLSubclassOnly)

+ (Class)defaultCollectionViewLayoutClass;
- (UIView *)backgroundViewForCollectionView:(UICollectionView *)collectionView;

@end
