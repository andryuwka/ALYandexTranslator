//
//  ALTranslatorViewController.m
//  sample
//
//  Created by Andrew Lebedev on 03.10.15.
//  Copyright (c) 2015 Andrew Lebedev. All rights reserved.
//

#import "ALTextViewController.h"
#import "ActionSheetStringPicker.h"
#import "TSMessage.h"
#import "ALServerManager.h"

@interface ALTextViewController ()

@end

@implementation ALTextViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWasShown:)
             name:UIKeyboardDidShowNotification
           object:nil];

  self.translateItem = [[UIMenuItem alloc] initWithTitle:@"Перевести"
                                                  action:@selector(translate:)];
  self.menuController = [UIMenuController sharedMenuController];

  [self.menuController
      setMenuItems:[NSArray arrayWithObject:self.translateItem]];
  
  [[ALServerManager sharedManager]
      checkInternetConnectionWithHandler:^(BOOL check) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (!check) {
            [self errorInternetConnection:YES];
          }
        });
      }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - TSMessages

- (void)errorInternetConnection:(BOOL)animated {
  [TSMessage showNotificationWithTitle:@"Something failed"
                              subtitle:@"The internet connection seems to be "
                              @"down. Please check that!"
                                  type:TSMessageNotificationTypeError];
}

- (void)errorTextLength:(BOOL)animated {
  [TSMessage showNotificationWithTitle:@"Something failed"
                              subtitle:@"Selected is too large. Please "
                              @"select the text smaller."
                                  type:TSMessageNotificationTypeWarning];
}

#pragma mark - UIMenuItemMethods

- (BOOL)canBecomeFirstResponder {
  return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
  if (action == @selector(translate:)) {
    if (self.textView.selectedRange.length > 0) {
      return YES;
    }
  }

  return NO;
}

- (void)translate:(id)sender {

  [[ALServerManager sharedManager]
      checkInternetConnectionWithHandler:^(BOOL check) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (check) {
            [self
                performSegueWithIdentifier:@"IdentifierTranslatorViewController"
                                    sender:self];
          } else {
            [self errorInternetConnection:YES];
          }
        });
      }];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  return YES;
}

#pragma mark - prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

  ALTranslatorViewController *temp = segue.destinationViewController;
  temp.textForTranslate =
      [self.textView textInRange:[self.textView selectedTextRange]];
}

#pragma mark - Keyboard

- (void)keyboardWasShown:(NSNotification *)notification {
  NSDictionary *info = [notification userInfo];
  CGRect keyboardRect = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  keyboardRect = [self.textView convertRect:keyboardRect fromView:nil];

  UIEdgeInsets insets = self.textView.contentInset;
  insets.bottom = keyboardRect.size.height;
  self.textView.contentInset = insets;
  self.textView.scrollIndicatorInsets = insets;

  [self.textView setNeedsLayout];
}

@end
