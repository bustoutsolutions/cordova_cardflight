/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <Cordova/CDV.h>
#import "CDVCardFlight.h"

@interface CDVCardFlight ()
@property (nonatomic) CFTReader *reader;
@property (nonatomic) CFTCard *card;
@property (nonatomic) CDVPluginResult *readerPluginResult;
@property (nonatomic) NSString *onReaderAttachedCallbackId;
@property (nonatomic) NSString *onReaderConnectedCallbackId;
@property (nonatomic) NSString *onReaderDisconnectedCallbackId;
@property (nonatomic) NSString *onReaderConnectingCallbackId;
@property (nonatomic) NSString *onSwipeCompleteCallbackId;
@end

@implementation CDVCardFlight
@synthesize onReaderAttachedCallbackId, onReaderConnectedCallbackId, onReaderDisconnectedCallbackId, onReaderConnectingCallbackId, onSwipeCompleteCallbackId;


- (void)setApiTokens:(CDVInvokedUrlCommand*)command {
    NSString* apiToken = [command.arguments objectAtIndex:0];
    NSString* accountToken = [command.arguments objectAtIndex:1];
    CDVPluginResult* pluginResult = nil;
    [[CardFlight sharedInstance] setApiToken:apiToken accountToken:accountToken];

    NSLog(@"API TOKEN: %@ ACCOUNT TOKEN: %@\n", [[CardFlight sharedInstance] getApiToken], [[CardFlight sharedInstance] getAccountToken]);

    _reader = [[CFTReader alloc] initAndConnect];
    if (_reader) {
      [_reader setDelegate:self];
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)swipeCard:(CDVInvokedUrlCommand*)command {
  NSString* _popupTitle = nil;
    if([[command.arguments objectAtIndex:0] isEqualToString:@"none"]) {
      [_reader beginSwipeWithMessage:nil];
    }
    else {
      [_reader beginSwipeWithMessage:[command.arguments objectAtIndex:0]];
    }


    // Here wait for the cardResponse to complete via block
    __weak CDVCardFlight *weakSelf = self;
    readerDone = ^{
        [weakSelf.commandDelegate sendPluginResult:weakSelf.readerPluginResult
                                        callbackId:command.callbackId];
        NSLog(@"READER DONE");
        NSLog(@"READER CALLBACKID %@\n", command.callbackId);
        NSLog(@"READER RESULT %@\n", weakSelf.readerPluginResult);
    };
  weakSelf = nil;
}

- (void)readerCardResponse:(CFTCard *)card withError:(NSError *)error {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CardFlight" message:error.localizedDescription delegate:self
                                              cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    } else {
        _card = card;
        NSLog(@"SWIPE RESPONSE %@", _card.name);
        if (self.onSwipeCompleteCallbackId) {
          CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                    messageAsDictionary:@{@"name": _card.name, @"last4": _card.last4,
                                                        @"cardType": CardType_toString[_card.cardType],
                                                        @"expirationMonth": [NSNumber numberWithInt: _card.expirationMonth],
                                                        @"expirationYear": [NSNumber numberWithInt: _card.expirationYear]
                                                      } ];
          [self.commandDelegate sendPluginResult:result callbackId:self.onSwipeCompleteCallbackId];
        }
        [_card tokenizeCardWithSuccess:^{
            NSLog(@"Card Token:  %@\n", _card.cardToken);
            _readerPluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                    messageAsDictionary:@{@"cardToken": _card.cardToken}];
              // Callback to the block in the swipeCard method
              readerDone();
         }
                       failure:^(NSError *error){
                           NSLog(@"ERROR CODE: %i", error.code);
                           _readerPluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                                   messageAsString:error.localizedDescription];
                          // Callback to the block in the swipeCard method
                          readerDone();
                       }];
    }
}


//Response after manual entry
-(void)manualEntryDictionary:(NSDictionary *)dictionary
{
}


//Server response after submitting data
-(void)serverResponse:(NSData *)response andError:(NSError *)error
{
    //Manage the CardFlight API server response
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"Server Response: %@", jsonDict);
}

- (void)readerIsAttached {
  NSLog(@"called readerIsAttached");
  NSLog(@"CallbackId %@", self.onReaderAttachedCallbackId);
  // fire corresponding callback id for onReaderAttached
  if (self.onReaderAttachedCallbackId) {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:self.onReaderAttachedCallbackId];
  }
}

- (void)readerIsDisconnected {
  NSLog(@"called readerIsDisconnected");
  NSLog(@"CallbackId %@", self.onReaderDisconnectedCallbackId);
  // fire corresponding callback id for onReaderAttached
  if (self.onReaderDisconnectedCallbackId) {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:self.onReaderDisconnectedCallbackId];
  }
}

- (void)readerIsConnecting {
  NSLog(@"called readerIsConnecting");
  NSLog(@"CallbackId %@", self.onReaderConnectingCallbackId);
  if (self.onReaderConnectingCallbackId) {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:self.onReaderConnectingCallbackId];
  }
}


- (void)readerIsConnected:(BOOL)isConnected withError:(NSError *)error {
    NSLog(@"called readerIsConnected");
    NSLog(@"CallbackId %@", self.onReaderConnectedCallbackId);
    CDVPluginResult* result;

    if (self.onReaderConnectedCallbackId) {
      if (isConnected) {
        NSLog(@"READER IS CONNECTED");
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      } else {
          NSLog(@"ERROR CODE: %i", error.code);
          result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
      }
      [self.commandDelegate sendPluginResult:result callbackId:self.onReaderConnectedCallbackId];
    }
}

/* ============== Callbacks =========== */

- (void)setCallbackOnReaderAttached:(CDVInvokedUrlCommand*)command {
    onReaderAttachedCallbackId = command.callbackId;
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"called startOnReaderAttached");
    NSLog(@"called setCallbackOnReaderAttached");
  }

- (void)setCallbackOnReaderDisconnected:(CDVInvokedUrlCommand*)command {
    onReaderDisconnectedCallbackId = command.callbackId;
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"called startOnReaderDisconnected");
    NSLog(@"called setCallbackOnReaderDisconnected");
  }

- (void)setCallbackOnReaderConnected:(CDVInvokedUrlCommand*)command {
    onReaderConnectedCallbackId = command.callbackId;
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"called startOnReaderConnected");
    NSLog(@"called setCallbackOnReaderConnected");
  }

- (void)setCallbackOnReaderConnecting:(CDVInvokedUrlCommand*)command {
    onReaderConnectingCallbackId = command.callbackId;
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"called startOnReaderConnecting");
    NSLog(@"called setCallbackOnReaderConnecting");
  }

// Callback returns card swipe information as a hash
- (void)setCallbackOnSwipeComplete:(CDVInvokedUrlCommand*)command {
    onSwipeCompleteCallbackId = command.callbackId;
    NSLog(@"called setCallbackOnSwipeComplete");
  }

+ (NSString*)cordovaVersion
{
    return CDV_VERSION;
}

NSString * const CardType_toString[] = {
    [UNKNOWN] = @"UNKNOWN",
    [VISA] = @"VISA",
    [MASTERCARD] = @"MASTERCARD",
    [AMEX] = @"AMEX",
    [DINERS] = @"DINERS",
    [DISCOVER] = @"DISCOVER",
    [JCB] = @"JCB"
};
@end
