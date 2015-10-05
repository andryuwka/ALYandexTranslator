//
//  ALTranslatorViewController.m
//  sample
//
//  Created by Andrew Lebedev on 04.10.15.
//  Copyright (c) 2015 Andrew Lebedev. All rights reserved.
//

#import "ALTranslatorViewController.h"
#import "ALServerManager.h"
#include "TSMessage.h"
#include "ActionSheetStringPicker.h"

static NSString *ALLocalization = @"ru";

@interface ALTranslatorViewController ()

@property(nonatomic, readwrite) NSInteger currentIndexFrom;
@property(nonatomic, readwrite) NSInteger currentIndexTo;

@end

@implementation ALTranslatorViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.viewTo setText:@""];
  self.langFrom = @"ru";
  self.langTo = @"en";
  [self.viewFrom setText:self.textForTranslate];

  self.currentIndexFrom = 0;
  self.currentIndexTo = 0;

  [self.buttonFrom setTitle:@"Определение..." forState:UIControlStateNormal];
  [self.buttonTo setTitle:@"Английский" forState:UIControlStateNormal];

  self.buttonFrom.clipsToBounds = YES;
  self.buttonFrom.layer.cornerRadius = 10;
  self.buttonTo.clipsToBounds = YES;
  self.buttonTo.layer.cornerRadius = 10;
  self.buttonFrom.layer.borderWidth = 1.0f;
  self.buttonFrom.layer.borderColor = [[UIColor blueColor] CGColor];
  self.buttonTo.layer.borderWidth = 1.0f;
  self.buttonTo.layer.borderColor = [[UIColor blueColor] CGColor];

  [self getDirect];
  [self getTranlationForText:self.textForTranslate];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - IBActions

- (IBAction)buttonFromClicked:(id)sender {

  NSArray *langs = [NSArray arrayWithArray:self.keysForLangList];
  NSMutableArray *temp = [[NSMutableArray alloc] init];
  for (int i = 0; i < [langs count]; ++i) {
    [temp addObject:self.langs[langs[i]]];
  }
  [temp addObject:@"Авто"];
  NSArray *descriptions = [NSArray arrayWithArray:temp];

  [ActionSheetStringPicker showPickerWithTitle:@"Select a first language"
      rows:descriptions
      initialSelection:self.currentIndexFrom
      doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex,
                  id selectedValue) {
        NSString *str = @"Авто";

        if ([str isEqualToString:selectedValue]) {
          [self defineLangForText:self.textForTranslate];
        } else {
          [self.buttonFrom setTitle:selectedValue
                           forState:UIControlStateNormal];
          self.langFrom = langs[selectedIndex];
          self.currentIndexFrom = selectedIndex;
        }

        [self getTranlationForText:self.textForTranslate];

      }
      cancelBlock:^(ActionSheetStringPicker *picker) {
        // NSLog(@"Block Picker Canceled");
      }
      origin:sender];
}

- (IBAction)buttonToClicked:(id)sender {

  NSArray *langs = [NSArray arrayWithArray:self.langList[self.langFrom]];
  NSMutableArray *temp = [[NSMutableArray alloc] init];
  for (int i = 0; i < [langs count]; ++i) {
    [temp addObject:self.langs[langs[i]]];
  }
  NSArray *descriptions = [NSArray arrayWithArray:temp];
  if ([descriptions count] == 0) {
    [self errorChooseLanguage:YES];
  } else {
    [ActionSheetStringPicker showPickerWithTitle:@"Select a second language"
        rows:descriptions
        initialSelection:self.currentIndexTo
        doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex,
                    id selectedValue) {

          [self.buttonTo setTitle:selectedValue forState:UIControlStateNormal];
          self.langTo = langs[selectedIndex];
          self.currentIndexTo = selectedIndex;
          [self getTranlationForText:self.textForTranslate];
        }
        cancelBlock:^(ActionSheetStringPicker *picker) {
          // NSLog(@"Block Picker Canceled");
        }
        origin:sender];
  }
}

#pragma mark - TSMessages

- (void)errorChooseLanguage:(BOOL)animated {
  [TSMessage showNotificationWithTitle:@"Something failed"
                              subtitle:@"There are no any supported languages."
                                  type:TSMessageNotificationTypeWarning];
}

#pragma mark - Get requests

- (void)getDirect {
  [[ALServerManager sharedManager] getTranslatingDirect:ALLocalization
      onSuccess:^(NSArray *dirs, NSDictionary *langs) {
        self.dirs = dirs;
        self.langs = langs;
      }
      onFailure:^(NSError *error, NSInteger code) {
        NSLog(@"Error at - (void)getDirect: in "
              @"ALTranslatorViewController: error = %@, code = %ld",
              [error localizedDescription], (long)code);
      }];
}

- (void)defineLangForText:(NSString *)text {
  [[ALServerManager sharedManager] defineLang:text
      onSuccess:^(NSString *lang) {
        self.langFrom = lang;
        NSString *title =
            [NSString stringWithFormat:@"Авто(%@)", self.langs[lang]];
        [self.buttonFrom setTitle:title forState:UIControlStateNormal];
      }
      onFailure:^(NSError *error, NSInteger code) {
        NSLog(@"Error at - (void)defineLangOfText: in "
              @"ALTranslatorViewController: error = %@, code = %ld",
              [error localizedDescription], (long)code);
      }];
}

- (void)getTranlationForText:(NSString *)text {

  NSString *lang =
      [NSString stringWithFormat:@"%@-%@", self.langFrom, self.langTo];

  [[ALServerManager sharedManager] translate:text
      forLang:lang
      withFormat:@"plain"
      options:@1
      onSuccess:^(NSString *translated) {
        self.translatedText = [NSString stringWithString:translated];
        [self.viewTo setText:self.translatedText];
      }
      onFailure:^(NSError *error, NSInteger code) {
        NSLog(@"Error at - (void)getTranlationForText: in "
              @"ALTranslatorViewController: error = %@, code = %ld",
              [error localizedDescription], (long)code);
      }];
}

#pragma mark - Some helpful converting method

- (void)convertDictToList {
  NSMutableDictionary *langList = [[NSMutableDictionary alloc] init];
  for (int i = 0; i < [self.dirs count]; ++i) {

    NSString *firstLang, *secondLang;
    firstLang = [self.dirs[i] substringToIndex:2];
    secondLang = [self.dirs[i] substringFromIndex:3];
    if (langList[firstLang] == nil) {
      [langList setObject:[NSMutableArray arrayWithObject:secondLang]
                   forKey:firstLang];
    } else {
      NSMutableArray *temp = langList[firstLang];
      [temp addObject:secondLang];
      [langList setObject:temp forKey:firstLang];
    }
  }
  self.langList = langList;

  NSMutableArray *keys = [[NSMutableArray alloc] init];
  for (NSString *key in langList) {
    [keys addObject:key];
  }
  self.keysForLangList = keys;
}

#pragma mark - Setters

- (void)setLangs:(NSDictionary *)langs {
  _langs = langs;
  [self defineLangForText:self.textForTranslate];
  [self convertDictToList];
}

- (void)setTextForTranslate:(NSString *)textForTranslate {
  _textForTranslate = textForTranslate;
}

- (void)setTranslatedText:(NSString *)translatedText {
  _translatedText = translatedText;
}

- (void)setButtonFrom:(UIButton *)buttonFrom {
  _buttonFrom = buttonFrom;
}

- (void)setButtonTo:(UIButton *)buttonTo {
  _buttonTo = buttonTo;
}

@end
