//
//  YouTuBePlayerView.h
//  YouTuBePlayer
//
//  Created by liwei on 2017/5/13.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef NS_ENUM(NSInteger,PlayerState) {

    PlayerStateUnStarted,/**  play video unstart,maybe videosource has error      */
    PlayerStateEnded,/**  play video end  **/
    
    PlayerStatePlaying,/**   video is playing **/
    
    PlayerStatePaused,/**   pause playing video **/
    
    PlayerStateBuffering,/**    video is buffering  **/
    
    PlayerStateEmbed/**    video embed   **/
};


@interface YouTuBePlayerView : UIView

// video play id
@property (nonatomic,copy) NSString *videoId;

//video play status
@property (nonatomic,assign) PlayerState playerState;

//video has played time
@property (nonatomic,assign) float playTime;

/*
 video play start block
 
 **/
@property (nonatomic,copy) void (^videoPlayStart)();

/**
 create player object
 **/
+ (instancetype)playerVideo;

/*
 play video with videoId
 **/
- (void)startVideo;

/*
 pause video click pauseBtn
 **/
- (void)pauseVideo;

/*
 get video play time
 **/
- (void)currentTime:(void(^)(float curretTime,NSError *error))complentionHandler;

/*
 stop play
 **/
- (void)stopVideo;

/*
 play video with seconds
 
 allowSeekAhead:是否允许从头开始跳
 
 跳转到指定时间播放视频
 **/
- (void)seekToSecondsPlayVideo:(float)seconds allowSeekAhead:(BOOL)allowSeekAhead;

/*
 play video with videoId
 **/
- (BOOL)playVideoWithVideoId:(NSString *)videoId;


/*
 play video with videoURL
 **/
- (BOOL)playVideoWithVideoURL:(NSString *)videoURL;

/*
 play video with videoId and playerVars
 **/
- (BOOL)playVideoWithVideoId:(NSString *)videoId playerVars:(NSDictionary *)playerVars;

/*
 remove player view
 **/
- (void)removePlyerViewFromSuperView;

/*
 userInterface open
 **/
- (void)openInterfacePlayer;

/*
 userInterface close
 **/
- (void)closeInterfacePlayer;

@end
