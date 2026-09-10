#import <AudioToolbox/AudioToolbox.h>
#import "AXNAppCell.h"
#import "AXNManager.h"

@interface AXNFrostedActionMenuController : UIViewController
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) dispatch_block_t clearAppHandler;
@property (nonatomic, copy) dispatch_block_t clearAllHandler;
- (instancetype)initWithAppName:(NSString *)appName clearApp:(dispatch_block_t)clearApp clearAll:(dispatch_block_t)clearAll;
@end

@implementation AXNFrostedActionMenuController

- (instancetype)initWithAppName:(NSString *)appName clearApp:(dispatch_block_t)clearApp clearAll:(dispatch_block_t)clearAll {
    self = [super init];
    if (self) {
        _appName = [appName copy] ?: @"应用";
        _clearAppHandler = [clearApp copy];
        _clearAllHandler = [clearAll copy];
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (UIButton *)buttonWithTitle:(NSString *)title color:(UIColor *)color action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.contentEdgeInsets = UIEdgeInsetsMake(12, 14, 12, 14);
    return button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.16];

    UIControl *dismissArea = [[UIControl alloc] initWithFrame:CGRectZero];
    dismissArea.translatesAutoresizingMaskIntoConstraints = NO;
    [dismissArea addTarget:self action:@selector(dismissMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismissArea];
    [NSLayoutConstraint activateConstraints:@[
        [dismissArea.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [dismissArea.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [dismissArea.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [dismissArea.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
    UIVisualEffectView *card = [[UIVisualEffectView alloc] initWithEffect:effect];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.layer.cornerRadius = 22;
    card.layer.cornerCurve = kCACornerCurveContinuous;
    card.clipsToBounds = YES;
    [self.view addSubview:card];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    title.textAlignment = NSTextAlignmentCenter;
    title.numberOfLines = 1;
    title.text = [NSString stringWithFormat:@"%@ 的通知", self.appName];

    UIButton *clearApp = [self buttonWithTitle:@"清除此应用" color:[UIColor systemRedColor] action:@selector(clearApp)];
    UIButton *clearAll = [self buttonWithTitle:@"清除全部" color:[UIColor systemRedColor] action:@selector(clearAll)];
    UIButton *cancel = [self buttonWithTitle:@"取消" color:[UIColor labelColor] action:@selector(dismissMenu)];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectZero];
    separator.backgroundColor = [UIColor separatorColor];
    separator.translatesAutoresizingMaskIntoConstraints = NO;

    UIStackView *actions = [[UIStackView alloc] initWithArrangedSubviews:@[clearApp, separator, clearAll]];
    actions.translatesAutoresizingMaskIntoConstraints = NO;
    actions.axis = UILayoutConstraintAxisHorizontal;
    actions.alignment = UIStackViewAlignmentCenter;
    actions.distribution = UIStackViewDistributionFillEqually;
    [separator.widthAnchor constraintEqualToConstant:1].active = YES;
    [separator.heightAnchor constraintEqualToConstant:28].active = YES;

    UIStackView *content = [[UIStackView alloc] initWithArrangedSubviews:@[title, actions, cancel]];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    content.axis = UILayoutConstraintAxisVertical;
    content.alignment = UIStackViewAlignmentFill;
    content.spacing = 8;
    [card.contentView addSubview:content];
    [NSLayoutConstraint activateConstraints:@[
        [card.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [card.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [card.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor constant:-42],
        [card.widthAnchor constraintEqualToConstant:300],
        [content.topAnchor constraintEqualToAnchor:card.contentView.topAnchor constant:18],
        [content.leadingAnchor constraintEqualToAnchor:card.contentView.leadingAnchor constant:10],
        [content.trailingAnchor constraintEqualToAnchor:card.contentView.trailingAnchor constant:-10],
        [content.bottomAnchor constraintEqualToAnchor:card.contentView.bottomAnchor constant:-10]
    ]];
}

- (void)clearApp { if (self.clearAppHandler) self.clearAppHandler(); [self dismissMenu]; }
- (void)clearAll { if (self.clearAllHandler) self.clearAllHandler(); [self dismissMenu]; }
- (void)dismissMenu { [self dismissViewControllerAnimated:YES completion:nil]; }
@end

@implementation AXNAppCell

static NSDictionary *axnCellPrefs;

UIView *getBlurView(CGRect frame) {
    NSInteger darkModeTmp = [axnCellPrefs[@"DarkMode"] intValue] ?: 0;
    UIView *blurView;
    if(darkModeTmp == 0) {
        id materialView = objc_getClass("MTMaterialView");
        if([materialView respondsToSelector:@selector(materialViewWithRecipe:options:)]) blurView = [materialView materialViewWithRecipe:MTMaterialRecipeNotifications options:MTMaterialOptionsBlur];
        else blurView = [materialView materialViewWithRecipe:MTMaterialRecipeNotifications configuration:1];
        blurView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    } else if(darkModeTmp == 1) {
        blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    } else if(darkModeTmp == 2) {
        blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    }
    if (!blurView) {
        blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial]];
    }
    blurView.frame = frame;
    return blurView;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _style = -1;

    // for some unknown reason AXNView isn't able to set badgesEnabled, so i'm loading it from the preferences
    axnCellPrefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.q1643240.axon17.plist"] ?: @{};
    self.badgesEnabled = axnCellPrefs[@"BadgesEnabled"] != nil ? [axnCellPrefs[@"BadgesEnabled"] boolValue] : YES;

    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
    [self addGestureRecognizer:recognizer];

    self.layer.cornerRadius = 13;
    self.layer.continuousCorners = YES;
    self.layer.masksToBounds = YES;

    self.iconView = [[UIImageView alloc] initWithFrame:frame];
    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;

    if (self.badgesEnabled) {
      self.badgeLabel = [[UILabel alloc] initWithFrame:frame];
      self.badgeLabel.font = [UIFont boldSystemFontOfSize:14];
      self.badgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
      self.badgeLabel.text = @"0";
      self.badgeLabel.textColor = [UIColor whiteColor];
      self.badgeLabel.backgroundColor = [UIColor blackColor];
      self.badgeLabel.layer.cornerRadius = 10;
      self.badgeLabel.layer.masksToBounds = YES;
      self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    }

    self.blurView = getBlurView(CGRectMake(0, 0, frame.size.width, frame.size.height));
    // self.blurView.bounds = self.bounds;

    if (self.badgesEnabled) {
      _styleConstraints = @[
        @[  // default
            [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-30],
            [self.badgeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [self.badgeLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10],
            [self.badgeLabel.heightAnchor constraintEqualToConstant:20],
            [self.badgeLabel.widthAnchor constraintEqualToConstant:30],
        ],
        @[  // packed
            [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10],
            [self.badgeLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5],
            [self.badgeLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],
            [self.badgeLabel.heightAnchor constraintEqualToConstant:20],
            [self.badgeLabel.widthAnchor constraintEqualToConstant:30],
        ],
        @[  // compact
            [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],
            [self.badgeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [self.badgeLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],
            [self.badgeLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
            [self.badgeLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
        ],
        @[  // tiny
            [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-25],
            [self.badgeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [self.badgeLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],
            [self.badgeLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5],
            [self.badgeLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5],
        ],
        @[  // group
            [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-28],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],

            [self.badgeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [self.badgeLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:5],
            [self.badgeLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],
            [self.badgeLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [self.badgeLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
        ],
        @[  // group rounded
            [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:3],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-26],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8],

            [self.badgeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [self.badgeLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
            [self.badgeLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8],
            [self.badgeLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:33],
            [self.badgeLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-7],
        ]
      ];
    } else if (!self.badgesEnabled) {
      _styleConstraints = @[
        @[  // default
            [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10],
        ],
        @[  // packed
            [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10],
        ],
        @[  // compact
            [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],
        ],
        @[  // tiny
            [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],
        ],
        @[  // group
            [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],
        ],
        @[  // group rounded
            [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8],
        ]
      ];
    }

    return self;
}

-(UISemanticContentAttribute)semanticContentAttribute {
  return UISemanticContentAttributeForceLeftToRight;
}

-(void)axnClearAll {
    [[AXNManager sharedInstance] clearAll:self.bundleIdentifier];
}
-(void)axnRealClearAll {
  [[AXNManager sharedInstance] clearAll];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(axnClearAll));
}

-(NSString *)getAppName {
    NSString *name = [AXNManager sharedInstance].names[self.bundleIdentifier];
    return name.length > 0 ? name : self.bundleIdentifier;
}

-(void)showMenu:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    UIResponder *responder = self;
    while (responder && [responder isKindOfClass:[UIView class]]) {
        responder = [responder nextResponder];
    }
    if (![responder isKindOfClass:[UIViewController class]]) return;

    AudioServicesPlaySystemSound(1519);
    __weak typeof(self) weakSelf = self;
    AXNFrostedActionMenuController *menu = [[AXNFrostedActionMenuController alloc] initWithAppName:[self getAppName] clearApp:^{
        [weakSelf axnClearAll];
    } clearAll:^{
        [weakSelf axnRealClearAll];
    }];
    [(UIViewController *)responder presentViewController:menu animated:YES completion:nil];
}

-(void)setBundleIdentifier:(NSString *)value {
    _bundleIdentifier = value;

    if(self.iconStyle == 0) self.iconView.image = [[AXNManager sharedInstance] getIcon:value rounded:_style == 5];
    else if(self.iconStyle == 1) self.iconView.image = [[AXNManager sharedInstance] getIcon:value rounded:true];
    else if(self.iconStyle == 2) self.iconView.image = [[AXNManager sharedInstance] getIcon:value rounded:false];

    self.badgeLabel.backgroundColor = [UIColor clearColor];
    if(_style != 4) self.badgeLabel.textColor = [[AXNManager sharedInstance] fallbackColor];
    if(_style == 5) self.badgeLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];

    BOOL iOS13 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 13;

    if (self.badgesShowBackground && self.iconView.image && _style != 4) {
        if ([AXNManager sharedInstance].backgroundColorCache[value] && [AXNManager sharedInstance].textColorCache[value]) {
            self.badgeLabel.backgroundColor = [[AXNManager sharedInstance].backgroundColorCache[value] copy];
            self.badgeLabel.textColor = [[AXNManager sharedInstance].textColorCache[value] copy];
        } else {
          if(iOS13) {
            CGSize size = {1, 1};
            UIGraphicsBeginImageContext(size);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSetInterpolationQuality(ctx, kCGInterpolationMedium);
            [[self.iconView.image copy] drawInRect:(CGRect){.size = size} blendMode:kCGBlendModeCopy alpha:1];
            uint8_t *data = CGBitmapContextGetData(ctx);
            UIColor *backgroundColor = [UIColor colorWithRed:data[2] / 255.0f green:data[1] / 255.0f blue:data[0] / 255.0f alpha:1];
            UIGraphicsEndImageContext();
            CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
            [backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
            int threshold = 105;
            int bgDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114));
            UIColor *textColor = (255 - bgDelta < threshold) ? [UIColor blackColor] : [UIColor whiteColor];
            self.badgeLabel.backgroundColor = [backgroundColor copy];
            self.badgeLabel.textColor = [textColor copy];
          } else {
            __weak AXNAppCell *weakSelf = self;
            MPArtworkColorAnalyzer *colorAnalyzer = [[MPArtworkColorAnalyzer alloc] initWithImage:self.iconView.image algorithm:0];
            [colorAnalyzer analyzeWithCompletionHandler:^(MPArtworkColorAnalyzer *analyzer, MPArtworkColorAnalysis *analysis) {
                [AXNManager sharedInstance].backgroundColorCache[value] = [analysis.backgroundColor copy];
                [AXNManager sharedInstance].textColorCache[value] = [analysis.primaryTextColor copy];
                [weakSelf badgeLabel].backgroundColor = [analysis.backgroundColor copy];
                [weakSelf badgeLabel].textColor = [analysis.primaryTextColor copy];
            }];
          }
        }
    }
}

-(void)setNotificationCount:(NSInteger)value {
    _notificationCount = value;

    if (value <= 99) {
        self.badgeLabel.text = [NSString stringWithFormat:@"%ld", value];
    } else {
        self.badgeLabel.text = @"99+";
    }
}

-(void)setSelectionStyle:(NSInteger)style {
    _selectionStyle = style;

    self.iconView.alpha = 1.0;
    self.badgeLabel.alpha = 1.0;
    self.backgroundColor = [UIColor clearColor];
}

-(void)setStyle:(NSInteger)style {
    if (_style == style) return;
    NSInteger oldStyle = _style;

    if (style >= [_styleConstraints count] || style < 0) _style = 0;
    else _style = style;

    if (style == 2) self.badgeLabel.layer.cornerRadius = 8;
    if(style == 3 || style == 4 || style == 5) {
      if (style == 3) {
        self.layer.cornerRadius = 10;
        self.badgeLabel.layer.cornerRadius = 8;
      } else if(style == 4) {
        self.layer.cornerRadius = 10;
        self.badgeLabel.textAlignment = NSTextAlignmentRight;
        self.badgeLabel.backgroundColor = [UIColor clearColor];
        self.badgeLabel.textColor = [UIColor whiteColor];
      } else {
        self.layer.cornerRadius = 18;
        self.alpha = 0.5;
        self.badgeLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
      }
      if (self.addBlur || style == 4 || style == 5) [self addSubview:self.blurView];
      if (self.badgesEnabled) [self addSubview:self.badgeLabel];
      [self addSubview:self.iconView];
    } else {
      if (self.addBlur || style == 4 || style == 5) [self addSubview:self.blurView];
      [self addSubview:self.iconView];
      if (self.badgesEnabled) [self addSubview:self.badgeLabel];
    }

    if (oldStyle != -1) [NSLayoutConstraint deactivateConstraints:_styleConstraints[oldStyle]];
    [NSLayoutConstraint activateConstraints:_styleConstraints[_style]];
    [self setNeedsLayout];
}

-(void)setDarkMode:(NSInteger)darkMode {
    if (_darkMode == darkMode) return;

    self.blurView = getBlurView(self.blurView.frame);
    self.badgeLabel.textColor = darkMode ? [UIColor whiteColor] : [UIColor blackColor];
    self.badgeLabel.alpha = 0.4f;

    [self setNeedsDisplay];
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if(self.selectionStyle == 2) return;

    if (selected) {
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            switch (self.selectionStyle) {
                case 1:
                    self.iconView.alpha = 1.0;
                    self.badgeLabel.alpha = 1.0;
                    break;
                default:
                    if (!self.darkMode) self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
                    else if (self.darkMode) self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            }
        } completion:NULL];
    } else {
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            switch (self.selectionStyle) {
                case 1:
                    self.iconView.alpha = 0.5;
                    self.badgeLabel.alpha = 0.5;
                    break;
                default:
                    self.backgroundColor = [UIColor clearColor];
            }
        } completion:NULL];
    }
}

@end
