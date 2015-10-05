//
//  ALTranslatorViewController.h
//  sample
//
//  Created by Andrew Lebedev on 04.10.15.
//  Copyright (c) 2015 Andrew Lebedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALTranslatorViewController : UIViewController

@property (nonatomic, weak, readwrite) IBOutlet UIButton *buttonFrom;
@property (nonatomic, weak, readwrite) IBOutlet UIButton *buttonTo;

@property (nonatomic, weak, readwrite) IBOutlet UITextView *viewFrom;
@property (nonatomic, weak, readwrite) IBOutlet UITextView *viewTo;

@property (nonatomic, weak, readwrite) IBOutlet UILabel *labelFrom;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *labelTo;

@property (nonatomic, strong, readwrite) NSString *textForTranslate;
@property (nonatomic, strong, readwrite) NSString *translatedText;
@property (nonatomic, strong, readwrite) NSString *langFrom; 
@property (nonatomic, strong, readwrite) NSString *langTo;

@property (nonatomic, strong, readwrite) NSArray *dirs; // list of directions
@property (nonatomic, strong, readwrite) NSDictionary *langs; // descriptions of languages

@property (nonatomic, strong, readwrite) NSMutableArray *keysForLangList;
@property (nonatomic, strong, readwrite) NSMutableDictionary *langList;// dict langFrom for langTo

- (IBAction)buttonFromClicked:(id)sender;
- (IBAction)buttonToClicked:(id)sender;


@end
