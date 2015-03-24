//
//  MLLoadableContentViewModel.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLLoadToken.h"

/**
 Loadable content states
 */
extern NSString * const MLContentStateInitial;
extern NSString * const MLContentStateLoading;
extern NSString * const MLContentStateRefreshing;
extern NSString * const MLContentStatePaging;
extern NSString * const MLContentStateLoaded;
extern NSString * const MLContentStateNoContent;
extern NSString * const MLContentStateError;

/**
 MLLoadableContentType
 */
typedef NS_ENUM(NSUInteger, MLLoadableContentType) {
    MLLoadableContentTypeDefault,       // Default type for loading resource
    MLLoadableContentTypePaging         // Paging type for loading resources with pagination
};

@class MLLoadableContentViewModel;

/**
 MLLoadableContentDelegate
 */
@protocol MLLoadableContentDelegate <NSObject>

@required
- (void)loadableContent:(MLLoadableContentViewModel *)loadableContent loadDataWithLoadToken:(MLLoadToken *)loadToken;

@optional
- (void)loadableContentWillChangeState:(MLLoadableContentViewModel *)loadableContent;
- (void)loadableContentDidChangeState:(MLLoadableContentViewModel *)loadableContent;

// MLLoadableContentDelegate support also state changing methods:
// - (BOOL)loadableContentShouldEnter[toState];
// - (void)loadableContentDidExit[fromState];
// - (void)loadableContentDidEnter[toState];
// - (void)loadableContentStateDidChangeFrom[formState]To[toState];

@end

/**
 MLLoadableContentViewModel
 */
@interface MLLoadableContentViewModel : NSObject

@property (nonatomic, readonly, copy) NSString * currentState;
@property (nonatomic, readonly, strong) MLLoadToken * loadToken;
@property (nonatomic, readonly, assign) MLLoadableContentType type;
@property (nonatomic, readwrite, weak) id <MLLoadableContentDelegate> delegate;

- (instancetype)initWithType:(MLLoadableContentType)type;

- (BOOL)loadContent;
- (BOOL)refreshContent;
- (BOOL)pageContent;

@end

/**
 MLLoadableContentViewModel (MLSubclassOnly)
 */
@interface MLLoadableContentViewModel (MLSubclassOnly)

- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState;

@end
