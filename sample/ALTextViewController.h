//
//  ALTranslatorViewController.h
//  sample
//
//  Created by Andrew Lebedev on 03.10.15.
//  Copyright (c) 2015 Andrew Lebedev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALTranslatorViewController.h"

@interface ALTextViewController : UIViewController <UITextViewDelegate>



@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, strong, readwrite) UIMenuController *menuController;
@property (nonatomic, strong, readwrite) UIMenuItem *translateItem;

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;


@end
