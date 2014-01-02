//
//  CMMotionManager+Shared.m
//  KitchenSink
//
//  Created by Marin Fischer on 11/20/13.
//  Copyright (c) 2013 Marin Fischer. All rights reserved.
//

#import "CMMotionManager+Shared.h"

@implementation CMMotionManager (Shared)

+ (CMMotionManager *)sharedMotionManager
{
    static CMMotionManager *shared = nil;
    if (!shared) {
        //dispatch_once is part of GCD, it will only ever get executed once in teh entire running of your application. All the threads that call this will all block until one succeeds until one succeeds and executes. Once it executed they will all unblock and you can return it to get them all. You have a token and then you call dispatch once and provide a pointer to the token, then tell it to do something.
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[CMMotionManager alloc] init];

        });
    }
    return shared;
}

@end
