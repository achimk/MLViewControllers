//
//  MLRuntime.h
//  ViewControllers
//
//  Created by Joachim Kret on 01.05.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <objc/runtime.h>

/**
 * Enable or disable logging of the messages sent through objc_msgSend. Messages are logged to
 *    /tmp/msgSends-XXXX
 * with the following format:
 *    <Receiver object class> <Class which implements the method> <Selector name>
 *
 * Remark:
 * This is a function secretely implemented by the Objective-C runtime. The declaration
 * is here only provided for convenience
 */
void instrumentObjcMessageSends(BOOL start);

/**
 * Replace the implementation of a class method, given its selector. Return the original implementation
 */
IMP MLSwizzleClassSelector(Class clazz, SEL selector, IMP newImplementation);

/**
 * Replace the implementation of an instance method, given its selector. Return the original implementation
 */
IMP MLSwizzleSelector(Class clazz, SEL selector, IMP newImplementation);
