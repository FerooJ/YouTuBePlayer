//
//  YouTuBePlayerView.m
//  YouTuBePlayer
//
//  Created by liwei on 2017/5/13.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "YouTuBePlayerView.h"
#import "WKWebViewJavascriptBridge.h"

#define YouTubeOrigin @"http://www.baidu.com"
@interface YouTuBePlayerView ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic,strong) WKWebViewJavascriptBridge *bridge;

@property (nonatomic,strong) NSURL *originalURL;

@property (nonatomic,strong) WKWebView *webView;

@property (nonatomic,strong) NSString *videoUrl;

@end

@implementation YouTuBePlayerView
- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[NSClassFromString(@"WKWebViewConfiguration") alloc] init];
        NSString *jsStr = @"var meta=document.createElement('meta');meta.setAttribute('name','viewport');meta.setAttribute('content','width=device-width');document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsStr injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        configuration.preferences = [NSClassFromString(@"WKPreferences") new];
        configuration.userContentController = [NSClassFromString(@"WKUserContentController") new];
        [configuration.userContentController addUserScript:userScript];
        WKPreferences *prefer = [[WKPreferences alloc] init];
        prefer.javaScriptEnabled = YES;
        prefer.javaScriptCanOpenWindowsAutomatically = YES;
        configuration.preferences = prefer;
        configuration.allowsInlineMediaPlayback = YES;//控制视频播放默认不是全屏播放
        configuration.mediaTypesRequiringUserActionForPlayback = NO;
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _webView.backgroundColor = [UIColor blackColor];
        _webView.scrollView.scrollEnabled = NO;
        for (UIView *view in _webView.subviews) {
            view.backgroundColor = [UIColor blackColor];
        }
        _webView.UIDelegate= self;
        _webView.navigationDelegate = self;
        _webView.userInteractionEnabled = NO;
        [self addSubview:_webView];
        [self configBridge];
    }
    return _webView;
}

+ (instancetype)playerVideo {

    static YouTuBePlayerView *playerView;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerView = [[YouTuBePlayerView alloc] init];
    });
    return playerView;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

//布局
- (void)layoutSubviews {
    
    [super layoutSubviews];
    _webView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)configBridge {
    
    [WKWebViewJavascriptBridge accessInstanceVariablesDirectly];
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:self];
    
    __weak typeof(self) weakSelf = self;
    //准备播放
    [self.bridge registerHandler:@"onPlayerReady" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (weakSelf.videoPlayStart) {
            weakSelf.videoPlayStart();
        }
       
    }];
    //播放状态改变
    [self.bridge registerHandler:@"onPlayerStateChange" handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data[@"data"] integerValue] == 1) {//如果正在播放
            weakSelf.playerState = PlayerStatePlaying;
            if (weakSelf.playTime > 1) {
                [weakSelf seekToSecondsPlayVideo:weakSelf.playTime allowSeekAhead:YES];
                weakSelf.playTime = 0;
            }
            
        }else if([data[@"data"] integerValue] == 0) {
            weakSelf.playerState = PlayerStateEnded;
        }else if ([data[@"data"] integerValue] == -1) {
            weakSelf.playerState = PlayerStateUnStarted;
            if ([data[@"errorCode"] integerValue] != -1) {
//                NSInteger code = [data[@"errorCode"] integerValue];
            }
            
        }else if ([data[@"data"] integerValue] == 2) {
            weakSelf.playerState = PlayerStatePaused;
        }else if ([data[@"data"] integerValue] == 3) {
            weakSelf.playerState = PlayerStateBuffering;
        }else if([data[@"data"] integerValue] == 5) {
            weakSelf.playerState = PlayerStateEmbed;
        }
        
    }];
}


/**
 play video with videoId
 **/
- (BOOL)playVideoWithVideoId:(NSString *)videoId {

    NSDictionary *dic = @{@"autoplay":@1,@"controls":@2,@"playsinline":@1,@"origin":YouTubeOrigin};
    return  [self playVideoWithVideoId:videoId playerVars:dic];
}

/*
 play video with videoURL
 **/
- (BOOL)playVideoWithVideoURL:(NSString *)videoURL {
    self.videoUrl = videoURL;
    NSString *videoID = [self getVideoIdFromVideoURL];
    return [self playVideoWithVideoId:videoID];
}

/**
 play video with videoId and playerVars
 **/
- (BOOL)playVideoWithVideoId:(NSString *)videoId playerVars:(NSDictionary *)playerVars {
    if (!playerVars) {
        playerVars = @{};
    }
    NSDictionary *playerParams = @{ @"videoId" : videoId, @"playerVars" : playerVars };
    return [self playVideoWithParams:playerParams];
}

