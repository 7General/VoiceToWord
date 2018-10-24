//
//  GZIMVoiceToWord.h
//  VoiceToWord
//
//  Created by zzg on 2018/10/24.
//  Copyright © 2018年 zzg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GZIMVoiceToWordHelper;

@protocol GZIMVoiceToWordDelegate <NSObject>
@required
- (void)GZIMonCompleted:(GZIMVoiceToWordHelper *)voiceHelper withResoultDesc:(NSString *)errorDesc;
- (void)GZIMonCompleted:(GZIMVoiceToWordHelper *)voiceHelper forTranslationWord:(NSString *)voiceWord;

@end

/* 音频流转换文字 */
@interface GZIMVoiceToWordHelper : NSObject

+ (instancetype)defaultMannager;

@property (nonatomic, weak) id<GZIMVoiceToWordDelegate>  delegate;

- (void)gzimVoiceToWordWithPath:(NSString *)path;

@end
