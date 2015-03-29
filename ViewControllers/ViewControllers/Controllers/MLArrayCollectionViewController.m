//
//  MLArrayCollectionViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 29.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLArrayCollectionViewController.h"
#import "MLCollectionViewDataSource.h"
#import "MLCollectionListController.h"
#import "RZCollectionList.h"
#import "MLUniformFlowLayout.h"
#import "MLCustomCollectionReusableView.h"
#import "MLCustomCollectionViewCell.h"

#pragma mark - MLArrayCollectionViewController

@interface MLArrayCollectionViewController () <MLCollectionViewDataSourceDelegate>

@property (nonatomic, readwrite, strong) MLCollectionListController * collectionListController;
@property (nonatomic, readwrite, strong) MLCollectionViewDataSource * dataSource;

@end

#pragma mark -

@implementation MLArrayCollectionViewController

+ (Class)defaultCollectionViewLayoutClass {
    return [MLUniformFlowLayout class];
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    MLUniformFlowLayout * uniformLayout = (MLUniformFlowLayout *)self.collectionViewLayout;
    uniformLayout.interItemSpacing = MLInterItemSpacingMake(5.0f, 5.0f);
    uniformLayout.enableStickyHeader = NO;
    
    [self.collectionView registerClass:[MLCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [self.collectionView registerClass:[MLCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    [MLCustomCollectionViewCell registerCellWithCollectionView:self.collectionView];
    
    RZArrayCollectionList * collectionList = [[RZArrayCollectionList alloc] initWithArray:@[] sectionNameKeyPath:nil];
    self.collectionListController = [[MLCollectionListController alloc] initWithCollectionList:collectionList];
    
    self.dataSource = [[MLCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                               resultsController:self.collectionListController
                                                                        delegate:self];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addAction:)];
}

#pragma mark Accessors

- (RZArrayCollectionList *)arrayCollectionList {
    return self.collectionListController.collectionList;
}

#pragma mark Actions

- (IBAction)addAction:(id)sender {
    [self.arrayCollectionList addObject:[NSDate date] toSection:0];
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

@end
