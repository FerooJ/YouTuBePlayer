//
//  ViewController.m
//  YouTuBePlayer
//
//  Created by liwei on 2017/5/13.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import "ViewController.h"
#import "YouTuBePlayerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *videoId = @"M7lc1UVf-VE";
    
    YouTuBePlayerView *playerView = [[YouTuBePlayerView alloc] init];
    playerView.center = self.view.center;
    playerView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, 200);
    [playerView playVideoWithVideoId:videoId];
    [self.view addSubview:playerView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
