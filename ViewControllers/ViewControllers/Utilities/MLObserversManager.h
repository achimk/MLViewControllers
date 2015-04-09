//
//  MLObserversManager.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MLObserversManagerType) {
    MLObserversManagerTypeDefault,          // forward to all observers
    MLObserversManagerTypeForwardFirst      // forward to first responds selector observer
};

@interface MLObserversManager : NSObject

@property (nonatomic, readwrite, assign) MLObserversManagerType type; // Default type: MLObserversManagerTypeDefault

- (instancetype)initWithObservers:(NSArray *)observers;
- (instancetype)initWithProtocol:(Protocol *)protocol observers:(NSArray *)observers;

- (NSArray *)arrayOfObservers;
- (void)registerObserver:(id)observer;
- (void)unregisterObserver:(id)observer;
- (void)unregisterAllObservers;

@end
