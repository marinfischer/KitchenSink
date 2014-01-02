//
//  AskerViewController.h
//  KitchenSink
//
//  Created by Marin Fischer on 11/11/13.
//  Copyright (c) 2013 Marin Fischer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AskerViewController : UIViewController

@property (nonatomic, strong) NSString *question;
@property (nonatomic, readonly) NSString *answer;

@end
