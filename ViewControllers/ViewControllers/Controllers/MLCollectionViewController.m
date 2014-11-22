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

#pragma mark Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSCurrentLocaleDidChangeNotification
                                                  object:nil];
}

#pragma mark Init

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    NSParameterAssert(layout);
    
    if (self = [self initWithNibName:nil bundle:nil]) {
        if (!layout) {
            layout = [[[self class] defaultCollectionViewLayoutClass] new];
        }
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
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
    _collectionViewConstraintsNeedsUpdate = NO;
}

#pragma mark View

- (void)loadView {
    [super loadView];
    
    if (!self.isViewLoaded) {
        self.view = [[UIView alloc] init];
    }
    
    if (!_collectionView) {
        UICollectionViewLayout * layout = [[[[self class] defaultCollectionViewLayoutClass] alloc] init];
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    }
    else if (!_collectionView.superview) {
        _collectionViewConstraintsNeedsUpdate = YES;
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_collectionView];
        [self.view setNeedsUpdateConstraints];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(currentLocaleDidChangeNotification:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
        && self.automaticallyAdjustsScrollViewInsets
        && self.appearsFirstTime) {
        
        self.collectionView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, self.bottomLayoutGuide.length, 0.0f);
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
        _collectionViewConstraintsNeedsUpdate = NO;
        
        NSDictionary * views = @{@"collectionView"  : self.collectionView};
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:0 metrics:nil views:views]];
    }
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
    NSAssert2([NSThread isMainThread], @"%@: %@ must be called on main thread", [self class], NSStringFromSelector(_cmd));
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
    if (self.reloadOnCurrentLocaleChange) {
        if (self.isViewVisible) {
            [self reloadData];
        }
        else {
            [self setNeedsReload];
        }
    }
}

#pragma mark UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@: NOT IMPLEMENTED.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

@end
