//
//  MLLoadableCollectionViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 24.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLLoadableCollectionViewController.h"
#import "MLUniformFlowLayout.h"
#import "MLCollectionViewDataSource.h"
#import "MLCustomCollectionReusableView.h"
#import "MLCustomCollectionViewCell.h"
#import "MLLoadingCollectionViewCell.h"

#pragma mark - MLLoadableCollectionViewController

@interface MLLoadableCollectionViewController () <MLCollectionViewLoadingDataSourceDelegate>

@property (nonatomic, readwrite, strong) MLCollectionViewDataSource * dataSource;

@end

#pragma mark -

@implementation MLLoadableCollectionViewController

+ (Class)defaultCollectionViewLayoutClass {
    return [MLUniformFlowLayout class];
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reloadOnAppearsFirstTime = NO;
    self.dataSource = [[MLCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                               resultsController:self.resultsController
                                                                        delegate:self];
    self.dataSource.animateCollectionChanges = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    MLUniformFlowLayout * uniformLayout = (MLUniformFlowLayout *)self.collectionViewLayout;
    uniformLayout.interItemSpacing = MLInterItemSpacingMake(5.0f, 5.0f);
    uniformLayout.enableStickyHeader = NO;
    
    [self.collectionView registerClass:[MLCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [self.collectionView registerClass:[MLCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    [MLCustomCollectionViewCell registerCellWithCollectionView:self.collectionView];
    [MLLoadingCollectionViewCell registerCellWithCollectionView:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.loadableContent.currentState isEqualToString:MLContentStateInitial]) {
        [self.loadableContent loadContent];
    }
}

#pragma mark Reload Data

- (void)reloadData {
    [self.dataSource reloadData];
}

#pragma mark MLUniformFlowLayoutDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(MLUniformFlowLayout *)layout itemHeightInSection:(NSInteger)section {
    return 44.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(MLUniformFlowLayout *)layout headerHeightInSection:(NSInteger)section; {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(MLUniformFlowLayout *)layout footerHeightInSection:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView sectionSpacingForlayout:(MLUniformFlowLayout *)layout {
    return 10.0f;
}

- (NSUInteger)collectionView:(UICollectionView *)collectionView layout:(MLUniformFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section {
    return 1;
}

#pragma mark MLCollectionViewDataSourceDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    MLCustomCollectionViewCell * cell = [MLCustomCollectionViewCell cellForCollectionView:collectionView indexPath:indexPath];
    cell.textLabel.text = [object description];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView * reusableView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        MLCollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        reusableView = headerView;
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        MLCollectionReusableView * footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
        reusableView = footerView;
    }
    
    return reusableView;
}

#pragma mark MLCollectionViewLoadingDataSourceDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView loadingCellAtIndexPath:(NSIndexPath *)indexPath {
    MLLoadingCollectionViewCell * cell = [MLLoadingCollectionViewCell cellForCollectionView:collectionView indexPath:indexPath];
    [self.loadableContent pageContent];
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowLoadingCellAtIndexPath:(NSIndexPath *)indexPath {
    MLLoadableContentType type = self.loadableContent.type;
    NSString * currentState = self.loadableContent.currentState;
    return type == MLLoadableContentTypePaging && ([currentState isEqualToString:MLContentStateLoaded] || [currentState isEqualToString:MLContentStatePaging]);
}

@end
