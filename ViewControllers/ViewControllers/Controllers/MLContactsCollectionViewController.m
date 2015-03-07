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

#define IGNORE_CACHE    1

#pragma mark - MLContactsCollectionViewController

@interface MLContactsCollectionViewController ()

@property (nonatomic, readwrite, strong) NSCache * cacheOfCellHeights;
@property (nonatomic, readwrite, strong) NSArray * arrayOfContacts;

@end

#pragma mark -

@implementation MLContactsCollectionViewController

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    _cacheOfCellHeights = [[NSCache alloc] init];
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    
    [MLContactCollectionViewCell registerCellWithCollectionView:self.collectionView];
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
    [cell configureForData:[self.arrayOfContacts objectAtIndex:indexPath.row] collectionView:collectionView indexPath:indexPath];
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
    NSNumber * height = [self.cacheOfCellHeights objectForKey:@(indexPath.row)];
    
    if (!height) {
        CGSize size = [MLContactCollectionViewCell cellSizeForData:data
                                                    collectionView:collectionView
                                                         indexPath:indexPath];
        height = @(size.height);
#if !IGNORE_CACHE
        [self.cacheOfCellHeights setObject:height forKey:@(indexPath.row)];
#endif
    }
    
    return (height) ? height.floatValue : 0.0f;
}

@end
