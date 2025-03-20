//抖音视频加速悬浮按
//By @c00kiec00k
//2025.3.21



#import "AWETikTokSpeed.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#pragma mark - 全局定义
#define BTN_SIZE 40
#define MENU_MAX_WIDTH 280
#define ITEM_HEIGHT 70
#define DEFAULT_ALPHA 0.8
#define SAVE_KEY @"TikTokSpeedSettings"

#pragma mark - 全局变量
static UIButton *floatingButton;
static NSMutableArray *speedSettings;
static UIVisualEffectView *menuView;
static BOOL isButtonHidden = NO;

#pragma mark - 窗口获取函数
static inline UIWindow *GetKeyWindow() {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive &&
                [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) return window;
                }
            }
        }
    }
    return [[UIApplication sharedApplication].windows lastObject];
}

#pragma mark - Hook实现
%hook AWEPlayInteractionViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    [_TikTokSpeedButton setupButton];
}
%end

%hook AWEFeedCellViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    [_TikTokSpeedButton setupButton];
}
%end

%hook AWEAwemePlayVideoViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    [_TikTokSpeedButton setupButton];
    [self loadCurrentSpeed];
}
%end

#pragma mark - 菜单实现
@implementation _TikTokSpeedMenu

+ (void)showMenu {
    if (menuView) return;
    
    // 动态计算菜单尺寸
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat maxWidth = MIN(MENU_MAX_WIDTH, screenBounds.size.width * 0.8);
    CGFloat contentHeight = 5 * ITEM_HEIGHT + 20;
    CGFloat menuHeight = MIN(contentHeight, screenBounds.size.height * 0.6);
    
    // 毛玻璃效果
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    menuView = [[UIVisualEffectView alloc] initWithEffect:blur];
    menuView.frame = CGRectMake(0, 0, maxWidth, menuHeight);
    menuView.center = GetKeyWindow().center;
    menuView.layer.cornerRadius = 12;
    menuView.clipsToBounds = YES;
    
    // 关闭按钮
UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom]; // 修改为Custom类型
closeBtn.frame = CGRectMake(maxWidth - 190, 8, 110, 30);          
// 调整位置和尺寸
[closeBtn setTitle:@"点击空白处关闭" forState:UIControlStateNormal];
[closeBtn setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.6] forState:UIControlStateNormal]; 
// 设置白色文字
closeBtn.titleLabel.font = [UIFont systemFontOfSize:15];          
// 调整字号
closeBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0];
// 半透明背景
closeBtn.layer.cornerRadius = 6;                                  
// 圆角效果
[closeBtn addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
[menuView.contentView addSubview:closeBtn];
    
    // 滚动容器
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, maxWidth, menuHeight-44)];
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    
    // 菜单项布局
    NSArray *titles = @[@"⚙️1.0倍速", @"🏃‍♂️1.25倍速", @"🚲1.5倍速", @"🚗2.0倍速", @"🚀3.0倍速"];
    CGFloat yPos = 10;
    CGFloat contentWidth = maxWidth - 40;
    
    for (int i = 0; i < 5; i++) {
        UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(50, yPos, contentWidth, 50)];
        
        UISwitch *sw = [[UISwitch alloc] init];
        sw.tag = i;
        sw.on = [speedSettings[i] boolValue];
        [sw addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        sw.center = CGPointMake(30, 20);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, contentWidth-70, 28)];
        label.text = titles[i];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:16];
        label.adjustsFontSizeToFitWidth = YES;
        
        [itemView addSubview:sw];
        [itemView addSubview:label];
        [scrollView addSubview:itemView];
        yPos += ITEM_HEIGHT;
    }
    
    // 内容居中处理
    if (yPos < scrollView.bounds.size.height) {
        CGFloat offset = (scrollView.bounds.size.height - yPos)/2;
        scrollView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0);
    }
    scrollView.contentSize = CGSizeMake(contentWidth, yPos + 10);
    [menuView.contentView addSubview:scrollView];
    
    // 背景点击关闭
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)];
    tap.cancelsTouchesInView = NO;
    [menuView addGestureRecognizer:tap];
    
    // 入场动画
    menuView.alpha = 0;
    menuView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [GetKeyWindow() addSubview:menuView];
    
    [UIView animateWithDuration:0.3 delay:0 
        usingSpringWithDamping:0.7 
        initialSpringVelocity:0.5 
        options:0 
        animations:^{
            menuView.alpha = 1;
            menuView.transform = CGAffineTransformIdentity;
        } completion:nil];
}

+ (void)hideMenu {
    [UIView animateWithDuration:0.2 animations:^{
        menuView.alpha = 0;
        menuView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        [menuView removeFromSuperview];
        menuView = nil;
    }];
}

