# Auth0SMS-SocialConnections

This sample exposes how to create custom UI with passwordless SMS authentication and Social connection.

First of all you need to configure [SMS connection](https://auth0.com/docs/connections/passwordless/sms), [Facebook connection](https://auth0.com/docs/connections/social/facebook) and [Twitter connection](https://auth0.com/docs/connections/social/twitter)

For integration of these connections you need to add the following to your `Podfile`:
```
  pod 'Lock-Facebook', '~> 2.0'
  pod 'Lock-Twitter', '~> 1.1'
  pod 'Lock/SMS'
  pod 'SimpleKeychain'
```

## Important Snippets

### Step 1: Register authenticators 
```Objective-C
  A0Lock *lock = [A0Lock sharedLock];
  NSString *twitterApiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TwitterConsumerKey"];
  NSString *twitterApiSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TwitterConsumerSecret"];
        
  A0TwitterAuthenticator *twitter = [A0TwitterAuthenticator newAuthenticatorWithKey:twitterApiKey andSecret:twitterApiSecret];
  A0FacebookAuthenticator *facebook = [A0FacebookAuthenticator newAuthenticatorWithDefaultPermissions];
  [lock registerAuthenticators:@[twitter, facebook]];
```

### Step 2: Authenticate with Connection name 
(`@"twitter"` or `@"facebook"`)
```Objective-C
  void(^success)(A0UserProfile *, A0Token *) = ^(A0UserProfile *profile, A0Token *token) {
    NSLog(@"User: %@", profile);
  };
  void(^error)(NSError *) = ^(NSError *error) {
    NSLog(@"Oops something went wrong: %@", error);
  };
    
  A0Lock *lock = [A0Lock sharedLock];
  [[lock identityProviderAuthenticator] authenticateWithConnectionName:connectionName
                                                            parameters:nil
                                                               success:success
                                                               failure:error];
```

### Step 3: Getting a code
```Objective-C
  A0Lock *lock = [A0Lock sharedLock];
  A0APIClient *client = [lock apiClient];
  [client startPasswordlessWithPhoneNumber:self.emailPhoneTextField.text success:^{
    [self showMessage:@"Please check your sms and eneter code"];
  } failure:^(NSError *error) {
    NSLog(@"Oops something went wrong: %@", error);
  }];
```

### Step 4: Login with phone number and the code
```Objective-C
  A0Lock *lock = [A0Lock sharedLock];
  A0APIClient *client = [lock apiClient];
  [client loginWithPhoneNumber:self.phoneNumber
                      passcode:self.emailPhoneTextField.text
                    parameters:nil
                       success:^(A0UserProfile * _Nonnull profile, A0Token * _Nonnull tokenInfo) {
                        NSLog(@"User: %@", profile);
                     } failure:^(NSError * _Nonnull error) {
                        NSLog(@"Oops something went wrong: %@", error);
                    }];
```

Before using the example please make sure that you change some keys in `Info.plist` with your data:

##### Auth0 data from [Auth0 Dashboard](https://manage.auth0.com/#/applications)
- Auth0ClientId
- Auth0Domain
- CFBundleURLSchemes

```
<key>CFBundleTypeRole</key>
<string>None</string>
<key>CFBundleURLName</key>
<string>auth0</string>
<key>CFBundleURLSchemes</key>
<array>
<string>a0{CLIENT_ID}</string>
</array>
```

##### Twitter data from the configured [Social connection](https://manage.auth0.com/#/connections/social). For more details about connection your app to Twitter see [link](https://auth0.com/docs/connections/social/twitter)
- TwitterConsumerKey
- TwitterConsumerSecret

##### Facebook data from the configured [Social connection](https://manage.auth0.com/#/connections/social). For more details about connection your app to Facebook see [link](https://auth0.com/docs/connections/social/facebook)
- FacebookAppID
- CFBundleURLSchemes

```
<key>CFBundleTypeRole</key>
<string>None</string>
<key>CFBundleURLName</key>
<string>facebook</string>
<key>CFBundleURLSchemes</key>
<array>
<string>fb{FACEBOOK_APP_ID}</string>
</array>
```
