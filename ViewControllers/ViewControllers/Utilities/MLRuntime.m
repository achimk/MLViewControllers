//
//  MLRuntime.m
//  ViewControllers
//
//  Created by Joachim Kret on 01.05.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLRuntime.h"

IMP MLSwizzleClassSelector(Class clazz, SEL selector, IMP newImplementation) {
    // Get the original implementation we are replacing
    Class metaClass = objc_getMetaClass(class_getName(clazz));
    Method method = class_getClassMethod(metaClass, selector);
    IMP origImp = method_getImplementation(method);
    if (! origImp) {
        return NULL;
    }
    
    class_replaceMethod(metaClass, selector, newImplementation, method_getTypeEncoding(method));
    return origImp;
}

IMP MLSwizzleSelector(Class clazz, SEL selector, IMP newImplementation) {
    // Get the original implementation we are replacing
    Method method = class_getInstanceMethod(clazz, selector);
    IMP origImp = method_getImplementation(method);
    if (! origImp) {
        return NULL;
    }
    
    class_replaceMethod(clazz, selector, newImplementation, method_getTypeEncoding(method));
    return origImp;
}
