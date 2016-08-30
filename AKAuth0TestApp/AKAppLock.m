//
//  AKAppLock.m
//  AKAuth0TestApp
//

#import "AKAppLock.h"

@implementation AKAppLock

+ (AKAppLock *)sharedInstance {
    static AKAppLock *sharedApplication = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedApplication = [[self alloc] init];
    });
    return sharedApplication;
}

- (id)init {
    self = [super init];
    if (self) {
        _lock = [A0Lock newLock];
        
        NSString *twitterApiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TwitterConsumerKey"];
        NSString *twitterApiSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TwitterConsumerSecret"];
        
        A0TwitterAuthenticator *twitter = [A0TwitterAuthenticator newAuthenticatorWithKey:twitterApiKey andSecret:twitterApiSecret];
        A0FacebookAuthenticator *facebook = [A0FacebookAuthenticator newAuthenticatorWithDefaultPermissions];
        [_lock registerAuthenticators:@[twitter, facebook]];
    }
    
    return self;
}

@end
