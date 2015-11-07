//
//  FYUDPNewWork.m
//  FYIntelligence
//
//  Created by changxicao on 15/10/21.
//  Copyright © 2015年 changxicao. All rights reserved.
//

#import "FYUDPNetWork.h"
#import "GCDAsyncUdpSocket.h"

@interface FYUDPNetWork ()<GCDAsyncUdpSocketDelegate>

@property (strong, nonatomic) GCDAsyncUdpSocket *sendUdpSocket;
@property (copy, nonatomic) FYUDPNetWorkFinishBlock finishBlock;
@property (copy, nonatomic) FYUDPNetWorkFinishBlock mainBlock;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *mainTimer;
@property (strong, nonatomic) NSData *sendMessage;
@property (assign, nonatomic) NSInteger sendTimes;
@property (assign, nonatomic) BOOL isSending;

@end

@implementation FYUDPNetWork

+ (instancetype) shareNetEngine
{
    static FYUDPNetWork *sharedEngine = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedEngine = [[self alloc] init];
    });
    return sharedEngine;

}

- (void)createClientUdpSocket
{
    dispatch_queue_t dQueue = dispatch_queue_create("client udp socket", NULL);
    self.sendUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
    uint16_t port = kUDPHostPort;
    NSError *error = nil;
    if (![self.sendUdpSocket bindToPort:port error:&error]){
        NSLog(@"Error starting server (bind): %@", error);
        return;
    }
    if (![self.sendUdpSocket beginReceiving:&error]){
        [self.sendUdpSocket close];
        NSLog(@"Error starting server (recv): %@", error);
        return;
    }
}

- (NSTimer *)timer
{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(fireSendMessage) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (NSTimer *)mainTimer
{
    if(!_mainTimer){
        _mainTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(mainSendMessage) userInfo:nil repeats:YES];
    }
    return _mainTimer;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    [self.timer setFireDate:[NSDate distantFuture]];
    self.sendTimes = 0;
    self.sendMessage = nil;
    self.isSending = NO;
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"udp string:%@",string);

    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern: @"\\w+" options:0 error:nil];
    NSMutableArray *results = [NSMutableArray array];
    [regularExpression enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        [results addObject:result];
    }];
    NSComparator cmptr = ^(NSTextCheckingResult *obj1, NSTextCheckingResult *obj2){
        if (obj1.range.location > obj2.range.location) {
            return (NSComparisonResult)NSOrderedDescending;
        } else if (obj1.range.location < obj2.range.location) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    NSArray *MResult = [results sortedArrayUsingComparator:cmptr];
    NSTextCheckingResult *result = [MResult firstObject];
    NSString *globleString = [string substringWithRange:result.range];
    NSLog(@"globleString = %@",globleString);

    NSInteger globleNumber = [[globleString substringFromIndex:6] integerValue];
    NSLog(@"globleNumber = %ld",(long)globleNumber);

    NSString *responeString = @"";
    for (NSInteger index = 1; index <= MResult.count - 1; index++) {
        result = [MResult objectAtIndex:index];
        responeString = [responeString stringByAppendingFormat:@"%@&",[string substringWithRange:result.range]];
    }
    NSLog(@"success = %@",responeString);
    __weak typeof(self) weakSelf = self;

    if(globleNumber == kAppDelegate.globleNumber){
        kAppDelegate.globleNumber++;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.finishBlock(YES, responeString);
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.finishBlock(NO, @"");
        });
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    
}

- (void)sendRequest:(NSString *)request complete:(void (^)(BOOL, NSString *))block
{
    if(self.isSending){
        return;
    }
    self.isSending = YES;
    NSData *data = [request dataUsingEncoding:NSUTF8StringEncoding];
    [self.timer setFireDate:[NSDate date]];
    self.sendMessage = data;
    self.finishBlock = block;
}

- (void)fireSendMessage
{
    if(!self.sendMessage || self.sendTimes >= 20){
        [self.timer setFireDate:[NSDate distantFuture]];
        self.sendTimes = 0;
        self.isSending = NO;
        self.finishBlock(NO,@"");
        return;
    }
    self.sendTimes++;
    NSLog(@"send times %ld",(long)self.sendTimes);
    // 发送消息 这里不需要知道对象的ip地址和端口
    NSString *host = kHostAddress;
    uint16_t port = kUDPHostPort;
    [self.sendUdpSocket sendData:self.sendMessage toHost:host port:port withTimeout:0 tag:100];
}

- (void)mainSendMessage
{

}


@end
