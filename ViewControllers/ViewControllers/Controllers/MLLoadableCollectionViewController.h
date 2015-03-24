//
//  MLLoadableCollectionViewController.h
//  ViewControllers
//
//  Created by Joachim Kret on 24.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLCollectionViewController.h"
#import "MLLoadableContentViewModel.h"
#import "MLResultsControllerProtocol.h"

@interface MLLoadableCollectionViewController : MLCollectionViewController

@property (nonatomic, readwrite, strong) MLLoadableContentViewModel * loadableContentViewModel;
@property (nonatomic, readwrite, strong) id <MLResultsController> resultsController;

@end