/*
 play video with playerVars
 **/
- (BOOL)playVideoWithParams:(NSDictionary *)additionalPlayerParams {
    NSDictionary *playerCallbacks = @{
                                      @"onReady" : @"onPlayerReady",
                                      @"onStateChange" : @"onPlayerStateChange",
                                      @"onError" : @"onPlayerError"
                                      };
    NSMutableDictionary *playerParams = [[NSMutableDictionary alloc] init];
    if (additionalPlayerParams) {
        [playerParams addEntriesFromDictionary:additionalPlayerParams];
    }
    if (![playerParams objectForKey:@"height"]) {
        [playerParams setValue:@"100%" forKey:@"height"];
    }
    if (![playerParams objectForKey:@"width"]) {
        [playerParams setValue:@"100%" forKey:@"width"];
    }
    
    [playerParams setValue:playerCallbacks forKey:@"events"];
    
    if ([playerParams objectForKey:@"playerVars"]) {
        NSMutableDictionary *playerVars = [[NSMutableDictionary alloc] init];
        [playerVars addEntriesFromDictionary:[playerParams objectForKey:@"playerVars"]];
        
        if (![playerVars objectForKey:@"origin"]) {
            self.originalURL = [NSURL URLWithString:YouTubeOrigin];
        } else {
            self.originalURL = [NSURL URLWithString: [playerVars objectForKey:@"origin"]];
        }
    } else {
        // This must not be empty so we can render a '{}' in the output JSON
        [playerParams setValue:[[NSDictionary alloc] init] forKey:@"playerVars"];
    }
    NSString *html = [[NSBundle mainBundle] pathForResource:@"youtube" ofType:@"html"];
    NSString *htmlStr = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:nil];
    NSError *jsonRenderingError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:playerParams
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonRenderingError];
    NSString *playerVarsJsonString =
    [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *embedHTML = [NSString stringWithFormat:htmlStr, playerVarsJsonString];
        self.webView.userInteractionEnabled = YES;
        [self.webView loadHTMLString:embedHTML baseURL: self.originalURL];
    
    return YES;

}

/*
 get video play time
 **/
- (void)currentTime:(void (^)(float, NSError *))complentionHandler {

    [self.webView evaluateJavaScript:@"player.getCurrentTime();" completionHandler:^(id returnValue, NSError * _Nullable error) {
        float currentTime = [returnValue floatValue];
        complentionHandler(currentTime,error);
    }];
}
/**
 start play video
 **/
- (void)startVideo {

    [self openInterfacePlayer];
    [self.webView evaluateJavaScript:@"player.playVideo();" completionHandler:nil];
}
/**
 stop play video
 **/
- (void)stopVideo {

    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    [self.webView evaluateJavaScript:@"player.stopVideo();" completionHandler:nil];
    [self closeInterfacePlayer];
}



/**
 pause play video
 **/
- (void)pauseVideo {

    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    [self.webView evaluateJavaScript:@"player.pauseVideo();" completionHandler:nil];
    
}


/**
 play video from seconds
 **/
- (void)seekToSecondsPlayVideo:(float)seconds allowSeekAhead:(BOOL)allowSeekAhead {

    NSString *command = [NSString stringWithFormat:@"player.seekTo(%@,%@);",[NSNumber numberWithFloat:seconds],allowSeekAhead ? @"true":@"false"];

    [self.webView evaluateJavaScript:command completionHandler:nil];
}

/**
 remove playerView
 **/
- (void)removePlyerViewFromSuperView {
    [self.webView removeFromSuperview];
}

- (void)openInterfacePlayer {
    self.webView.userInteractionEnabled = YES;
}

- (void)closeInterfacePlayer {
    self.webView.userInteractionEnabled = NO;
}

#pragma mark - WKNavigationDelegate and WKUIDelegate
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,nil);
}

//播放器销毁
- (void)dealloc {
  
    _webView.navigationDelegate = nil;
    _webView.UIDelegate = nil;
    [_webView removeFromSuperview];
    _webView = nil;
}


- (NSString *)getVideoIdFromVideoURL {
    NSString *videoId;
    NSString *searchedString = self.videoUrl;
    NSRange searchRange = NSMakeRange(0, [searchedString length]);
    NSString *pattern = @"(youtu(?:\\.be|be\\.com)\\/(?:.*v(?:\\/|=)|(?:.*\\/)?)([\\w'-]+))";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:searchedString options:0 range:searchRange];
    videoId = [searchedString substringWithRange:[match rangeAtIndex:2]];
    return  videoId;
}

@end
