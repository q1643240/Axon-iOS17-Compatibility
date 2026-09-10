#import <AppList/AppList.h>
#import "AXNController.h"

@interface AXNDebugController : PSListController
@end

@implementation AXNDebugController

-(id)specifiers {
    if (_specifiers == nil) {
        NSMutableArray *specifiers = [[NSMutableArray alloc] init];

        [specifiers addObject:({
            PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"调试选项" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
            [specifier.properties setValue:@"仅在排查问题时使用。清除操作只会处理 Axon 已登记的通知。" forKey:@"footerText"];
            specifier;
        })];
        [specifiers addObject:({
            PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"清除全部 Axon 通知" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
            specifier->action = @selector(clearAll);
            specifier;
        })];
        [specifiers addObject:({
            PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"保存通知列表" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
            specifier->action = @selector(saveNotification);
            specifier;
        })];
        [specifiers addObject:({
            PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"提交问题反馈" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
            specifier->action = @selector(report);
            specifier;
        })];
        _specifiers = [specifiers copy];
    }
    return _specifiers;
}

-(void)clearAll {
    [[objc_getClass("NSDistributedNotificationCenter") defaultCenter] postNotificationName:@"com.q1643240.axon17.clearAllNotification" object:nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"调试" message:@"已请求清除 Axon 已登记的全部通知。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)saveNotification {
    [[objc_getClass("NSDistributedNotificationCenter") defaultCenter] postNotificationName:@"com.q1643240.axon17.saveNotification" object:nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"调试" message:@"已请求将 Axon 通知列表保存到 /var/mobile/Documents/AxonDebug.txt。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)report {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/q1643240/Axon-iOS17-Compatibility/issues/new"] options:@{} completionHandler:nil];
}

@end
