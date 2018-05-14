//
//  RecordScreenTool.h
//  WFRecScreenDemo
//
//  Created by Sandwind on 2018/5/8.
//  Copyright © 2018年 WF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordScreenTool : NSObject

@property (nonatomic,assign) BOOL isRecing;
@property (nonatomic,assign) BOOL isPauseing;

+ (instancetype)shareInstance;

#pragma mark - start record screen
-(void)beginToRecVideowithbeginBtn;

#pragma mark - suspend or continue record screen
- (void)pauseVideowithPauseBtn;

#pragma mark - stop record screen
- (void)stopAndSaveVideowithbeginBtn;


@end
