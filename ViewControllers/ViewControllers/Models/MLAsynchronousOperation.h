//
//  MLAsynchronousOperation.h
//  ViewControllers
//
//  Created by Joachim Kret on 10.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLOperation.h"

/**
 Operation's states.
 */
typedef NS_ENUM(NSUInteger, MLOperationState) {
    MLOperationStateUnknown,    // Unknown
    MLOperationStateReady,      // Ready
    MLOperationStateExecuting,  // Executing
    MLOperationStateFinished    // Finished
};

/**
 MLAsynchronousOperation - asynchronous operation class.
 */
@interface MLAsynchronousOperation : MLOperation

@property (nonatomic, readwrite, assign) MLOperationState state; // Property for change operation state.

@end
