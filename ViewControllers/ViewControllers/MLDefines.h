//
//  MLDefines.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#ifndef MLDEFINES
#define MLDEFINES

/*
 *  User Interface Device Preprocessor Macros
 */
#define IS_SIMULATOR    (TARGET_IPHONE_SIMULATOR)
#define IS_IPAD         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE       (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5     (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA       ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f)

/*
 *  System Versioning Preprocessor Macros
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/*
 *  Common NSException Macros
 *  from: https://github.com/michalkonturek/MKUnits/blob/master/Source/MKMacros.h
 */
#define METHOD_NOT_IMPLEMENTED METHOD(@"%@: NOT IMPLEMENTED.")
#define METHOD_MUST_BE_OVERRIDDEN METHOD(@"You must override %@ in subclass.")
#define METHOD_USE_DESIGNATED_INIT  METHOD(@"%@: Use designated initializer.")
#define METHOD(MSG) @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:MSG, NSStringFromSelector(_cmd)] userInfo:nil];

#endif
