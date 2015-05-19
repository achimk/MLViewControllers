//
//  MLCollectionViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLCollectionViewController.h"

#pragma mark - MLCollectionViewController

@interface MLCollectionViewController () {
    BOOL _collectionViewInsetsNeedsUpdate;
    BOOL _collectionViewConstraintsNeedsUpdate;
    BOOL _needsReload;
}

@end

#pragma mark -

@implementation MLCollectionViewController

@dynamic collectionViewLayout;
@dynamic showsBackgroundView;

+ (Class)defaultCollectionViewLayoutClass {
    return [UICollectionViewFlowLayout class];
}

+ (UIEdgeInsets)defaultCollectionViewInset {
    return UIEdgeInsetsZero;
}

#pragma mark Init / Dealloc

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    NSParameterAssert(layout);
    
    if (self = [self initWithNibName:nil bundle:nil]) {
        if (!layout) {
            layout = [[[[self class] defaultCollectionViewLayoutClass] alloc] init];
        }
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    
    return self;
}

- (void)finishInitialize {
    [super finishInitialize];
    
    _needsReload = NO;
    _reloadOnCurrentLocaleChange = NO;
    _reloadOnAppearsFirstTime = YES;
    _clearsSelectionOnViewWillAppear = YES;
    _clearsSelectionOnReloadData = NO;
    _collectionViewInsetsNeedsUpdate = NO;
    _collectionViewConstraintsNeedsUpdate = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark View

- (void)loadView {
    [super loadView];

    if (!self.collectionView) { // For programmatically init
        UICollectionViewLayout * layout = [[[[self class] defaultCollectionViewLayoutClass] alloc] init];
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    }
    else if (!self.collectionView.superview) { // For programmatically init from initWithCollectionViewLayout:
        _collectionViewConstraintsNeedsUpdate = YES;
        self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.collectionView];
        [self.view setNeedsUpdateConstraints];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (_collectionViewInsetsNeedsUpdate) {
        [self updateCollectionViewInsets];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.reloadOnAppearsFirstTime) {
        [self reloadData];
    }
    else {
        [self reloadIfNeeded];
    }
    
    if (self.clearsSelectionOnViewWillAppear) {
        for (NSIndexPath * indexPath in [[self.collectionView indexPathsForSelectedItems] copy]) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:animated];
        }
    }
}

#pragma mark Constraints

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    if (_collectionViewConstraintsNeedsUpdate) {
        _collectionViewInsetsNeedsUpdate = YES;
        _collectionViewConstraintsNeedsUpdate = NO;
        [self updateCollectionViewConstraints];
    }
}

- (void)updateCollectionViewConstraints {
    UIEdgeInsets inset = [[self class] defaultCollectionViewInset];
    NSDictionary * sizes = @{@"top"             : @(inset.top),
                             @"bottom"          : @(inset.bottom),
                             @"left"            : @(inset.left),
                             @"right"           : @(inset.right)};
    NSDictionary * views = @{@"topGuide"        : self.topLayoutGuide,
                             @"bottomGuide"     : self.bottomLayoutGuide,
                             @"collectionView"  : self.collectionView};
    
    if (self.automaticallyAdjustsScrollViewInsets) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[collectionView]-(bottom)-|"
                                                                          options:kNilOptions
                                                                          metrics:sizes
                                                                            views:views]];
    }
    else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topGuide]-(top)-[collectionView]-(bottom)-[bottomGuide]|"
                                                                          options:kNilOptions
                                                                          metrics:sizes
                                                                            views:views]];
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[collectionView]-(right)-|"
                                                                      options:kNilOptions
                                                                      metrics:sizes
                                                                        views:views]];
}

