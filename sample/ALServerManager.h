//
//  ALServerManager.h
//  sample
//
//  Created by Andrew Lebedev on 04.10.15.
//  Copyright (c) 2015 Andrew Lebedev. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *API_KEY = @"trnsl.1.1.20150930T074032Z.cb21f79f9c2cb0c6."
                           @"290b8003dc75a4edce017c8a5baa8103fb2471c5";

static NSString *ALTranslateGetLangs = @"getLangs";
static NSString *ALTranslateDetect = @"detect";
static NSString *ALTranslateTranslate = @"translate";

@interface ALServerManager : NSObject

+ (ALServerManager *)sharedManager;

- (void)getTranslatingDirect:(NSString *)ui
                   onSuccess:(void (^)(NSArray *dirs,
                                       NSDictionary *langs))success
                   onFailure:(void (^)(NSError *error, NSInteger code))failure;

- (void)defineLang:(NSString *)text
         onSuccess:(void (^)(NSString *lang))success
         onFailure:(void (^)(NSError *error, NSInteger code))failure;

- (void)translate:(NSString *)text
          forLang:(NSString *)lang
       withFormat:(NSString *)format
          options:(NSString *)options
        onSuccess:(void (^)(NSString *text))success
        onFailure:(void (^)(NSError *error, NSInteger code))failure;

- (void)checkInternetConnectionWithHandler:(void (^)(BOOL))handler;

@end
