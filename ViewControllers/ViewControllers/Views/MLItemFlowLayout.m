//
//  MLItemFlowLayout.m
//  ViewControllers
//
//  Created by Joachim Kret on 19.05.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLItemFlowLayout.h"

#pragma mark - MLItemFlowLayout

@interface MLItemFlowLayout ()

@property (nonatomic, readwrite, assign) CGFloat sectionSpacing;

@end

#pragma mark -

@implementation MLItemFlowLayout

@dynamic delegate;

#pragma mark Accessors

- (void)setItemSpacing:(MLItemSpacing)itemSpacing {
    _itemSpacing = itemSpacing;
    [self invalidateLayout];
}

- (void)setDelegate:(id<MLCollectionViewDelegateItemFlowLayout>)delegate {
    self.collectionView.delegate = delegate;
}

- (id<MLCollectionViewDelegateItemFlowLayout>)delegate {
    return (id<MLCollectionViewDelegateItemFlowLayout>)self.collectionView.delegate;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return [self.collectionView numberOfItemsInSection:section];
}

- (NSInteger)numberOfSections {
    return self.collectionView.numberOfSections;
}

#pragma mark Override Methods

- (void)prepareLayout {
    [super prepareLayout];
    
    self.sectionSpacing = 0.0f;
    if ([self.delegate respondsToSelector:@selector(sectionSpacingForCollectionView:)]) {
        self.sectionSpacing = [self.delegate sectionSpacingForCollectionView:self.collectionView];
    }
}

- (CGSize)collectionViewContentSize {
    CGSize contentSize = CGSizeZero;
    contentSize.width = [self collectionViewContentWidth];
    contentSize.height = [self collectionViewContentHeight];
    return contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray * arrayOfAttributes = [NSMutableArray array];
    NSInteger numberOfSections = [self numberOfSections];
    for (NSInteger i = 0; i < numberOfSections; i++) {
        NSInteger numberOfItemsInSection = [self numberOfItemsInSection:i];
        for (NSInteger j = 0; j < numberOfItemsInSection; j++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes * attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [arrayOfAttributes addObject:attributes];
            }
        }
    }
    
    return [NSArray arrayWithArray:arrayOfAttributes];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes * attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    [self setupItemAttrbutes:attributes atIndexPath:indexPath];
    return attributes;
}

#pragma mark Attributes

- (void)setupItemAttrbutes:(UICollectionViewLayoutAttributes *)attributes atIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(attributes);
    NSParameterAssert(indexPath);
    
    NSUInteger numberOfColumns = [self numberOfColumnsInSection:indexPath.section];
    NSAssert(0 < numberOfColumns, @"Number of columns must be greater than 0");
    
    NSInteger currentSection = indexPath.section;
    NSInteger currentRow = indexPath.row / numberOfColumns;
    NSInteger currentColumn = indexPath.row % numberOfColumns;
    
    CGRect frame = attributes.frame;
    frame.origin.x = (self.itemSpacing.x * currentColumn) + ([self computeItemWidthInSection:currentSection] * currentColumn);
    frame.origin.y = (self.itemSpacing.y * currentRow) + ([self computeItemHeightInSection:currentSection] * currentRow) + [self computePositionYInSection:currentSection];
    frame.size.width = [self computeItemWidthInSection:currentSection];
    frame.size.height = [self computeItemHeightInSection:currentSection];
    
    attributes.frame = frame;
}

#pragma mark Items Calculations

- (CGFloat)computeItemWidthInSection:(NSInteger)section {
    NSParameterAssert(0 <= section);
    
    NSUInteger numberOfColumns = [self numberOfColumnsInSection:section];
    CGFloat result = self.collectionView.contentInset.left + self.collectionView.contentInset.right + (self.itemSpacing.x * (numberOfColumns - 1));
    CGFloat width = (self.collectionView.frame.size.width - result) / numberOfColumns;
    
    return width;
}

- (CGFloat)computeItemHeightInSection:(NSInteger)section {
    NSParameterAssert(0 <= section);
    
    CGFloat height = 0.0f;
    if ([self.delegate respondsToSelector:@selector(collectionView:heightForItemsInSection:)]) {
        height = [self.delegate collectionView:self.collectionView heightForItemsInSection:section];
    }
    
    return MAX(height, 0.0f);
}

#pragma mark Section Calculations

- (CGFloat)computePositionYInSection:(NSInteger)section {
    NSParameterAssert(0 <= section);
    
    CGFloat totalInterSectionSpacing = self.sectionSpacing * section;
    CGFloat totalitemSpacingY = 0.0f;
    CGFloat totalSectionItemHeight = 0.0f;
    
    for (NSInteger i = 0; i < section; i++) {
        totalitemSpacingY += [self computeTotalitemSpacingYInSection:i];
        totalSectionItemHeight += [self computeTotalItemHeightInSection:i];
    }
    
    CGFloat positionY = totalInterSectionSpacing + totalitemSpacingY + totalSectionItemHeight;
    return positionY;
}

- (CGFloat)computeTotalitemSpacingYInSection:(NSInteger)section {
    NSParameterAssert(0 <= section);
    
    NSInteger numberOfRowsInSection = [self numberOfRowsInSection:section];
    CGFloat totalitemSpacingYInSection = (self.itemSpacing.y * (numberOfRowsInSection - 1));
    return totalitemSpacingYInSection;
}

- (CGFloat)computeTotalItemHeightInSection:(NSInteger)section {
    NSParameterAssert(0 <= section);
    
    NSInteger numberOfRowsInSection = [self numberOfRowsInSection:section];
    CGFloat itemHeight = [self computeItemHeightInSection:section];
    CGFloat totalHeightInSection = itemHeight * numberOfRowsInSection;
    
    return totalHeightInSection;
}

#pragma mark Columns / Rows

- (NSUInteger)numberOfColumnsInSection:(NSInteger)section {
    NSParameterAssert(0 <= section);
    NSUInteger numberOfColumns = 1;
    if ([self.delegate respondsToSelector:@selector(collectionView:numberOfColumnsInSection:)]) {
        numberOfColumns = [self.delegate collectionView:self.collectionView numberOfColumnsInSection:section];
    }
    
    return numberOfColumns;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    NSParameterAssert(0 <= section);
    
    NSInteger numberOfItemsInSection = [self numberOfItemsInSection:section];
    NSInteger numberOfRowsInSection = floorf(numberOfItemsInSection / [self numberOfColumnsInSection:section]);
    return numberOfRowsInSection;
}

#pragma mark Content Sze

- (CGFloat)collectionViewContentWidth {
    return 0.0f;
}

- (CGFloat)collectionViewContentHeight {
    NSInteger lastSection = [self numberOfSections] - 1;
    CGFloat height = 0.0f;
    
    if (0 <= lastSection) {
        height = [self computePositionYInSection:lastSection] + [self computeTotalitemSpacingYInSection:lastSection] + [self computeTotalItemHeightInSection:lastSection];
    }
    
    return MAX(height, (self.collectionView.frame.size.height + 1.0f));
}

@end
