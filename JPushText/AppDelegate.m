
/*
    移除别名标签需注意：没有做退出登录，需在willTerminate中移除数据库；此处移除标签会失败，因为删除标签是一个异步过程，耗时；
    启动极光登录成功之后可以设置一个不相关的标签 这个不登录就收不到通知
    如果需求是要求登录之后收到之前发的消息，那这个也不实用了，只能使用自定义消息
*/

/*群推：
    测试中需要在后台用户分群里面 创建群组 设置标签 地理位置 等
    根据注册时 设置的tags和alias进行推送
 */

/*
 推送通知消息负载内容
 每个推送通知都带有内容负载，这个负载内容会被应用程序下载并提醒用户收到数据。负载内容最大允许为256个字节，苹果推送通知服务器拒绝任何超过最大负载字节的推送通知。记住，通知的提交是“尽力而为”，它并不能得到保证。
 */

/*
 对于BadgeNumber的值，在推送消息中用badge来设置，客户端可以用[UIApplication sharedApplication].applicationIconBadgeNumber对红点数进行修改。并且每当有推送过来的时候，显示的BadgeNumber都会跟推送中设置的值一致，不会自动累加。
 远程APS的推送角标需要服务器去赋值badge，再传给苹果服务器。然后苹果服务器推送到客户端
 */

/*
 真机调试该项目，如果控制台输出以下日志则代表您已经集成成功。
 2016-08-19 17:12:12.745823 219b28[1443:286814]  | JPUSH | I - [JPUSHLogin]
 ----- login result -----
 uid:5460310207
 registrationID:171976fa8a8620a14a4
 
 比如：
 ----- login result -----
 uid:10474274895
 registrationID:1a1018970a939fb1af2
 
 RegistrationID 定义
 
 + (NSString *)registrationID;
 
 + (void)registrationIDCompletionHandler:(void(^)(int resCode,NSString *registrationID))completionHandler;
 
 集成了 JPush SDK 的应用程序在第一次成功注册到 JPush 服务器时，JPush 服务器会给客户端返回一个唯一的该设备的标识 - RegistrationID。JPush SDK 会以广播的形式发送 RegistrationID 到应用程序。
 应用程序可以把此 RegistrationID 保存以自己的应用服务器上，然后就可以根据 RegistrationID 来向设备推送消息或者通知。
 
 */

/*
 JPush SDK 相关事件监听
 
 extern NSString *const kJPFNetworkIsConnectingNotification; // 正在连接中
 extern NSString * const kJPFNetworkDidSetupNotification; // 建立连接
 extern NSString * const kJPFNetworkDidCloseNotification; // 关闭连接
 extern NSString * const kJPFNetworkDidRegisterNotification; // 注册成功
 extern NSString *const kJPFNetworkFailedRegisterNotification; //注册失败
 extern NSString * const kJPFNetworkDidLoginNotification; // 登录成功
 extern NSString * const kJPFNetworkDidReceiveMessageNotification; // 收到自定义消息(非APNs)
 */

/*
 Jpush自定义消息
 只有在前端运行的时候才能收到自定义消息的推送。 基于长连接
 在后台点击app图标会触发通知回调
 从jpush服务器获取用户推送的自定义消息内容和标题以及附加字段等。
 */

/*
    标签与别名 API (iOS)
    只有call back 返回值为 0 才设置成功，才可以向目标推送。否则服务器 API 会返回1011错误。所有回调函数都在主线程运行。
 
 别名 alias
 
 为安装了应用程序的用户，取个别名来标识。以后给该用户 Push 消息时，就可以用此别名来指定。
 每个用户只能指定一个别名。
 同一个应用程序内，对不同的用户，建议取不同的别名。这样，尽可能根据别名来唯一确定用户。
 系统不限定一个别名只能指定一个用户。如果一个别名被指定到了多个用户，当给指定这个别名发消息时，服务器端API会同时给这多个用户发送消息。
 举例：在一个用户要登录的游戏中，可能设置别名为 userid。游戏运营时，发现该用户 3 天没有玩游戏了，则根据 userid 调用服务器端API发通知到客户端提醒用户。
 
 Method - setAlias:completion:seq:调用此 API 来设置别名
 Method - deleteAlias:completion:seq:来删除别名
 Method - getAlias:completion:seq:查询当前别名
 
 typedef void (^JPUSHAliasOperationCompletion)(NSInteger iResCode, NSString *iAlias, NSInteger seq);
 
 标签 tag 
 限制：每个 tag 命名长度限制为 40 字节，最多支持设置 1000 个 tag，但总长度不得超过5K字节。（判断长度需采用UTF-8编码）
 
 为安装了应用程序的用户，打上标签。其目的主要是方便开发者根据标签，来批量下发 Push 消息。
 可为每个用户打多个标签。
 举例： game, old_page, women
 Method - addTags:completion:seq:增加逻辑
 Method - setTags:completion:seq:覆盖逻辑
 Method - deleteTags:completion:seq:删除标签
 Method - clearTags:completion:seq:清除所有标签 0为成功
 Method - getAllTags:completion:seq: 获取所有标签
 Method - validTag:completion:seq:验证目标tag是否已经设置
 Method - filterValidTags用于过滤出正确可用的 tags 如果总数量超出最大限制则返回最大数量的靠前的可用tags。
 

 typedef void (^JPUSHTagsOperationCompletion)(NSInteger iResCode, NSSet *iTags, NSInteger seq);
 typedef void (^JPUSHTagValidOperationCompletion)(NSInteger iResCode, NSSet *iTags, NSInteger seq, BOOL isBind);

 Method - setTagsWithAlias (with Callback)设置别名与标签
 
 
 
 */

#import "AppDelegate.h"

// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用idfa功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>

