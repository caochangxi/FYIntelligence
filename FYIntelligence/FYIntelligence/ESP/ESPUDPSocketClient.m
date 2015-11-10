//
//  ESPUDPSocketClient.m
//  EspTouchDemo
//
//  Created by 白 桦 on 4/13/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#import "ESPUDPSocketClient.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "ESPTouchTask.h"

@interface ESPUDPSocketClient ()

@property(nonatomic, assign) int _sck_fd;
@property(nonatomic, assign) BOOL _isStop;
// it is used to check whether the socket is closed already to prevent close more than once.
// especially, when you close the socket second time, it is created just now, it will crash.
//
//      // suppose fd1 = 4, fd1 belong to obj1
// e.g. int fd1 = socket(AF_INET,SOCK_DRAM,0);
//      close(fd1);
//
//      // suppose fd2 = 4 as well, fd2 belong to obj2
//      int fd2 = socket(AF_INET,SOCK_DRAM,0);
//
//      // obj1's dealloc() is called by system, so
//      close(fd1);
//
//      // Amazing!!! at the moment, fd2 is close by others
//
@property(nonatomic,assign) volatile BOOL _isClosed;
// it is used to lock the close method
@property(nonatomic,strong) volatile NSLock *_lock;

@end

@implementation ESPUDPSocketClient

- (id)init
{
    self = [super init];
    if (self)
    {
        self._isStop = NO;
        self._sck_fd = socket(AF_INET,SOCK_DGRAM,0);
        if (DEBUG_ON)
        {
            NSLog(@"##########################client init() _sck_fd=%d",self._sck_fd);
        }
        if (self._sck_fd < 0)
        {
            if (DEBUG_ON)
            {
                perror("client: init() _skd_fd init fail\n");
            }
            return nil;
        }
    }
    return self;
}

// make sure the socket will be closed sometime
- (void)dealloc
{
    if (DEBUG_ON)
    {
        NSLog(@"###################client dealloc()");
    }
    [self close];
}

- (void) close
{
    [self._lock lock];
    if (!self._isClosed)
    {
        if (DEBUG_ON)
        {
            NSLog(@"###################client close() fd=%d",self._sck_fd);
        }
        close(self._sck_fd);
        self._isClosed = YES;
    }
    [self._lock unlock];
}

- (void) interrupt
{
    self._isStop = YES;
}

- (void) sendDataWithBytesArray2: (NSArray *) bytesArray2 ToTargetHostName: (NSString *)targetHostName WithPort: (int) port
                    andInterval: (long) interval
{
    // check data is valid
    if (nil == bytesArray2 || 0 == [bytesArray2 count])
    {
        if (DEBUG_ON)
        {
            perror("client: data is null or data's length equals 0, so sendData fail\n");
        }
        [self close];
        return;
    }
    // init socket parameters
    bool isBroadcast = [targetHostName isEqualToString:@"255.255.255.255"];
    socklen_t addr_len;
    struct sockaddr_in target_addr;
    memset(&target_addr, 0, sizeof(target_addr));
    target_addr.sin_family = AF_INET;
    target_addr.sin_addr.s_addr = inet_addr([targetHostName cStringUsingEncoding:NSASCIIStringEncoding]);
    target_addr.sin_port = htons(port);
    addr_len = sizeof(target_addr);
    if (isBroadcast) {
        const int opt = 1;
        // set whether the socket is broadcast or not
        if (setsockopt(self._sck_fd,SOL_SOCKET,SO_BROADCAST,(char *)&opt, sizeof(opt)) < 0)
        {
            if (DEBUG_ON)
            {
                perror("client: setsockopt SO_BROADCAST fail\n");
            }
            [self close];
            return;
        }
    }
    // send data gotten from the array
    for (int i = 0; !self._isStop && i < [bytesArray2 count]; i++) {
        // get data
        NSData* data = [bytesArray2 objectAtIndex:i];
        NSUInteger dataLen = [data length];
        if (0 == dataLen)
        {
            continue;
        }
        Byte bytes[dataLen];
        [data getBytes:bytes length:dataLen];
        // send data
        if (sendto(self._sck_fd, bytes, dataLen, 0, (struct sockaddr*)&target_addr, addr_len) < 0)
        {
            if (DEBUG_ON)
            {
                perror("client: sendto fail\n");
            }
            [self close];
            return;
        }
        // sleep interval
        usleep((useconds_t)(interval*1000));
    }
    // check whether the client is stop
    if (self._isStop) {
        [self close];
    }
}

@end
