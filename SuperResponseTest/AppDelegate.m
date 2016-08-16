//
//  AppDelegate.m
//  SuperResponseTest
//
//  Created by baidu on 16/8/15.
//  Copyright © 2016年 dzpqzb. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>
#import <objc/message.h>


Class DZGetCurrentClassInvocationSEL(NSString* functionString)
{
    
    if (functionString.length == 0) {
        return nil;
    }
    
    NSRange rangeStart = [functionString rangeOfString:@"["];
    NSRange rangeEnd = [functionString rangeOfString:@" "];
    if (rangeStart.location == NSNotFound || rangeEnd.location == NSNotFound) {
        return nil;
    }
    NSInteger start = rangeStart.location + rangeStart.length;
    if (rangeEnd.location - start <= 0) {
        return nil;
    }
    NSRange classRange = NSMakeRange(start, rangeEnd.location - start);
    NSString *classString = [functionString substringWithRange:classRange];
    return NSClassFromString(classString);
}

BOOL DZCheckSuperResponseToSelector(Class cla, SEL selector) {
    Class superClass = class_getSuperclass(cla);
    return class_respondsToSelector(superClass, selector);
}



FOUNDATION_EXTERN Class DZGetCurrentClassInvocationSEL(NSString*  functionString);

FOUNDATION_EXTERN BOOL DZCheckSuperResponseToSelector(Class cla, SEL selector);
#define __IMP_CLASS__  DZGetCurrentClassInvocationSEL([NSString stringWithFormat:@"%s",__FUNCTION__])
#define __DZSuperResponseCMD__ DZCheckSuperResponseToSelector(__IMP_CLASS__, _cmd)


@interface A : NSObject <UITableViewDelegate>

@end
@implementation A

- (void) test
{
    Class supClass = class_getSuperclass([self class]);
    NSLog(@"self class is %@, super class is %@",self.class, supClass);
    if (class_respondsToSelector(supClass, _cmd)) {
        struct objc_super sup = {
            .receiver = self,
            .super_class = [self class]
        };
        void(*func)(struct objc_super*,SEL) = (void*)&objc_msgSendSuper;
        func(&sup, _cmd);
    }
}

- (void) test2
{
    if (__DZSuperResponseCMD__) {
        struct objc_super sup = {
            .receiver = self,
            .super_class = [self class]
        };
        void(*func)(struct objc_super*,SEL) = (void*)&objc_msgSendSuper;
        func(&sup, _cmd);
    }
}
@end

@interface B  : A

@end

@implementation B
@end

@interface C : B

@end

@implementation C


@end



void TestC() {
    C* c = [C new];
    [c test];
}

void TestC2() {
    C* c = [C new];
    [c test2];
}
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    TestC2();
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
