//
//  ViewController.m
//  TestRecord
//
//  Created by LennonChen on 16/2/23.
//  Copyright © 2016年 LennonChen. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
- (IBAction)StartRecord:(id)sender;
- (IBAction)EndRecord:(id)sender;
- (IBAction)PlayRecord:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *ContentMsg;
@property (nonatomic) NSString *fileName;
@property (nonatomic) NSURL *fileURL;
@property (nonatomic) AVAudioRecorder *recorder;
@property (nonatomic) AVAudioPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)StartRecord:(id)sender
{
    self.ContentMsg.text = @"录音中...";
    NSString *uri = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    uri = [uri stringByAppendingPathComponent:@"fuckworld.aac"];
    self.fileName = uri;
    self.fileURL = [NSURL fileURLWithPath:uri];
   
    NSLog(@"文件路径：%@", self.fileName);
    
    // 设置会话，以便可以直接进行录制和播放
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    // 录音机的参数设置
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    // 录音格式，这里是aac
    [dict setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey: AVFormatIDKey];
    // 采样率，这个值会影响音频质量，Android与iOS都是16000，在可接受范围内
    [dict setValue:[NSNumber numberWithFloat:16000] forKey: AVSampleRateKey];
    // 通道数
    [dict setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    // 线性采样率
    [dict setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    // 录音质量
    [dict setValue:[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
    
    NSError *error = nil;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.fileURL settings: dict error: &error];
    self.recorder.delegate = self;
    if (error)
    {
        NSLog(@"录音机创建失败：%@", error.localizedDescription);
        return;
    }
    
    [self.recorder record];
    
}

- (IBAction)EndRecord:(id)sender
{
    if (self.recorder)
    {
        [self.recorder stop];
        self.recorder = nil;
    }
    
    if (self.player)
    {
        [self.player stop];
        self.player = nil;
    }
}

- (IBAction)PlayRecord:(id)sender
{
    NSError *error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.fileURL error:&error];
    self.player.numberOfLoops = 0;
    [self.player prepareToPlay];
    if (error)
    {
        NSLog(@"播放机错误：%@", error.localizedDescription);
        return;
    }
    
    [self.player play];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recoder successfully:(BOOL)flag
{
    // 录音完成之后的delagte
    NSLog(@"录音完成: %@", self.fileName);
    NSFileManager *mgr = [NSFileManager defaultManager];
    if ([mgr fileExistsAtPath:self.fileName])
    {
        unsigned long long size = [[mgr attributesOfItemAtPath:self.fileName error:nil] fileSize];
        NSLog(@"文件大小：%lld", size);
    }
}
@end
