#import <Cordova/CDVPlugin.h>
#import "CardFlight.h"
#import "CFTReader.h"
#import "CFTCard.h"
#import "CFTCharge.h"

@interface CDVCardFlight : CDVPlugin <readerDelegate>
{
    void (^readerDone)(void);
}

+ (NSString*)cordovaVersion;
extern NSString * const CardType_toString[];

- (void)setApiTokens:(CDVInvokedUrlCommand*)command;
- (void)swipeCard:(CDVInvokedUrlCommand*)command;
- (void)cancelSwipe:(CDVInvokedUrlCommand*)command;
- (void)setCallbackOnReaderAttached:(CDVInvokedUrlCommand*)command;
- (void)setCallbackOnReaderDisconnected:(CDVInvokedUrlCommand*)command;
- (void)setCallbackOnReaderConnected:(CDVInvokedUrlCommand*)command;
- (void)setCallbackOnReaderConnecting:(CDVInvokedUrlCommand*)command;
- (void)setCallbackOnSwipeComplete:(CDVInvokedUrlCommand*)command;

@end
