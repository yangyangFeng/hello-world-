//
//  TYDownLoader.m
//  TYDownLoader
//
//  Created by 邴天宇 on 15/3/24.
//  Copyright (c) 2015年 邴天宇. All rights reserved.
//

#import "TYDownLoader.h"

@interface TYDownLoader ()<NSURLConnectionDataDelegate, NSURLConnectionDelegate>

//文件数据
@property(nonatomic,retain)NSMutableData *fileData;
//文件句柄
@property(nonatomic,retain)NSFileHandle *writeHandle;


//当前获取到的数据长度
@property(nonatomic,assign)long long currentLength;
//完整数据长度
@property(nonatomic,assign)long long sumLength;


//是否正在下载
@property (nonatomic,assign,getter=isdownLoading) BOOL downLoading;

//请求对象
@property (nonatomic,retain) NSURLConnection * connt;

@property (nonatomic, assign)BOOL finish;


@property (nonatomic, strong) NSOperationQueue * queue;
@end

@implementation TYDownLoader
 - (id)init
{
    self = [super init];
    if (self) {
        //  1. 创建文件 存数路径
        NSString * caches = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
        NSString * Path = [NSString stringWithFormat:@"%@/DownLoade/Temp",caches];
        
          NSString * Path2 = [NSString stringWithFormat:@"%@/DownLoade/Caches",caches];
        NSFileManager * mgr = [NSFileManager defaultManager];
        if (![mgr isExecutableFileAtPath:Path]) {
            [mgr createDirectoryAtPath:Path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![mgr isExecutableFileAtPath:Path2]) {
            [mgr createDirectoryAtPath:Path2 withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

+ (TYDownLoader * )setDownLoaderMessageUrl:(NSString *)url name:(NSString *)name Queue:(NSOperationQueue *)mainQueue;
{
    TYDownLoader * loader = [[TYDownLoader alloc]init];
    loader.url = url;
    loader.fileName = name;
    loader.queue = mainQueue;
    [loader start];
    return loader;
}
+ (NSString *)getDownLoaderMessage:(NSString *)name
{
    //  1. 创建文件 存数路径
    NSString * caches = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString * Path = [NSString stringWithFormat:@"%@/DownLoade/Caches",caches];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@",Path,name];
    

    return filePath;
}
#pragma mark -开始下载
 - (void)start
{
    _Downloading = YES;
    
//    创建一个下载请求
    NSURL * URL = [NSURL URLWithString:self.url];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:URL];
    
    
//    设置请求头 信息
    NSString * requestHeader = [NSString stringWithFormat:@"bytes=%lld-",self.currentLength];
    [request setValue:requestHeader forHTTPHeaderField:@"Range"];
    
//    发送网络请求
    self.connt = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [_connt setDelegateQueue:self.queue];
//    UIApplication * app = [UIApplication sharedApplication];
//    app.networkActivityIndicatorVisible = YES;
     self.finish = NO;
    while (!_finish) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    [self.connt start];
}
- (void)setDownFinish:(BOOL)finish
{

}
#pragma mark - 暂停下载
 - (void)pause
{
    _Downloading = NO;

    //    取消   发送 请求
    [self.connt cancel];
//    取消 请求 对象
    self.connt = nil;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
#warning 判断是否是第一次连接, 如果是则 不再进行 下列创建
    if (self.sumLength) return;
    
    
    //  1. 创建文件 存数路径
    NSString * caches = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString * Path = [NSString stringWithFormat:@"%@/DownLoade/Temp",caches];
    NSLog(@"DownLoader = %@",Path);
    
    NSFileManager * mgr = [NSFileManager defaultManager];
    if (![mgr isExecutableFileAtPath:Path]) {
//        [mgr createFileAtPath:Path contents:nil attributes:nil]; 不好使
        [mgr createDirectoryAtPath:Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * filepath = [NSString stringWithFormat:@"%@/%@.caf",Path,self.fileName];
    self.destinationPath = filepath;
    //    2.创建一个空得文件路径
    [mgr createFileAtPath:filepath contents:nil attributes:nil];
    //    3.创建写数据的文件柄
    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:filepath];
    
    //    4.
    //4.获取完整的文件的长度
    self.sumLength=response.expectedContentLength;
    
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //    累加接收到得数据
    self.currentLength += data.length;
    //      计算当前进度(转换为double型的)
    double progress= (double)self.currentLength/self.sumLength;
    if (self.progressHandler) {
        self.progressHandler(progress);
    }
//    NSLog(@"-----%f",progress);
//    监测 下载 速度
//    self.DownloadSpeed(data.length);
    
//    NSLog(@"接收到得服务器数据! --- %ld",data.length);
    
    //    将data写入创建的空文件中,但是不能使用writeTofile(会覆盖)
    //    移动到文件的尾部
    [self.writeHandle seekToEndOfFile];
    //    从当前移动的位置,写入数据
    [self.writeHandle writeData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"下载完毕");
    //    关闭连接,不在输入 数据在文件中
        [self.writeHandle closeFile];
    
    //    在下载完毕后对进度进行清空
    self.currentLength = 0;
    self.sumLength = 0;
    
    if (self.finishHandler) {
        self.finishHandler();   // 下载完成后 通知 控制器
    }
//      如果文件下载完成 那么 移动 到caches 文件夹当中
    NSString * caches = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString * Path = [NSString stringWithFormat:@"%@/DownLoade/Caches",caches];
    
    
    NSFileManager * mgr = [NSFileManager defaultManager];
    if (![mgr isExecutableFileAtPath:Path]) {
        [mgr createFileAtPath:Path contents:nil attributes:nil];
    }
    NSString * filepath = [NSString stringWithFormat:@"%@/%@.caf",Path,self.fileName];
    NSError * error;
    [mgr moveItemAtPath:self.destinationPath toPath:filepath error:&error];
    
    if (error) {
        NSLog(@"write to file Error = %@",error);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//    向服务器 发送 错误 信息
    if (self.errorHandler) {
        self.errorHandler(error);
    }
}



@end
