//
//  ViewController.m
//  recordMe
//
//  Created by Tewodros Wondimu on 2/2/15.
//  Copyright (c) 2015 MobileMakers. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property AVAudioRecorder *audioRecorder;
@property AVAudioPlayer *audioPlayer;
@property AVAudioSession *audioSession;

@property NSURL *documents;
@property NSURL *filePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.audioSession = [AVAudioSession sharedInstance];

    // Check that the user has permission to record
    if([self.audioSession respondsToSelector:@selector(requestRecordPermission:)]){
        [self.audioSession requestRecordPermission:^(BOOL granted) {
            NSLog(@"Yeaaah!!!");
        }];
    }

    // Create a url for where to store the recording
    self.documents = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    self.filePath = [self.documents URLByAppendingPathComponent:@"recording.caf"];

    NSDictionary *recorderSettings = @{
                                     AVFormatIDKey:[NSNumber numberWithInt:kAudioFormatLinearPCM],
                                     AVSampleRateKey: [NSNumber numberWithFloat:44100.0],
                                     AVNumberOfChannelsKey: [NSNumber numberWithInt: 2],
                                     AVLinearPCMBitDepthKey: [NSNumber numberWithInt:16],
                                     AVLinearPCMIsBigEndianKey:[NSNumber numberWithBool:NO],
                                     AVLinearPCMIsFloatKey:[NSNumber numberWithBool:NO]
                                     };

    // Handle the error when creating a new instance of the audio recorder
    NSError *error = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.filePath settings:recorderSettings error:&error];
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    else
    {
        [self.audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
        [self.audioRecorder prepareToRecord];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onRecordButtonPressed:(UIButton *)sender
{
    // Check if the audio recorder is already recording
    if (!self.audioRecorder.recording) {
        // If not, start recording
        [self.audioRecorder record];
    }
}

- (IBAction)onStopRecordingButtonTapped:(UIButton *)sender
{
    // Check if the audio recorder is already recording
    if (self.audioRecorder.recording) {
        // If it is, stop recording
        [self.audioRecorder stop];
        [[AVAudioSession sharedInstance] setActive: NO error: nil];
    }
    if (self.audioPlayer.playing) {
        [self.audioPlayer stop];
        [[AVAudioSession sharedInstance] setActive: NO error: nil];
    }
}

- (IBAction)onPlayButtonPressed:(UIButton *)sender
{
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//    if (self.audioRecorder.recording) {
//        [self.audioRecorder stop];
//    }
    // Setup the audio player
    NSURL *filePathMusic = [self.documents URLByAppendingPathComponent:@"recording.caf"];
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePathMusic error:&error];
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer setVolume:0.5];
    self.audioPlayer.numberOfLoops = 1;
    [self.audioPlayer play];
}

#pragma mark AUDIO RECORDER

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (flag) {
        NSLog(@"Audio Recording Finished Successfully");
    }
}

@end
