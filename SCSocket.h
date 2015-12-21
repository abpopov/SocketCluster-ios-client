//
//  SCSocket.h
// 
//
//  Created by Anatoliy Popov on 03.12.15.
//  Copyright © 2015 Anatoliy Popov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _SOCKET_STATE {
    
    SOCKET_STATE_CONNECTING =0 ,
    SOCKET_STATE_OPEN,
    SOCKET_STATE_CLOSED
    
} SOCKET_STATE;

@class SCChannel;
@class SCMessage;

@protocol SocketClusterDelegate<NSObject>

@optional

-(void)socketClusterAuthenticateEvent:(NSString*)token;
-(void)socketClusterConnectEvent;
-(void)socketClusterErrorEvent:(id)data;

-(void)socketClusterReceivedEvent:(NSString *)eventName WithData:(NSDictionary *)data isStandartEvent:(BOOL)isStandartEvent;


@end


@interface SCSocket : NSObject

@property (assign, nonatomic) id <SocketClusterDelegate>delegate;
@property (nonatomic, readonly) NSString* socketId;



+(instancetype)client;

- (void)initWithHost:(NSString *)host onPort:(NSInteger)port securly:(BOOL)isSecureConnection;

- (SOCKET_STATE)getState;
- (void)connect;
- (void)disconnect;


-(void)loginWithData:(nullable NSDictionary*)data withSuccess:(nullable void (^)(id response))success withFail:(nullable void (^)(id response))fail;

-(void)subscribeToChannel:(SCChannel*)channel;

-(NSInteger)sendMessage:(SCMessage*)message toChannel:(nullable SCChannel*)channel;

-(void)setRestoreChannels:(BOOL)restore;

@end