+ (void)switchChanged:(UISwitch *)sender {
    speedSettings[sender.tag] = @(sender.isOn);
    [[NSUserDefaults standardUserDefaults] setObject:speedSettings forKey:SAVE_KEY];
}

@end

#pragma mark - 悬浮按钮实现
@implementation _TikTokSpeedButton

+ (CGPoint)safeCenterPosition {
    CGRect screen = [UIScreen mainScreen].bounds;
    return CGPointMake(
        MAX(BTN_SIZE/2, MIN(screen.size.width - BTN_SIZE/2, screen.size.width/2)),
        MAX(BTN_SIZE/2 + 20, MIN(screen.size.height - BTN_SIZE/2, screen.size.height/2))
    );
}

+ (void)toggleVisibility {
    isButtonHidden = !isButtonHidden;
    floatingButton.hidden = isButtonHidden;
}

+ (void)setupButton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        speedSettings = [NSMutableArray arrayWithArray:
            [[NSUserDefaults standardUserDefaults] objectForKey:SAVE_KEY]];
        if (speedSettings.count != 5) {
            speedSettings = [@[@YES, @NO, @NO, @NO, @NO] mutableCopy];
        }
        
        floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingButton.frame = CGRectMake(0, 0, BTN_SIZE, BTN_SIZE);
        floatingButton.center = [self safeCenterPosition];
        floatingButton.layer.cornerRadius = BTN_SIZE/2;
        floatingButton.alpha = DEFAULT_ALPHA;
        floatingButton.backgroundColor = [UIColor colorWithWhite:0.1 alpha:DEFAULT_ALPHA];
        [floatingButton setTitle:@"1.0x" forState:UIControlStateNormal];
        floatingButton.titleLabel.font = [UIFont systemFontOfSize:14];
        
        // 异步加载图片
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData *data = [NSData dataWithContentsOfURL:
                [NSURL URLWithString:@"http://wp.qq-5.com/view.php/a103d414b150ab406a408068e5354064.png"]];
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [floatingButton setImage:image forState:UIControlStateNormal];
                });
            }
        });
        
        // 手势系统
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] 
            initWithTarget:self action:@selector(handlePan:)];
        [floatingButton addGestureRecognizer:pan];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] 
            initWithTarget:self action:@selector(handleTap)];
        [floatingButton addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] 
            initWithTarget:self 
                    action:@selector(handleLongPress:)];
        longPress.minimumPressDuration = 0.5;
        [floatingButton addGestureRecognizer:longPress];
    });
    
    if (!floatingButton.superview) {
        [GetKeyWindow() addSubview:floatingButton];
    }
}

+ (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIButton *btn = (UIButton *)gesture.view;
    CGPoint translation = [gesture translationInView:btn.superview];
    
    CGPoint newCenter = CGPointMake(
        btn.center.x + translation.x,
        btn.center.y + translation.y
    );
    
    CGRect screen = [UIScreen mainScreen].bounds;
    newCenter.x = MAX(BTN_SIZE/2, MIN(screen.size.width - BTN_SIZE/2, newCenter.x));
    newCenter.y = MAX(BTN_SIZE/2, MIN(screen.size.height - BTN_SIZE/2, newCenter.y));
    
    btn.center = newCenter;
    [gesture setTranslation:CGPointZero inView:btn.superview];
}

+ (void)handleTap {
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
    
    NSArray *speeds = @[@1.0, @1.25, @1.5, @2.0, @3.0];
    for (int i = 0; i < 5; i++) {
        if ([speedSettings[i] boolValue]) {
            [self changeSpeed:[speeds[i] doubleValue]];
            break;
        }
    }
}

+ (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [_TikTokSpeedMenu showMenu];
    }
}

+ (void)changeSpeed:(double)speed {
    UIViewController *rootVC = GetKeyWindow().rootViewController;
    if ([rootVC isKindOfClass:NSClassFromString(@"AWEAwemePlayVideoViewController")]) {
        [(AWEAwemePlayVideoViewController *)rootVC setPlayRate:speed];
        [floatingButton setTitle:[NSString stringWithFormat:@"%.1fx", speed] 
                       forState:UIControlStateNormal];
    }
}

@end

#pragma mark - 分类实现
@implementation UIViewController (TikTokSpeed)

- (void)loadCurrentSpeed {
    if ([self respondsToSelector:@selector(setPlayRate:)]) {
        [floatingButton setTitle:@"1.0x" forState:UIControlStateNormal];
    }
}

@end

#pragma mark - 构造函数
%ctor {
    @autoreleasepool {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), 
            dispatch_get_main_queue(), ^{
                UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc] 
                    initWithTarget:_TikTokSpeedButton.class 
                            action:@selector(toggleVisibility)];
                tripleTap.numberOfTapsRequired = 2;
                tripleTap.numberOfTouchesRequired = 3;
                [GetKeyWindow() addGestureRecognizer:tripleTap];
            });
    }
}