#import <Preferences/Preferences.h>

#define LetMeKnowPath @"/User/Library/Preferences/com.imkpatil.letmeknow.plist"

@interface LMKRootListController : PSListController
@end

@implementation LMKRootListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"LetMeKnow" target:self] retain];
	}
	return _specifiers;
}

-(id) readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *letmeknowsettings = [NSDictionary dictionaryWithContentsOfFile:LetMeKnowPath];
    if (!letmeknowsettings[specifier.properties[@"key"]]) {
        return specifier.properties[@"default"];
    }
    return letmeknowsettings[specifier.properties[@"key"]];
}

-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:LetMeKnowPath]];
    [defaults setObject:value forKey:specifier.properties[@"key"]];
    [defaults writeToFile:LetMeKnowPath atomically:YES];
    //  NSDictionary *powercolorSettings = [NSDictionary dictionaryWithContentsOfFile:powercolorPath];
    CFStringRef toPost = (CFStringRef)specifier.properties[@"PostNotification"];
    if(toPost) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
}

- (void)visitTwitter {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/p2kdev"]];
}

@end
