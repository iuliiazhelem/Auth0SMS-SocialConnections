//
//  AKAppLock.h
//  AKAuth0TestApp
//
//  Created by Iuliia Zhelem on 24.05.16.
//  Copyright © 2016 Akvelon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Lock/Lock.h>
#import <Lock-Twitter/A0TwitterAuthenticator.h>
#import <Lock-Facebook/A0FacebookAuthenticator.h>

static NSString *kFacebookConnectionName = @"facebook";
static NSString *kTwitterConnectionName = @"twitter";
@interface AKAppLock : NSObject

@property (readonly, nonatomic) A0Lock *lock;
+ (AKAppLock *)sharedInstance;

@end
