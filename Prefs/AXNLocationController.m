#import "AXNController.h"

static NSString * const AXNReloadNotification = @"com.q1643240.axon17/ReloadPrefs";

@interface AXNLocationController : PSListController {
    PSSpecifier *_autoLayoutLocationSpecifier;
    PSSpecifier *_yAxisSpecifier;
}
@property (nonatomic, strong) NSMutableDictionary *axonLocationPrefs;
@property (nonatomic, strong) PSSpecifier *autoLayoutLocationSpecifier;
@property (nonatomic, strong) PSSpecifier *yAxisSpecifier;
@end

@implementation AXNLocationController

-(id)specifiers {
    if (_specifiers == nil) {
        self.axonLocationPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCE_IDENTIFIER] ?: [NSMutableDictionary dictionary];
        NSMutableArray *specifiers = [NSMutableArray array];

        [specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"位置" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
        PSSpecifier *autoLayout = [PSSpecifier preferenceSpecifierNamed:@"自动布局" target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
        [autoLayout.properties setValue:@"autoLayout" forKey:@"displayIdentifier"];
        [specifiers addObject:autoLayout];

        [specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"纵向位置" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
        self.autoLayoutLocationSpecifier = [PSSpecifier preferenceSpecifierNamed:@"显示位置" target:self set:@selector(setNumber:forSpecifier:) get:@selector(getValueForSpecifier:) detail:nil cell:PSSegmentCell edit:nil];
        [self.autoLayoutLocationSpecifier setValues:@[@0, @1] titles:@[@"顶部", @"底部（测试版）"]];
        [self.autoLayoutLocationSpecifier.properties setValue:@"location" forKey:@"displayIdentifier"];

        self.yAxisSpecifier = [PSSpecifier preferenceSpecifierNamed:@"纵向偏移" target:self set:@selector(setNumber:forSpecifier:) get:@selector(getValueForSpecifier:) detail:nil cell:PSSliderCell edit:nil];
        [self.yAxisSpecifier setProperty:@"yAxis" forKey:@"displayIdentifier"];
        [self.yAxisSpecifier setProperty:@500 forKey:@"default"];
        [self.yAxisSpecifier setProperty:@0 forKey:@"min"];
        [self.yAxisSpecifier setProperty:@([UIScreen mainScreen].bounds.size.height) forKey:@"max"];
        [self.yAxisSpecifier setProperty:@YES forKey:@"showValue"];

        [specifiers addObject:[[self getValue:@"autoLayout"] boolValue] ? self.autoLayoutLocationSpecifier : self.yAxisSpecifier];
        _specifiers = [specifiers copy];
    }
    return _specifiers;
}

-(void)writePreferencesAndReload {
    [self.axonLocationPrefs writeToFile:PREFERENCE_IDENTIFIER atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)AXNReloadNotification, NULL, NULL, YES);
}

-(void)setSwitch:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
    self.axonLocationPrefs[[specifier propertyForKey:@"displayIdentifier"]] = @([value boolValue]);
    [self writePreferencesAndReload];

    if ([[specifier propertyForKey:@"displayIdentifier"] isEqualToString:@"autoLayout"]) {
        if ([value boolValue]) {
            [self removeSpecifier:self.yAxisSpecifier animated:YES];
            [self addSpecifier:self.autoLayoutLocationSpecifier animated:YES];
        } else {
            [self removeSpecifier:self.autoLayoutLocationSpecifier animated:YES];
            [self addSpecifier:self.yAxisSpecifier animated:YES];
        }
    }
}

-(void)setNumber:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
    self.axonLocationPrefs[[specifier propertyForKey:@"displayIdentifier"]] = value;
    [self writePreferencesAndReload];
}

-(NSNumber *)getSwitch:(PSSpecifier *)specifier {
    return [self getValue:[specifier propertyForKey:@"displayIdentifier"]];
}

-(NSNumber *)getValueForSpecifier:(PSSpecifier *)specifier {
    return [self getValue:[specifier propertyForKey:@"displayIdentifier"]];
}

-(NSNumber *)getValue:(NSString *)name {
    NSNumber *stored = self.axonLocationPrefs[name];
    if (stored) return stored;
    if ([name isEqualToString:@"autoLayout"]) return @YES;
    if ([name isEqualToString:@"yAxis"]) return @500;
    return @0;
}

@end
