//
//  GZIMVoiceToWord.m
//  VoiceToWord
//
//  Created by zzg on 2018/10/24.
//  Copyright © 2018年 zzg. All rights reserved.
//

#import "GZIMVoiceToWordHelper.h"
#import "IFlyMSC/IFlyMSC.h"
#import "IATConfig.h"
#import "ISRDataHelper.h"


#define IFLYSPEECH_AUDIO_SAMPLETATE @"8000"
#define IFLYSPEECH_AUDIO_STREAM_SOURCE_KEY @"audio_source"
#define IFLYSPEECH_AUDIO_CHINESE     @"zh_cn"
#define IFLYSPEECH_AUDIO_LOCK_NAME @"com.gzimvoicetoword.manager.lock"

@interface GZIMVoiceToWordHelper()<IFlySpeechRecognizerDelegate>
/* 语音识别对象 */
@property (nonatomic, strong) IFlySpeechRecognizer* iflySpeechRecognizer;
@property (readwrite, nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) NSMutableString * showText;

@end

@implementation GZIMVoiceToWordHelper

+ (instancetype)defaultMannager {
    static GZIMVoiceToWordHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GZIMVoiceToWordHelper alloc]init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 目前只支持pcm和wav格式的音频（20181024）
        self.iflySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        [self.iflySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:IFLYSPEECH_AUDIO_STREAM_SOURCE_KEY];
        [self.iflySpeechRecognizer setParameter:IFLYSPEECH_AUDIO_SAMPLETATE forKey:[IFlySpeechConstant SAMPLE_RATE]];
        [self.iflySpeechRecognizer setDelegate:self];
        self.lock = [[NSLock alloc] init];
        self.lock.name = IFLYSPEECH_AUDIO_LOCK_NAME;
    }
    return self;
}


- (void)gzimVoiceToWordWithPath:(NSString *)path {
    if (0 == path.length) return;
    [self.lock lock];
    self.showText = [NSMutableString new];
    //启动识别服务
    [self.iflySpeechRecognizer startListening];
    //写入音频数据
    NSData *data = [NSData dataWithContentsOfFile:path];
   BOOL isSuccess = [self.iflySpeechRecognizer writeAudio:data];
    if (isSuccess) {
        [self.iflySpeechRecognizer stopListening];
    }
    [self.lock unlock];
    
}

#pragma mark - IFlySpeechRecognizerDelegate
-(void)onCompleted:(IFlySpeechError *)errorCode {
    NSLog(@"转换结果描述:%@",errorCode.errorDesc);
    if (self.delegate && [self.delegate respondsToSelector:@selector(GZIMonCompleted:withResoultDesc:)]) {
        [self.delegate GZIMonCompleted:self withResoultDesc:errorCode.errorDesc];
    }
}


- (void)onResults:(NSArray *)results isLast:(BOOL)isLast {
    NSMutableString *resultString = [[NSMutableString alloc] init];
    
    NSDictionary *dic = results[0];
    for (NSString *key in dic){
        [resultString appendFormat:@"%@",key];
    }
    
    if([IATConfig sharedInstance].isTranslate) {
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
    } else {
        NSString * valueString = [ISRDataHelper stringFromJson:resultString];
        NSLog(@"valueString=%@",valueString);
        [self.showText appendString:valueString];
    }
    if (isLast) {
        NSLog(@"--->>>>:%@",self.showText);
        if (self.delegate && [self.delegate respondsToSelector:@selector(GZIMonCompleted:forTranslationWord:)]) {
            [self.delegate GZIMonCompleted:self forTranslationWord:self.showText];
        }
    }
}




@end

