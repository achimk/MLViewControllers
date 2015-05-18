//
//  MLTableViewController.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLViewController.h"

@interface MLTableViewController : MLViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, readwrite, strong) IBOutlet UITableView * tableView;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnViewWillAppear;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnReloadData;
@property (nonatomic, readwrite, assign) BOOL reloadOnCurrentLocaleChange;
@property (nonatomic, readwrite, assign) BOOL reloadOnAppearsFirstTime;
@property (nonatomic, readwrite, assign) BOOL showsBackgroundView;

- (instancetype)initWithStyle:(UITableViewStyle)style;

- (void)setNeedsReload;
- (BOOL)needsReload;

- (void)reloadIfNeeded;
- (void)reloadIfVisible;
- (void)reloadData;

@end

@interface MLTableViewController (MLSubclassOnly)

+ (UITableViewStyle)defaultTableViewStyle;
+ (UIEdgeInsets)defaultTableViewInset;

- (void)finishInitialize NS_REQUIRES_SUPER;
- (UIView *)backgroundViewForTableView:(UITableView *)tableView;

@end
