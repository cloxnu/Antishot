//
//  CALayer+Swizzling.m
//  
//
//  Created by Sidney Liu on 7/21/24.
//

#if !TARGET_OS_WATCHOS
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@interface CALayer ()
- (void)setDisableUpdateMask:(unsigned int)aValue;
@end

@implementation CALayer (Swizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(init);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        SEL swizzledSelector = @selector(init_swizzled);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (instancetype)init_swizzled {
    self = [self init_swizzled];
    if (self) {
        if ([self respondsToSelector:@selector(setDisableUpdateMask:)]) {
            [self setDisableUpdateMask:0x12];
        }
    }
    return self;
}

@end
#endif
