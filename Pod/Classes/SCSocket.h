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

-(void)socketClusterAuthenticateEvent:( NSString* _Nonnull)token;
-(void)socketClusterConnectEvent:(BOOL)reconnecting;
-(void)socketClusterReceivedEvent:(NSString * _Nonnull)eventName WithData:( NSDictionary *_Nullable)data isStandartEvent:(BOOL)isStandartEvent;


@end


@interface SCSocket : NSObject

@property (assign, nonatomic,nullable) id <SocketClusterDelegate>delegate;
@property (nonatomic, readonly,nonnull) NSString* socketId;



+(instancetype _Nullable)client;

//init
- (void)initWithHost:(NSString *_Nonnull)host onPort:(NSInteger)port securely:(BOOL)isSecureConnection;

//getting info
- (SOCKET_STATE)getState;
- (BOOL) isAuthenticated;
-(NSArray* _Nonnull)getSubscribedChannels;

//connection methods
- (void)connect;
- (void)disconnect;

// settings
-(void)setRestoreWaitForAuth:(BOOL)wait;
-(void)setRestoreChannels:(BOOL)restore;
-(void)setMinSCReconnectTime:(NSInteger)minReconnectTime;
-(void)setMaxSCReconnectTime:(NSInteger)maxReconnectTime;


//service methods
-(void)loginWithData:(nullable NSDictionary*)data withSuccess:(nullable void (^)(_Nullable id response))success withFail:(nullable void (^)(_Nullable id response))fail;
-(void)subscribeToChannel:(SCChannel* _Nonnull)channel;
-(void)unSubscribeFromChannel:(SCChannel* _Nonnull)channel;



//sending messages
-(NSInteger)sendMessage:(SCMessage* _Nonnull)message toChannel:( SCChannel* _Nullable)channel;
-(NSInteger) emitEvent:(NSString* _Nonnull)event withData:(_Nullable id)data;




@end
