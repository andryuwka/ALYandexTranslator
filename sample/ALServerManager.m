//
//  ALServerManager.m
//  sample
//
//  Created by Andrew Lebedev on 04.10.15.
//  Copyright (c) 2015 Andrew Lebedev. All rights reserved.
//

#import "ALServerManager.h"
#import "AFNetworking.h"
#import "TSMessage.h"

@interface ALServerManager ()

@property(nonatomic, strong, readwrite)
    AFHTTPRequestOperationManager *requestOperationManager;

@end

@implementation ALServerManager

+ (ALServerManager *)sharedManager {
  static ALServerManager *manager = nil;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[ALServerManager alloc] init];
  });

  return manager;
}

- (id)init {
  self = [super init];

  if (self) {
    NSURL *url =
        [NSURL URLWithString:@"https://translate.yandex.net/api/v1.5/tr.json/"];
    self.requestOperationManager =
        [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
  }

  return self;
}

#pragma mark - Check Internet Connection

- (void)checkInternetConnectionWithHandler:(void (^)(BOOL))handler {
  NSString *urlString = @"https://www.google.com/";
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"HEAD"];
  [[[NSURLSession sharedSession]
      dataTaskWithRequest:request
   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
     handler(error == NULL);
   }] resume];
}

#pragma mark - GET requests from Server

- (void)getTranslatingDirect:(NSString *)ui
                   onSuccess:(void (^)(NSArray *dirs,
                                       NSDictionary *langs))success
                   onFailure:(void (^)(NSError *error, NSInteger code))failure {

  NSDictionary *params = [NSDictionary
      dictionaryWithObjectsAndKeys:API_KEY, @"key", ui, @"ui", nil];

  [self.requestOperationManager GET:ALTranslateGetLangs
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // NSLog(@"JSON: %@", responseObject);

        NSArray *dirs = responseObject[@"dirs"];
        NSDictionary *langs = responseObject[@"langs"];

        if (success) {
          success(dirs, langs);
        }

      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
          failure(error, operation.response.statusCode);
        }

      }];
}

- (void)defineLang:(NSString *)text
         onSuccess:(void (^)(NSString *lang))success
         onFailure:(void (^)(NSError *error, NSInteger code))failure {

  NSDictionary *params = [NSDictionary
      dictionaryWithObjectsAndKeys:API_KEY, @"key", text, @"text", nil];

  [self.requestOperationManager GET:ALTranslateDetect
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // NSLog(@"JSON: %@", responseObject);
        NSString *lang = responseObject[@"lang"];
        if (success) {
          success(lang);
        }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
          failure(error, operation.response.statusCode);
        }
      }];
}

- (void)translate:(NSString *)text
          forLang:(NSString *)lang
       withFormat:(NSString *)format
          options:(NSString *)options
        onSuccess:(void (^)(NSString *translated))success
        onFailure:(void (^)(NSError *error, NSInteger code))failure {
  NSDictionary *params = [NSDictionary
      dictionaryWithObjectsAndKeys:API_KEY, @"key", text, @"text", lang,
                                   @"lang", format, @"format", options,
                                   @"options", nil];

  [self.requestOperationManager GET:ALTranslateTranslate
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {

        // NSLog(@"JSON: %@", responseObject);
        NSString *translatedText;
        NSArray *ar = responseObject[@"text"];
        translatedText = ar[0];

        if (success) {
          success(translatedText);
        }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
          failure(error, operation.response.statusCode);
        }
      }];
}

@end
