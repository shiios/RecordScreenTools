//
//  RecordScreenTool.m
//  WFRecScreenDemo
//
//  Created by Sandwind on 2018/5/8.
//  Copyright © 2018年 WF. All rights reserved.
//

#import "RecordScreenTool.h"
#import "WFCapture.h"
#import "BlazeiceAudioRecordAndTransCoding.h"
#define VEDIOPATH @"vedioPath"


@interface RecordScreenTool ()<WFCaptureDelegate,AVAudioRecorderDelegate,BlazeiceAudioRecordAndTransCodingDelegate,UIAlertViewDelegate>

{
   
    WFCapture *capture;
    BlazeiceAudioRecordAndTransCoding *audioRecord;
    NSString* opPath;
    
}
@end

@implementation RecordScreenTool

+(instancetype)shareInstance
{
    static RecordScreenTool *recordScreenTool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recordScreenTool = [[RecordScreenTool alloc]init];
        recordScreenTool.isRecing=NO;
        recordScreenTool.isPauseing=NO;
    });
    return recordScreenTool;
}

#pragma mark - 开始录制视频
-(void)beginToRecVideowithbeginBtn
{
    if (self.isRecing) {
        return ;
    }
    self.isRecing =YES;
    [self recordMustSuccess];

}
#pragma mark----------------start record
- (void)recordMustSuccess {
    capture = [WFCapture sharedRecorder];
    capture.frameRate = 35;
    capture.delegate = self;
    //    capture.captureLayer = [[UIApplication sharedApplication].delegate window].layer;
    
    if (!audioRecord) {
        audioRecord = [[BlazeiceAudioRecordAndTransCoding alloc]init];
        audioRecord.recorder.delegate=self;
        audioRecord.delegate=self;
    }
    
    [capture performSelector:@selector(startRecording1)];
    
    NSString* path=[self getPathByFileName:VEDIOPATH ofType:@"wav"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]){
        [fileManager removeItemAtPath:path error:nil];
    }
    [self performSelector:@selector(toStartAudioRecord) withObject:nil afterDelay:0.1];
    
}

- (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString* fileDirectory = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:_fileName]stringByAppendingPathExtension:_type];
    return fileDirectory;
}


#pragma mark -
#pragma mark audioRecordDelegate
/**
 *  开始录音
 */
-(void)toStartAudioRecord
{
    [audioRecord beginRecordByFileName:VEDIOPATH];
}
/**
 *  音频录制结束合成视频音频
 */
-(void)wavComplete
{
    //视频录制结束,为视频加上音乐
    if (audioRecord) {
        NSString* path=[self getPathByFileName:VEDIOPATH ofType:@"wav"];
        [WFCaptureUtilities mergeVideo:opPath andAudio:path andTarget:self andAction:@selector(mergedidFinish:WithError:)];
    }
}
#pragma mark - 继续或者暂停录制
- (void)pauseVideowithPauseBtn
{
    if (self.isRecing) {
        //暂停
        self.isRecing=NO;
        self.isPauseing=YES;
        [[WFCapture sharedRecorder] pauseRecording];
        [audioRecord pauseRecord];
        
    }else if(self.isPauseing)
    {
        self.isRecing=YES;
        self.isPauseing=NO;
        [[WFCapture sharedRecorder] resumeRecording];
        [audioRecord resumeRecord];
        
    }
    
}
#pragma mark - 结束录制视频
- (void)stopAndSaveVideowithbeginBtn
{
  
    self.isRecing =NO;
    self.isPauseing=NO;
    [[WFCapture sharedRecorder]stopRecording];
    
}
#pragma mark --------------音频方法
#pragma mark CustomMethod

- (void)video: (NSString *)videoPath didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInfo{
    if (error) {
        NSLog(@"---%@",[error localizedDescription]);
    }
}

- (void)mergedidFinish:(NSString *)videoPath WithError:(NSError *)error
{
    //    NSLog(@"~~~~~~~~~~~~~~~~~~~~~");
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    long long int date = (long long int)time;
    NSString* fileName=[NSString stringWithFormat:@"%lld.mp4",date];
    //
    NSString* path=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/myVideo/%@",fileName]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath])
    {
        NSError *err=nil;
        [[NSFileManager defaultManager] moveItemAtPath:videoPath toPath:path error:&err];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[WFCapture sharedRecorder].opPath])
    {
        NSError *err=nil;
        [[NSFileManager defaultManager]removeItemAtPath:[WFCapture sharedRecorder].opPath error:&err];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"allVideoInfo"]) {
        
        NSMutableArray* allFileArr=[[NSMutableArray alloc] init];
        [allFileArr addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"allVideoInfo"]];
        [allFileArr insertObject:fileName atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:allFileArr forKey:@"allVideoInfo"];
    }
    else{
        NSMutableArray* allFileArr=[[NSMutableArray alloc] init];
        [allFileArr addObject:fileName];
        [[NSUserDefaults standardUserDefaults] setObject:allFileArr forKey:@"allVideoInfo"];
    }
    
    //音频与视频合并结束，存入相册中[THCapture sharedRecorder].opPath
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
        NSLog(@"123~~~~");
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"save success" message:@"prompt friendly" delegate:self cancelButtonTitle:nil otherButtonTitles:@"sure", nil];
            alterView.delegate = self;
            [alterView show];
        });
        
        
    }else
    {
        NSLog(@"错误");
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"save fail" message:@"prompt friendly" delegate:self cancelButtonTitle:nil otherButtonTitles:@"sure", nil];
            alterView.delegate = self;
            [alterView show];
        });
    }
}



#pragma mark -
#pragma mark WFCaptureDelegate
- (void)recordingFinished:(NSString*)outputPath
{
    NSLog(@"outputPath %@",outputPath);
    opPath=outputPath;
    if (audioRecord) {
        [audioRecord endRecord];
    }
    //    [self mergedidFinish:outputPath WithError:nil];
}

- (void)recordingFaild:(NSError *)error
{
}
@end
