//
//  CMMotionManager+Shared.h
//  KitchenSink
//
//  Created by Marin Fischer on 11/20/13.
//  Copyright (c) 2013 Marin Fischer. All rights reserved.
//


#import <CoreMotion/CoreMotion.h>

@interface CMMotionManager (Shared)

+ (CMMotionManager *)sharedMotionManager;

@end
