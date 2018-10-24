//
//  MainViewController.m
//  VoiceToWord
//
//  Created by zzg on 2018/8/23.
//  Copyright © 2018年 zzg. All rights reserved.
//

#import "MainViewController.h"
#import "IFlyMSC/IFlyMSC.h"
#import "IFlyMSC/IFlySpeechConstant.h"
//#import "VoiceConverter.h"
#import "IATConfig.h"
#import "ISRDataHelper.h"

#import "GZIMVoiceToWordHelper.h"




// 转换文件名称
#define toWorld @"rec.wav"
// 录音文件名称
#define recodWorld @"rec.wav"

@interface MainViewController ()</*IFlySpeechRecognizerDelegate,*/AVAudioRecorderDelegate,GZIMVoiceToWordDelegate>

/* 创建语音识别对象 */
//@property (nonatomic, strong)  IFlySpeechRecognizer* iflySpeechRecognizer;




@property (nonatomic, strong) NSString * result;
@property (nonatomic, strong) UILabel * textLabel;
@property (nonatomic, strong) NSMutableString * showText;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSString *recFilePath;

@property (nonatomic, strong) UITextField * filename;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // pch   wav 格式支持
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"语音转换文字";
    
    
    UIButton * startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [startButton setTitle:@"开始录音" forState:UIControlStateNormal];
    startButton.frame = CGRectMake(50, 100, 100, 50);
    startButton.backgroundColor = [UIColor grayColor];
    [startButton addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
    
    UIButton * stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopButton setTitle:@"结束录音" forState:UIControlStateNormal];
    stopButton.frame = CGRectMake(210, 100, 100, 50);
    stopButton.backgroundColor = [UIColor grayColor];
    [stopButton addTarget:self action:@selector(stopRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopButton];
    

    UIButton * cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleButton.frame = CGRectMake(100, 170, 150, 50);
    [cancleButton setTitle:@"开始转换" forState:UIControlStateNormal];
    cancleButton.backgroundColor = [UIColor greenColor];
    [cancleButton addTarget:self action:@selector(startRec) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancleButton];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.backgroundColor = [UIColor greenColor];
    self.textLabel.numberOfLines = 0;
    self.textLabel.frame = CGRectMake(100, 260, 200, 200);
    [self.view addSubview:self.textLabel];
    
    self.filename = [[UITextField alloc] initWithFrame:CGRectMake(100, 500, 100, 30)];
    self.filename.backgroundColor = [UIColor grayColor];
    self.filename.text = @"123";
    [self.view addSubview:self.filename];
    
}

- (void)convertwav {
    
}

// 开始识别
- (void)startRec {
//    IATConfig *instance = [IATConfig sharedInstance];
//    // pcm和wav格式的音频
//    self.iflySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
//    [self.iflySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];
//    [self.iflySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
//    self.iflySpeechRecognizer.delegate = self;
//
//    self.showText = [NSMutableString new];
//    //启动识别服务
//    [self.iflySpeechRecognizer startListening];
//    //写入音频数据
//    NSString * path = [[NSBundle mainBundle] pathForResource:toWorld ofType:nil];
//    NSData *data = [NSData dataWithContentsOfFile:path];
//    [self.iflySpeechRecognizer writeAudio:data];
//    [self.iflySpeechRecognizer stopListening];
    NSString * fileName = [NSString stringWithFormat:@"%@.wav",self.filename.text];
    NSString * path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    [[GZIMVoiceToWordHelper defaultMannager] gzimVoiceToWordWithPath:path];
    [[GZIMVoiceToWordHelper defaultMannager] setDelegate:self];
}

- (void)GZIMonCompleted:(GZIMVoiceToWordHelper *)voiceHelper withResoultDesc:(NSString *)errorDesc {
    NSLog(@"---描述：%@",errorDesc);
}

-(void)GZIMonCompleted:(GZIMVoiceToWordHelper *)voiceHelper forTranslationWord:(NSString *)voiceWord {
    self.textLabel.text = voiceWord;
}



#pragma mark - ify
//-(void)onCompleted:(IFlySpeechError *)errorCode {
//    NSLog(@"转换结果描述:%@",errorCode.errorDesc);
//}
//- (void)onResults:(NSArray *)results isLast:(BOOL)isLast {
//    NSMutableString *resultString = [[NSMutableString alloc] init];
//    NSDictionary *dic = results[0];
//    for (NSString *key in dic){
//        [resultString appendFormat:@"%@",key];
//    }
//
//    if([IATConfig sharedInstance].isTranslate) {
//        NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:
//                                    [resultString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
//        if(resultDic != nil){
//            NSDictionary *trans_result = [resultDic objectForKey:@"trans_result"];
//            if([[IATConfig sharedInstance].language isEqualToString:@"en_us"]){
//                NSString *dst = [trans_result objectForKey:@"dst"];
//                NSString * usString = [NSString stringWithFormat:@"%@\ndst:%@",resultString,dst];
//                NSLog(@"usString=%@",usString);
//                [self.showText appendString:usString];
//            } else {
//
//            }
//            if([[IATConfig sharedInstance].language isEqualToString:@"zh_cn"]) {
//                NSString *src = [trans_result objectForKey:@"src"];
//                NSString * cnString = [NSString stringWithFormat:@"%@\nsrc:%@",resultString,src];
//                NSLog(@"cnString=%@",cnString);
//                [self.showText appendString:cnString];
//            }
//        }
//    } else {
//        NSString * valueString = [ISRDataHelper stringFromJson:resultString];
//        NSLog(@"valueString=%@",valueString);
//        [self.showText appendString:valueString];
//    }
//
//    if (isLast) {
//        self.textLabel.text = self.showText;
//    }
//}




//获取录音设置
- (NSDictionary*)GetAudioRecorderSettingDict{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];
    return recordSetting;
}

- (AVAudioRecorder *)recorder
{
    if (!_recorder) {
        _recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:self.recFilePath]
                                               settings:[self GetAudioRecorderSettingDict]
                                                  error:nil];
        
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
    }
    return _recorder;
}

- (NSString *)recFilePath
{
    if (!_recFilePath) {
        _recFilePath = [self p_cacheVoicePathWithName:recodWorld];
    }
    return _recFilePath;
}

#pragma mark - Private
- (NSString *)p_cacheVoicePathWithName:(NSString *)name
{
    NSString *directory = [self gzim_voiceCacheDirectory];
    if (directory) {
        return [directory stringByAppendingString:name];
    }
    return nil;
}

- (NSString *)gzim_voiceCacheDirectory
{
    NSString* directory = [NSString stringWithFormat:@"%@/Voice/Cache/", [self gzim_documentPath]];
    NSLog(@"--<<<:%@",directory);
    BOOL isDirectory;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDirectory];
    if (!exist || !isDirectory) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"Voice Cache Folder Create Failed: %@", directory);
            directory = nil;
        }
    }
    return directory;
}
- (NSString *)gzim_documentPath
{
    return [self pathForDirectory:NSDocumentDirectory];
    
}

- (NSString *)pathForDirectory:(NSSearchPathDirectory)directory
{
    return NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES).firstObject;
}

- (void)startRecord {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.recFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.recFilePath error:nil];
    }
    
    [self.recorder prepareToRecord];
    [self.recorder record];
    
}
- (void)stopRecord {
    [self stoprecode];
}

-(void)stoprecode {
    [self.recorder stop];
}



@end
