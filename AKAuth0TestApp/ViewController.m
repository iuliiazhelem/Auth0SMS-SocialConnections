//
//  ViewController.m
//  AKAuth0TestApp
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "AKAppLock.h"
#import <SimpleKeychain.h>

static NSString *kIdTokenKeychainName = @"id_token";
static NSString *kAccessTokenKeychainName = @"access_token";
static NSString *kRefreshTokenKeychainName = @"refresh_token";
static NSString *kProfileKeychainName = @"profile";
static NSString *kKeychainName = @"Auth0";

@interface ViewController ()

@property (nonatomic) BOOL isLoginState;
@property (copy, nonatomic) NSString *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;

//Social Connection
- (IBAction)clickTwitterButton:(id)sender;
- (IBAction)clickFacebookButton:(id)sender;

//Custom Passwordless Connection
@property (weak, nonatomic) IBOutlet UILabel *actionNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *customSMSButton;
@property (weak, nonatomic) IBOutlet UITextField *emailPhoneTextField;
- (IBAction)clickCustomSMSButton:(id)sender;

@end

@implementation ViewController

//Passwordless Connection
- (IBAction)clickCustomSMSButton:(id)sender {
    A0Lock *lock = [[AKAppLock sharedInstance] lock];
    if (self.emailPhoneTextField.text.length < 1) {
        NSString *message = self.isLoginState ? @"You need to enter code" : @"You need to eneter phone number";
        [self showMessage:message];
        return;
    }
    
    A0APIClient *client = [lock apiClient];
    
    //Getting code
    if (!self.isLoginState) {
        [client startPasswordlessWithPhoneNumber:self.emailPhoneTextField.text success:^{
            [self showMessage:@"Please check your sms and eneter code"];
            self.isLoginState = YES;
        } failure:^(NSError *error) {
            NSLog(@"Oops something went wrong: %@", error);
        }];
    } else {
        //Login with phone number and code
        [client loginWithPhoneNumber:self.phoneNumber
                            passcode:self.emailPhoneTextField.text
                          parameters:nil
                             success:^(A0UserProfile * _Nonnull profile, A0Token * _Nonnull tokenInfo) {
                                 [self storeToken:tokenInfo profile:profile];
                             } failure:^(NSError * _Nonnull error) {
                                 NSLog(@"Oops something went wrong: %@", error);
                                 [self clearData];
                             }];
    }
}

- (void)setIsLoginState:(BOOL)isLoginState {
    _isLoginState = isLoginState;
    
    self.actionNameLabel.text = isLoginState ? @"An SMS with the code has been sent" : @"Send Passcode";
    NSString *buttonName = isLoginState ? @"Login" : @"Send";
    [self.customSMSButton setTitle:buttonName forState:UIControlStateNormal];
    if (isLoginState) {
        self.phoneNumber = self.emailPhoneTextField.text;
        self.emailPhoneTextField.text = @"";
    }
}

//Social Connection
- (IBAction)clickTwitterButton:(id)sender {
    
    void(^success)(A0UserProfile *, A0Token *) = ^(A0UserProfile *profile, A0Token *token) {
        [self storeToken:token profile:profile];
    };
    void(^error)(NSError *) = ^(NSError *error) {
        NSLog(@"Oops something went wrong: %@", error);
        [self clearData];
    };
    A0Lock *lock = [[AKAppLock sharedInstance] lock];
    [[lock identityProviderAuthenticator] authenticateWithConnectionName:kTwitterConnectionName
                                                              parameters:nil
                                                                 success:success
                                                                 failure:error];

}

- (IBAction)clickFacebookButton:(id)sender {
    
    void(^success)(A0UserProfile *, A0Token *) = ^(A0UserProfile *profile, A0Token *token) {
        [self storeToken:token profile:profile];
    };
    void(^error)(NSError *) = ^(NSError *error) {
        NSLog(@"Oops something went wrong: %@", error);
        [self clearData];
    };
    
    A0Lock *lock = [[AKAppLock sharedInstance] lock];
    [[lock identityProviderAuthenticator] authenticateWithConnectionName:kFacebookConnectionName
                                                              parameters:nil
                                                                 success:success
                                                                 failure:error];
}

//Saving JWT Tokens
- (void)storeToken:(A0Token *)token profile:(A0UserProfile *)profile
{
    A0SimpleKeychain *keychain = [A0SimpleKeychain keychainWithService:kKeychainName];
    [keychain setString:token.idToken forKey:kIdTokenKeychainName];
    [keychain setString:token.refreshToken forKey:kRefreshTokenKeychainName];
    [keychain setString:token.accessToken forKey:kAccessTokenKeychainName];
    [keychain setData:[NSKeyedArchiver archivedDataWithRootObject:profile] forKey:kProfileKeychainName];
    
    self.userIdLabel.text = profile.userId;
    self.userNameLabel.text = profile.name;
}

- (void)clearData
{
    A0SimpleKeychain *keychain = [A0SimpleKeychain keychainWithService:kKeychainName];
    [keychain clearAll];
    
}

- (void)showMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Auth0" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
    });
}

@end
