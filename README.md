# YouTuBePlayer
用WKWebView实现YouTuBe视频播放

YouTuBe视频播放的官方demo是采用UIWebView加载HTML实现的，我们都清楚UIWebView的性能问题不好解决，在iOS8之后苹果推出的WKWebView可以极大地节省内存，不过关于其使用，有很多坑，那么，笔者在开发到相关工程的时候就想到如何采用WKWebView去实现播放YouTuBe视频呢，经过一番研究，封装了一个实现WKWebView播放YouTuBe视频的工具类，以供有相似功能开发的人来一起研究学习，笔者后续会继续更新代码，有写的不对的地方，欢迎同胞们指出，大家一同共同进步


YouTuBe视频播放需要在翻墙条件下，笔者在这里对功能进行了一些简单封装，只需要导入YouTuBePlayerView类，调用里面提供的接口，就能够实现播放，暂停，跳转到指定位置播放的功能，另外也可以自己去设置播放的一些参数，下面列举几条常用的接口：

//开始播放
- (void)startVideo;

//暂停播放
- (void)pauseVideo;

//停止播放
- (void)stopVideo;

//以videoId开始播放
- (BOOL)playVideoWithVideoId:(NSString *)videoId;

//以videoURL播放，内部会实现自动以videoURL查询videoId
- (BOOL)playVideoWithVideoURL:(NSString *)videoURL;

//可以自己设置参数播放
- (BOOL)playVideoWithVideoId:(NSString *)videoId playerVars:(NSDictionary *)playerVars;

//跳转到指定时间播放
- (void)seekToSecondsPlayVideo:(float)seconds allowSeekAhead:(BOOL)allowSeekAhead;


//获取当前播放时间
- (void)currentTime:(void(^)(float curretTime,NSError *error))complentionHandler;


配合WebViewJavascriptBridge可以很好地去实现视频播放的功能
暂时就实现这些常用功能，如果有疑问可以联系我QQ1458538925，欢迎大家一起交流

