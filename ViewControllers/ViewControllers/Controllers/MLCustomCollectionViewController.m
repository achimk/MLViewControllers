//
//  MLCustomCollectionViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLCustomCollectionViewController.h"
#import "MLUniformFlowLayout.h"
#import "MLItemFlowLayout.h"
#import "MLCustomCollectionReusableView.h"
#import "MLCustomCollectionViewCell.h"

#define NUMBER_OF_SECTIONS      10
#define NUMBER_OF_COLUMNS       (IS_IPHONE) ? 1 : 3

#pragma mark - MLCollectionViewController

@interface MLCollectionViewController ()

- (void)updateCollectionViewInsets;

@end

#pragma mark - MLCustomCollectionViewController

@interface MLCustomCollectionViewController () <
    MLUniformFlowLayoutDelegate,
    MLCollectionViewDelegateItemFlowLayout,
    UICollectionViewDelegateFlowLayout
>

@end

#pragma mark -

@implementation MLCustomCollectionViewController

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    if ([self uniformFlowLayout]) {
        self.uniformFlowLayout.interItemSpacing = MLInterItemSpacingMake(5.0f, 5.0f);
        self.uniformFlowLayout.enableStickyHeader = YES;
    }
    else if ([self itemFlowLayout]) {
        self.itemFlowLayout.itemSpacing = MLItemSpacingMake(5.0f, 5.0f);
    }
    else if ([self collectionViewFlowLayout]) {
        self.collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(50.0f, 0.0f, 50.0f, 0.0f);
    }
    
    [self.collectionView registerClass:[MLCustomCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [self.collectionView registerClass:[MLCustomCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    [MLCustomCollectionViewCell registerCellWithCollectionView:self.collectionView];
}

- (void)updateCollectionViewInsets {
    [super updateCollectionViewInsets];

#warning Bug with content inset for item flow layout.
//    UIEdgeInsets contentInset = self.collectionView.contentInset;
//    contentInset.left = contentInset.right = 5.0f;
//    self.collectionView.contentInset = contentInset;
}

#pragma mark Accessors

- (MLUniformFlowLayout *)uniformFlowLayout {
    MLUniformFlowLayout * uniformFlowLayout = ([self.collectionViewLayout isKindOfClass:[MLUniformFlowLayout class]]) ? (MLUniformFlowLayout *)self.collectionViewLayout : nil;
    return uniformFlowLayout;
}

- (MLItemFlowLayout *)itemFlowLayout {
    MLItemFlowLayout * itemFlowLayout = ([self.collectionViewLayout isKindOfClass:[MLItemFlowLayout class]]) ? (MLItemFlowLayout *)self.collectionViewLayout : nil;
    return itemFlowLayout;
}

- (UICollectionViewFlowLayout *)collectionViewFlowLayout {
    UICollectionViewFlowLayout * flowLayout = ([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) ? (UICollectionViewFlowLayout *)self.collectionViewLayout : nil;
    return flowLayout;
}

#pragma mark MLUniformFlowLayoutDelegate

- (NSUInteger)collectionView:(UICollectionView *)collectionView layout:(MLUniformFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section {
    return NUMBER_OF_COLUMNS;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(MLUniformFlowLayout *)layout itemHeightInSection:(NSInteger)section {
    return 200.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(MLUniformFlowLayout *)layout headerHeightInSection:(NSInteger)section; {
    return 44.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(MLUniformFlowLayout *)layout footerHeightInSection:(NSInteger)section {
    return 44.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView sectionSpacingForlayout:(MLUniformFlowLayout *)layout {
    return 10.0f;
}

#pragma mark MLCollectionViewDelegateItemFlowLayout

- (NSUInteger)collectionView:(UICollectionView *)collectionView numberOfColumnsInSection:(NSInteger)section {
    return NUMBER_OF_COLUMNS;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView heightForItemsInSection:(NSInteger)section {
    return 200.0f;
}
- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView {
    return 10.0f;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 44.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 44.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(200.0f, 200.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 50.0f;
}

#pragma mark UICollectionDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"-> willDisplaySupplementaryView: %ld-%ld (%@)", indexPath.section, indexPath.row, elementKind);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"-> didEndDisplayingSupplementaryView: %ld-%ld (%@)", indexPath.section, indexPath.row, elementKind);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"-> willDisplayCell: %ld-%ld", indexPath.section, indexPath.row);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"-> didEndDisplayingCell: %ld-%ld", indexPath.section, indexPath.row);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark UICollectionDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MLCustomCollectionViewCell * cell = [MLCustomCollectionViewCell cellForCollectionView:collectionView indexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"Section: %ld row: %ld", indexPath.section, indexPath.row];
    cell.contentView.backgroundColor = [UIColor blueColor];
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return NUMBER_OF_SECTIONS;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return NUMBER_OF_SECTIONS;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([self itemFlowLayout]) {
        return nil;
    }
    
    UICollectionReusableView * reusableView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        MLCustomCollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        headerView.textLabel.text = [NSString stringWithFormat:@"Header for section: %ld", indexPath.section];
        headerView.backgroundColor = [UIColor redColor];
        reusableView = headerView;
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        MLCustomCollectionReusableView * footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
        footerView.textLabel.text = [NSString stringWithFormat:@"Footer for section: %ld", indexPath.section];
        footerView.backgroundColor = [UIColor greenColor];
        reusableView = footerView;
    }
    
    return reusableView;
}

@end
