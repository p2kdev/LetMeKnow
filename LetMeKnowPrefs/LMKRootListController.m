#import <Preferences/Preferences.h>

@interface LMKRootListController : PSListController
@end

@implementation LMKRootListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"LetMeKnow" target:self] retain];
	}
	return _specifiers;
}

- (void)savePrefs {
  CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.imkpatil.letmeknow.settingschanged"), NULL, NULL, YES);
}

- (void)visitTwitter {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/p2kdev"]];
}

@end
