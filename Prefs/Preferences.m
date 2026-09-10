#import "Preferences.h"
#include <unistd.h>
#include <spawn.h>
#include <Foundation/Foundation.h>
#import "AXNPaths.h"

@implementation AXNPrefsListController
@synthesize respringButton;

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
        self.navigationItem.rightBarButtonItem = self.respringButton;
        
        self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = @"Axon";
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.navigationItem.titleView addSubview:self.titleLabel];
        
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        const char *iconPathC = AXNRootPath("/Library/PreferenceBundles/AxonPrefs.bundle/icon@2x.png");
        NSString *iconPath = [NSString stringWithUTF8String:iconPathC];
        self.iconView.image = [UIImage imageWithContentsOfFile:iconPath];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconView.alpha = 0.0;
        [self.navigationItem.titleView addSubview:self.iconView];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
        ]];
    }
    
    return self;
}

-(id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Prefs" target:self];
    }
    return _specifiers;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    const char *bannerPathC = AXNRootPath("/Library/PreferenceBundles/AxonPrefs.bundle/axon.png");
    NSString *bannerPath = [NSString stringWithUTF8String:bannerPathC];
    self.headerImageView.image = [UIImage imageWithContentsOfFile:bannerPath];
    self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.headerView addSubview:self.headerImageView];
    [NSLayoutConstraint activateConstraints:@[
        [self.headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
        [self.headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
        [self.headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
        [self.headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
    ]];
    
    _table.tableHeaderView = self.headerView;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.headerView && self.headerView.frame.size.width != self.table.bounds.size.width) {
        self.headerView.frame = CGRectMake(0, 0, self.table.bounds.size.width, 200);
        self.headerImageView.frame = self.headerView.bounds;
        self.table.tableHeaderView = self.headerView;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];

    if (![[specifier propertyForKey:@"key"] isEqualToString:@"Style"]) return;
    UIAlertController *notice = [UIAlertController alertControllerWithTitle:@"样式已切换" message:@"图标样式会立即刷新；纵向模式或位置布局变更仍需注销后完全生效。" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:notice animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (notice.presentingViewController) [notice dismissViewControllerAnimated:YES completion:nil];
    });
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY > 200) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    }
    
    if (offsetY > 0) offsetY = 0;
    self.headerImageView.frame = CGRectMake(0, offsetY, self.headerView.frame.size.width, 200 - offsetY);
}

-(void)respring {
    pid_t pid;
    char* args[] = {"/usr/bin/killall", "backboardd", NULL};
    posix_spawn(&pid, AXNRootPath(args[0]), NULL, NULL, args, NULL);
}

@end

