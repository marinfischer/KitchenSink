//
//  AskerViewController.m
//  KitchenSink
//
//  Created by Marin Fischer on 11/11/13.
//  Copyright (c) 2013 Marin Fischer. All rights reserved.
//

#import "AskerViewController.h"

@interface AskerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UITextField *answerTextField;

@end

@implementation AskerViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self.questionLabel.text = self.question;
    self.answerTextField.text = nil;
    [self.answerTextField becomeFirstResponder];
}

- (NSString *)answer
{
    return self.answerTextField.text;
}


@end
