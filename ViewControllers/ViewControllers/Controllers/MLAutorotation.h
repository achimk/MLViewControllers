//
//  MLAutorotation.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MLAutorotationMode) {
    // Default: The container implementation decides which view controllers are involved
    // and which ones receive events
    MLAutorotationModeContainer,
    
    // The container only decides and receives events
    MLAutorotationModeContainerAndNoChildren,
    
    // The container and its top children decide and receive events. A container might have
    // several top children if it displays several view controllers next to each other
    MLAutorotationModeContainerAndTopChildren,
    
    // The container and all its children (even those not visible) decide and receive events
    MLAutorotationModeContainerAndAllChildren,
};

@protocol MLAutorotation <NSObject>

@required
- (MLAutorotationMode)autorotationMode;
- (void)setAutorotationMode:(MLAutorotationMode)autorotationMode;

@end
