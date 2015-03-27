//
//  MLLoadableTableViewController.h
//  ViewControllers
//
//  Created by Joachim Kret on 24.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLTableViewController.h"
#import "MLLoadableContent.h"
#import "MLResultsControllerProtocol.h"

@interface MLLoadableTableViewController : MLTableViewController

@property (nonatomic, readwrite, strong) MLLoadableContent * loadableContent;
@property (nonatomic, readwrite, strong) id <MLResultsController> resultsController;

@end
