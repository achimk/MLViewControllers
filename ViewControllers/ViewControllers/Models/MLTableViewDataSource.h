//
//  MLTableViewDataSource.h
//  ViewControllers
//
//  Created by Joachim Kret on 07.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLResultsControllerProtocol.h"

/**
 MLTableViewDataSourceDelegate
 */
@protocol MLTableViewDataSourceDelegate <NSObject>

@required
- (UITableViewCell *)tableView:(UITableView *)tableView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)tableView:(UITableView *)tableView updateCell:(UITableViewCell *)cell forObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (BOOL)tableView:(UITableView *)tableView canEditObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableView canMoveObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

@end

/**
 MLTableViewLoadingDataSourceDelegate
 */
@protocol MLTableViewLoadingDataSourceDelegate <MLTableViewDataSourceDelegate>

@required
- (BOOL)tableView:(UITableView *)tableView shouldShowLoadingCellAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView loadingCellAtIndexPath:(NSIndexPath *)indexPath;

@end

/**
 MLTableViewDataSource
 */
@interface MLTableViewDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, readonly, weak) UITableView * tableView;
@property (nonatomic, readwrite, strong) id <MLResultsController> resultsController;
@property (nonatomic, readwrite, weak) id <MLTableViewDataSourceDelegate> delegate;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnReloadData;
@property (nonatomic, readwrite, assign) BOOL reloadOnCurrentLocaleChange;
@property (nonatomic, readwrite, assign, getter = shouldShowSectionHeaders) BOOL showSectionHeaders;
@property (nonatomic, readwrite, assign, getter = shouldAnimateTableChanges) BOOL animateTableChanges;
@property (nonatomic, readwrite, assign) UITableViewRowAnimation addSectionAnimation;
@property (nonatomic, readwrite, assign) UITableViewRowAnimation removeSectionAnimation;
@property (nonatomic, readwrite, assign) UITableViewRowAnimation updateSectionAnimation;
@property (nonatomic, readwrite, assign) UITableViewRowAnimation addObjectAnimation;
@property (nonatomic, readwrite, assign) UITableViewRowAnimation removeObjectAnimation;
@property (nonatomic, readwrite, assign) UITableViewRowAnimation updateObjectAnimation;

- (instancetype)initWithTableView:(UITableView *)tableView resultsController:(id <MLResultsController>)resultsController delegate:(id <MLTableViewDataSourceDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (void)setAllAnimations:(UITableViewRowAnimation)animation;
- (void)setAllSectionAnimations:(UITableViewRowAnimation)animation;
- (void)setAllObjectAnimations:(UITableViewRowAnimation)animation;
- (BOOL)isLoadingSection:(NSUInteger)section;
- (BOOL)isLoadingIndexPath:(NSIndexPath *)indexPath;

- (void)reloadData;

@end
