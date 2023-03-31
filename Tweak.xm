#import <AudioToolbox/AudioToolbox.h>
#import <sys/utsname.h>
#import <UIKit/UIImpactFeedbackGenerator.h>
#import <UIKit/UINotificationFeedbackGenerator.h>

@interface TUCall
  @property (getter=isIncoming,nonatomic,readonly) BOOL incoming;
  @property (nonatomic,readonly) int callStatus;
@end

@interface MPTelephonyManager
  @property (atomic,assign) TUCall * activeCall;
  -(void)handleCallStatusChanged:(id)arg1;
  -(void)PlayVibration;
@end

static BOOL wasCallConnected = NO;
static BOOL VibrOnDiscConn = YES ;
static int callType = 1;
static NSString* VibrStrength = @"Medium";

static void PerfromVibration()
{
  BOOL IsDeviceNewer = true;
  struct utsname systemInfo;
  uname(&systemInfo);
  NSString *pl = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

  if ([pl isEqualToString:@"iPhone6,1"] ||
      [pl isEqualToString:@"iPhone6,2"] ||
      [pl isEqualToString:@"iPhone7,1"] ||
      [pl isEqualToString:@"iPhone7,2"] ||
      [pl isEqualToString:@"iPhone8,1"] ||
      [pl isEqualToString:@"iPhone8,2"] ||
      [pl isEqualToString:@"iPhone8,4"])
  {
      IsDeviceNewer = false;
  }

  if (IsDeviceNewer)
  {

    if ([VibrStrength isEqualToString:@"Heavy"])
    {
      UIImpactFeedbackGenerator *myGen = [[UIImpactFeedbackGenerator alloc] init];
      [myGen initWithStyle:(UIImpactFeedbackStyleHeavy)];
      [myGen impactOccurred];
    }
    else if ([VibrStrength isEqualToString:@"Light"])
    {
      UIImpactFeedbackGenerator *myGen = [[UIImpactFeedbackGenerator alloc] init];
      [myGen initWithStyle:(UIImpactFeedbackStyleLight)];
      [myGen impactOccurred];
    }
    else if ([VibrStrength isEqualToString:@"Success"])
    {
      UINotificationFeedbackGenerator *myGen = [[UINotificationFeedbackGenerator alloc] init];
      [myGen notificationOccurred:UINotificationFeedbackTypeSuccess];
    }
    else if ([VibrStrength isEqualToString:@"Warning"])
    {
      UINotificationFeedbackGenerator *myGen = [[UINotificationFeedbackGenerator alloc] init];
      [myGen notificationOccurred:UINotificationFeedbackTypeWarning];
    }
    else if ([VibrStrength isEqualToString:@"Error"])
    {
      UINotificationFeedbackGenerator *myGen = [[UINotificationFeedbackGenerator alloc] init];
      [myGen notificationOccurred:UINotificationFeedbackTypeError];
    }
    else if ([VibrStrength isEqualToString:@"Standard"])
    {
      AudioServicesPlaySystemSound(1352);
    }
    else
    {
      UIImpactFeedbackGenerator *myGen = [[UIImpactFeedbackGenerator alloc] init];
      [myGen initWithStyle:(UIImpactFeedbackStyleMedium)];
      [myGen impactOccurred];
    }

    //NSLog(@"[LetMeKnow] - Vibration Strength - %@",VibrStrength);
  }
  else
  {
      AudioServicesPlaySystemSound(1352);
  }
}

%hook TUCall
  -(void)_handleStatusChange
  {
    int callStat = self.callStatus;
    // NSString *msg = [NSString stringWithFormat:@"CallStatus %d",callStat];
    // UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"CallStatus" message:msg delegate:[[UIApplication sharedApplication] keyWindow].rootViewController cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    // [alertView show];
    // [alertView release];

    bool isIncoming = self.isIncoming;

    if (callStat == 1)
    {
      if ((callType == 1 && !isIncoming) || (callType == 2))
      {
        PerfromVibration();
      }
      wasCallConnected = YES;
    }

    if (callStat == 0 || callStat == 6)
    {
      if (VibrOnDiscConn && wasCallConnected)
      {
        PerfromVibration();
      }
      wasCallConnected = NO;
    }

    %orig;
  }

%end

  static void reloadSettings() {
		static CFStringRef prefsKey = CFSTR("com.imkpatil.letmeknow");
		CFPreferencesAppSynchronize(prefsKey);

		if (CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"WantsVibrOnDisc", prefsKey))) {
			VibrOnDiscConn = [(id)CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"WantsVibrOnDisc", prefsKey)) boolValue];
		}

		if (CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"LMKStrength", prefsKey))) {
			VibrStrength = [(id)CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"LMKStrength", prefsKey)) stringValue];
		}

		if (CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"CallTypeForVibration", prefsKey))) {
			callType = [(id)CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"CallTypeForVibration", prefsKey)) intValue];
		}        
  }

  static void PerformVibrationAction() {
    reloadSettings();
    PerfromVibration();
  }

  %ctor {
      CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)PerformVibrationAction, CFSTR("com.imkpatil.letmeknow.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
      reloadSettings();
  }