- (void)updateCollectionViewInsets {
    UIEdgeInsets scrollInsets = UIEdgeInsetsZero;
    
    if (self.automaticallyAdjustsScrollViewInsets) {
        BOOL isVerticalLayout = ([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]] && UICollectionViewScrollDirectionVertical == [(UICollectionViewFlowLayout *)self.collectionViewLayout scrollDirection]);
        
        if (isVerticalLayout) {
            scrollInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, self.bottomLayoutGuide.length, 0.0f);
        }
    }
    
    self.collectionView.contentInset = self.collectionView.scrollIndicatorInsets = scrollInsets;
}

#pragma mark Accessors

- (void)setCollectionView:(UICollectionView *)collectionView {
    if (collectionView != _collectionView) {
        if (_collectionView) {
            [_collectionView removeFromSuperview];
            _collectionView.delegate = nil;
            _collectionView.dataSource = nil;
        }
        
        _collectionView = collectionView;
        
        if (collectionView) {
            if (!collectionView.delegate) {
                collectionView.delegate = self;
            }
            
            if (!collectionView.dataSource) {
                collectionView.dataSource = self;
            }
            
            if (!collectionView.superview && self.isViewLoaded) {
                _collectionViewConstraintsNeedsUpdate = YES;
                collectionView.translatesAutoresizingMaskIntoConstraints = NO;
                [self.view addSubview:collectionView];
                [self.view setNeedsUpdateConstraints];
            }
        }
    }
}

- (UICollectionViewLayout *)collectionViewLayout {
    return (self.collectionView) ? self.collectionView.collectionViewLayout : nil;
}

- (void)setReloadOnCurrentLocaleChange:(BOOL)reloadOnCurrentLocaleChange {
    if (reloadOnCurrentLocaleChange != _reloadOnCurrentLocaleChange) {
        if (_reloadOnCurrentLocaleChange) {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:NSCurrentLocaleDidChangeNotification
                                                          object:nil];
        }
        
        _reloadOnCurrentLocaleChange = reloadOnCurrentLocaleChange;
        
        if (reloadOnCurrentLocaleChange) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(currentLocaleDidChangeNotification:)
                                                         name:NSCurrentLocaleDidChangeNotification
                                                       object:nil];
        }
    }
}

- (void)setShowsBackgroundView:(BOOL)showsBackgroundView {
    if (showsBackgroundView && !self.isViewLoaded) {
        [self view];
    }
    
    if (showsBackgroundView != self.showsBackgroundView) {
        self.collectionView.backgroundView = (showsBackgroundView) ? [self backgroundViewForCollectionView:self.collectionView] : nil;
    }
}

- (BOOL)showsBackgroundView {
    return (nil != self.collectionView.backgroundView);
}

- (UIView *)backgroundViewForCollectionView:(UICollectionView *)collectionView {
    return nil;
}

#pragma mark Reload Data

- (void)setNeedsReload {
    _needsReload = YES;
}

- (BOOL)needsReload {
    return _needsReload;
}

- (void)reloadIfNeeded {
    if (self.needsReload) {
        [self reloadData];
    }
}

- (void)reloadIfVisible {
    if (self.isViewVisible) {
        [self reloadData];
    }
    else {
        [self setNeedsReload];
    }
}

- (void)reloadData {
    NSAssert2([NSThread isMainThread], @"%@: %@ must be called on main thread!", [self class], NSStringFromSelector(_cmd));
    _needsReload = NO;
    
    if (self.isViewVisible) {
        self.reloadOnAppearsFirstTime = NO;
    }
    
    if (self.clearsSelectionOnReloadData) {
        [self.collectionView reloadData];
    }
    else {
        NSArray * selectedItems = [[self.collectionView indexPathsForSelectedItems] copy];
        
        [self.collectionView reloadData];
        
        for (NSIndexPath * indexPath in selectedItems) {
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
}

#pragma mark Notifications

- (void)currentLocaleDidChangeNotification:(NSNotification *)aNotification {
    if (self.isViewVisible) {
        [self reloadData];
    }
    else {
        [self setNeedsReload];
    }
}

#pragma mark UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

@end
