//
//  MLContactsCollectionViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 07.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLContactsCollectionViewController.h"
#import "MLContactCollectionViewCell.h"
#import "MLAutorotation.h"
#import "MLCellSizeManager.h"

#pragma mark - MLContactsCollectionViewController

@interface MLContactsCollectionViewController ()

@property (nonatomic, readwrite, strong) NSArray * arrayOfContacts;
@property (nonatomic, readwrite, strong) MLCellSizeManager * sizeManager;

@end

#pragma mark -

@implementation MLContactsCollectionViewController

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];

    _sizeManager = [[MLCellSizeManager alloc] init];
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    
    [MLContactCollectionViewCell registerCellWithCollectionView:self.collectionView];
    [self.sizeManager registerCellClass:[MLContactCollectionViewCell class] withSizeBlock:^(id cell, id anObject, NSIndexPath *indexPath) {
        [cell configureWithObject:anObject context:indexPath];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.appearsFirstTime && [self.parentViewController conformsToProtocol:@protocol(MLAutorotation)]) {
        [(id <MLAutorotation>)self.parentViewController setAutorotationMode:MLAutorotationModeContainerAndTopChildren];
    }
}

#pragma mark Accessors

- (NSArray *)arrayOfContacts {
    if (!_arrayOfContacts) {
        _arrayOfContacts = [self jsonObjectFromFilename:@"Contacts"];
    }
    
    return _arrayOfContacts;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [self cacheCellHeightForData:[self.arrayOfContacts objectAtIndex:indexPath.row]
                                   collectionView:collectionView
                                        indexPath:indexPath];
    return CGSizeMake(collectionView.bounds.size.width, height);
}

#pragma mark UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MLContactCollectionViewCell * cell = [MLContactCollectionViewCell cellForCollectionView:collectionView indexPath:indexPath];
    [cell configureWithObject:[self.arrayOfContacts objectAtIndex:indexPath.row] context:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayOfContacts.count;
}

#pragma mark Rotation

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark Private Methods

- (id)jsonObjectFromFilename:(NSString *)filename {
    NSParameterAssert(filename);
    id path = [[NSBundle bundleForClass:[self class]] URLForResource:filename withExtension:@"json"];
    id json = [NSData dataWithContentsOfURL:path];
    return [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
}

- (CGFloat)cacheCellHeightForData:(id)data collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    CGSize size = [self.sizeManager cellSizeForObject:data atIndexPath:indexPath];
    return size.height;
}

@end
