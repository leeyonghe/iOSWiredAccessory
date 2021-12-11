//
//  ViewController.m
//  MicTest
//
//  Created by ios-dev on 2021/12/01.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(WiredMPRemoteCommand:)
                                               name:@"WiredMPRemoteCommand"
                                             object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(RouteChangeNotification:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
}

- (void)SetWireMic:(NSString *) name extension:(NSString *) extension{
    MPRemoteCommandCenter *center = [MPRemoteCommandCenter sharedCommandCenter];
    [center.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSNotificationCenter.defaultCenter postNotificationName:@"WiredMPRemoteCommand"
                                                          object:nil
                                                        userInfo:nil];
        });
        return MPRemoteCommandHandlerStatusSuccess;

    }];
    [[center togglePlayPauseCommand] setEnabled:YES];
    [[center playCommand] setEnabled:YES];
    [[center pauseCommand] setEnabled:YES];
    [[center skipForwardCommand] setEnabled:NO];
    [[center skipBackwardCommand] setEnabled:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:name ofType:extension]];
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [audioPlayer play];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSString *audioCategory;
        audioCategory = AVAudioSessionCategoryPlayAndRecord;
        [audioSession setCategory:audioCategory error:nil];
        [audioSession setActive:YES error:nil];
    });
}

- (void)RouteChangeNotification:(NSNotification *)notif {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self SetWireMic:@"n_alert" extension:@"wav"];
    });
}

- (void)WiredMPRemoteCommand:(NSNotification *)notif {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@", ((MPRemoteCommandEvent*)notif.userInfo).command] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

@end
