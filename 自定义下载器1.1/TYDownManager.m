//
//  TYDownManager.m
//  史上时尚时尚最时尚的闹钟
//
//  Created by 邴天宇 on 15/4/15.
//  Copyright (c) 2015年 邴天宇. All rights reserved.
//

#import "TYDownManager.h"
#import "TYDownLoader.h"
static TYDownManager * loaderManager = nil;
@interface TYDownManager()

@property (nonatomic, retain) NSOperationQueue *connectionQueue;

@end

@implementation TYDownManager

+ (TYDownManager *)managerDownLoader
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!loaderManager) {
            loaderManager = [[TYDownManager alloc] init];
            loaderManager.connectionQueue = [[NSOperationQueue alloc] init];
            [loaderManager.connectionQueue setMaxConcurrentOperationCount:8];
        }
    });
    
    return loaderManager;
}

- (void)beginDownLoaderWithUrl:(NSString *) url
                                        fileName:(NSString *)name
                                        complete:(void(^)(BOOL finish))block
{
   
        NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{

       TYDownLoader* tyloader =  [TYDownLoader setDownLoaderMessageUrl:url name:name Queue:self.connectionQueue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                tyloader.finishHandler = ^{
                    block(YES);
                };
                tyloader.progressHandler = ^(double progress){
                    
                    self.progressHandler(progress);
                };
            });
         
        }];
    [self.connectionQueue addOperation:operation];
//    NSLog(@"cutton %@, main %@",[NSOperationQueue currentQueue], [NSOperationQueue mainQueue]);
    
}



@end
