//抖音视频加速悬浮按
//By @c00kiec00k
//2025.3.21

#import <UIKit/UIKit.h>

// 声明抖音原生类
@interface AWEPlayInteractionViewController : UIViewController
@end

@interface AWEFeedCellViewController : UIViewController
@end

@interface AWEAwemePlayVideoViewController : UIViewController
- (void)setPlayRate:(double)rate;
@end

// 声明插件类
@interface _TikTokSpeedMenu : NSObject
+ (void)showMenu;
+ (void)hideMenu;
@end

@interface _TikTokSpeedButton : NSObject
+ (void)setupButton;
+ (void)toggleVisibility;
@end

// 分类扩展声明
@interface UIViewController (TikTokSpeed)
- (void)loadCurrentSpeed;
@end