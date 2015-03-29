//  The MIT License (MIT)
//
//  Copyright (c) 2014 mownier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <UIKit/UIKit.h>

/**
 * Spacing for the items
 */
typedef struct MLInterItemSpacing {
    CGFloat x, y;
} MLInterItemSpacing;

/**
 * Creates an InterItemSpacing struct
 */
static inline MLInterItemSpacing MLInterItemSpacingMake(CGFloat x, CGFloat y) {
    MLInterItemSpacing spacing = {x, y};
    return spacing;
}

@interface MLUniformFlowLayout : UICollectionViewFlowLayout

/// The inter spacing for all items
@property (readwrite, nonatomic) MLInterItemSpacing interItemSpacing;

/// Condition to enable/disable sticky headers
@property (readwrite, nonatomic) BOOL enableStickyHeader;

/**
 * Computes the width of all the items for a particular section
 * @param section A particular section in the collection view
 * @return The width of all the items for a particular section
 */
- (CGFloat)computeItemWidthInSection:(NSInteger)section;

@end

/**
 * Handles the definition of the item height, header height,
 * footer height, section spacing, and number of columns
 * for a particular section
 */
@protocol MLUniformFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

/**
 * Gets the item height in a particular section
 * @param collectionView The involved UICollectionView
 *        layout The involed UICollectionViewFlowLayout
 *        section The section that needs the value of the height of it's items
 * @return Height for all the section's items
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(MLUniformFlowLayout *)layout itemHeightInSection:(NSInteger)section;

@optional

/**
 * Gets the header height in a particular section
 * @param collectionView The involved UICollectionView
 *        layout The involed UICollectionViewFlowLayout
 *        section The section that needs the value of the it's header height
 * @return Height of the section's header
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(MLUniformFlowLayout *)layout headerHeightInSection:(NSInteger)section;

/**
 * Gets the footer height in a particular section
 * @param collectionView The involved UICollectionView
 *        layout The involed UICollectionViewFlowLayout
 *        section The section that needs the value of the it's footer height
 * @return Height of the section's footer
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(MLUniformFlowLayout *)layout footerHeightInSection:(NSInteger)section;

/**
 * Gets the spacing between sections
 * @param collectionView The involved UICollectionView
 *        layout The involed UICollectionViewFlowLayout
 * @return Section spacing between sections
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView sectionSpacingForlayout:(MLUniformFlowLayout *)layout;

/**
 * Gets the number of columns in a particular section
 * @param collectionView The involved UICollectionView
 *        layout The involed UICollectionViewFlowLayout
 *        section The section that needs the value of the it's footer height
 * @return Number of columns
 */
- (NSUInteger)collectionView:(UICollectionView *)collectionView layout:(MLUniformFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section;

@end