@interface AppDelegate ()<JPUSHRegisterDelegate>

@end

@implementation AppDelegate

#pragma mark - 添加初始化APNs代码
#pragma mark - 添加初始化JPush代码

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //添加初始化APNs代码
    
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    //新版本的注册方法（兼容iOS10）
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    //添加初始化JPush代码
    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    /*
     appKey
     填写管理Portal上创建应用后自动生成的AppKey值。请确保应用内配置的 AppKey 与 Portal 上创建应用后生成的 AppKey 一致。
     channel
     指明应用程序包的下载渠道，为方便分渠道统计，具体值由你自行定义，如：App Store。
     apsForProduction
     1.3.1版本新增，用于标识当前应用所使用的APNs证书环境。
     0 (默认值)表示采用的是开发证书，1 表示采用生产证书发布应用。
     注：此字段的值要与Build Settings的Code Signing配置的证书环境一致。
     advertisingIdentifier
     */
    [JPUSHService setupWithOption:launchOptions
                           appKey:JPush_APPKEY
                          channel:@"iOS"
                 apsForProduction:NO
            advertisingIdentifier:advertisingId];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kJPFNetworkIsConnectingNotification:) name:kJPFNetworkDidSetupNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kJPFNetworkDidSetupNotification:) name:kJPFNetworkDidSetupNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kJPFNetworkDidCloseNotification:) name:kJPFNetworkDidCloseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kJPFNetworkDidRegisterNotification:) name:kJPFNetworkDidRegisterNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kJPFNetworkDidLoginNotification:) name:kJPFNetworkDidLoginNotification object:nil];
    
    //收到jpush自定义消息（非APNS）name:kJPFNetworkDidReceiveMessageNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kJPFNetworkDidReceiveMessageNotification:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
    //绑定alias tags
    //主线程异步操作 需要耗时
    /*
     后台推送时 没有相关别名会报错
     没有满足条件的推送目标
     如果是群发：则此应用还没有一个客户端用户注册。请检查 SDK 集成是否正常。
     如果是推送给某别名或者标签：则此别名或者标签还没有在任何客户端SDK提交设置成功。
     如果是根据 Registration ID 推送：则此 Registration ID 不存在。
     */
    //只要包含了alias关键字 都可以收到通知 多其他的无所谓 少一个
    NSString *alias = [NSString stringWithFormat:@"%@", @"ethan"];
    [JPUSHService setAlias:alias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        
        NSLog(@"iResCode = %ld, iAlias = %@, seq = %ld", iResCode, iAlias, seq);
        
    } seq:1];
    
    //只要包含了tags关键字 都可以收到通知 多其他的无所谓 少一个
    //Jpush后台可以设置交集 并集 补集
    [JPUSHService setTags:[[NSSet alloc] initWithObjects:@"music", nil] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        
        NSLog(@"iResCode = %ld, seq = %ld", iResCode, seq);
        
        NSEnumerator * obj1 = [iTags objectEnumerator];
        
        NSString *tag;
        
        while (tag == [obj1 nextObject]) {
            NSLog(@"tag = %@", tag);
        }
        
        
    } seq:1];

    return YES;
}

#pragma mark - 注册APNs成功并上报DeviceToken
//注册APNs成功并上报DeviceToken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

//实现注册APNs失败接口（可选）
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support 在前台自动调用
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support 在前台或者后台点击推送内容框都会调用
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //处理收到的 APNs 消息
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    //处理收到的 APNs 消息
    [JPUSHService handleRemoteNotification:userInfo];
}

#pragma mark - JPush SDK 相关事件监听
- (void)kJPFNetworkIsConnectingNotification:(NSNotification *)noti
{
    //会走多次 连接失败后重新连接
    NSLog(@"正在连接中 noti=%@", noti.userInfo);
}

- (void)kJPFNetworkDidSetupNotification:(NSNotification *)noti
{
    NSLog(@"建立连接 noti=%@", noti.userInfo);
}

- (void)kJPFNetworkDidCloseNotification:(NSNotification *)noti
{
    NSLog(@"关闭连接 noti=%@", noti.userInfo);
}

- (void)kJPFNetworkDidRegisterNotification:(NSNotification *)noti
{
    NSLog(@"注册成功 noti=%@", noti.userInfo);
}

- (void)kJPFNetworkDidLoginNotification:(NSNotification *)noti
{
    NSLog(@"登录成功 noti=%@", noti.userInfo);
}

- (void)kJPFNetworkDidReceiveMessageNotification:(NSNotification *)noti
{
    //APNS路线
    //由JPush服务器发送至APNS服务器，再下发到手机。
    //离线消息由APNS服务器缓存按照Apple的逻辑处理。
    //应用证书和推送指定的iOS环境匹配才可以收到。
    //应用退出，后台以及打开状态都能收到APNS
    //如果应用后台或退出或应用处于打开状态，会有系统的APNS提醒。
    
    //JPush自定义消息路线
    //收到一条自定义消息走一次 会走多次
    //由JPush直接下发，每次推送都会尝试发送，如果用户在线则立即收到。否则保存为离线。
    //用户不在线JPush server 会保存离线消息,时长默认保留一天。离线消息保留5条。
    //自定义消息与APNS证书环境无关。
    //需要应用打开，与JPush 建立连接才能收到。
    //非APNS，默认不展示。可通过获取接口自行编码处理。
    NSLog(@"收到非APNS消息 noti=%@", noti.userInfo);
}

#pragma mark - applicationWillEnterForeground
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //value 取值范围：[0,99999]
    
    //由JPush后台帮助管理每个用户所对应的推送badge
    [JPUSHService setBadge:0];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
}

#pragma mark - 收到消息的弹框并不影响 不会走applicationWillResignActive
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"applicationWillResignActive");
}

@end
