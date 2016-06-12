//
//  SCChannel.h
//  
//
//  Created by Anatoliy Popov on 20.12.15.
//  Copyright © 2015 Anatoliy Popov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SCChannelSubscribeHandler)(_Nullable id response);
typedef void(^SCChannelUnsubscribeHandler)();

typedef void(^SCChannelSubscribeFailHandler)(NSError* _Nullable error,_Nullable id response);


typedef enum _CHANNEL_STATE {
    
    CHANNEL_STATE_UNSUBSRIBED =0 ,
    CHANNEL_STATE_PENDING,
    CHANNEL_STATE_SUBSCRIBED
    
} CHANNEL_STATE;
@protocol SCChannelDelegate<NSObject>

-(void)SCChannel:(nonnull id/*<SCChannel>*/) channel receiveData:(nullable id)data;
-(void)SCChannel:(nonnull id/*<SCChannel>*/) channel kickOutWithMessage:(nullable id)message;

@end


@interface SCChannel : NSObject

@property (weak, nonatomic) _Nullable id <SCChannelDelegate>delegate;

@property (nonatomic, copy) _Nullable SCChannelUnsubscribeHandler UnsubsscribeSuccessBlock;
@property (nonatomic, copy) _Nullable SCChannelSubscribeHandler SubsscribeSuccessBlock;
@property (nonatomic, copy)_Nullable SCChannelSubscribeFailHandler SubscribeFailBlock;
@property NSInteger cid;
@property CHANNEL_STATE state;

-(nonnull instancetype) initWithChannelName:(nonnull NSString*)channelName andDelegate:(nullable id /*<SCChannelDelegate>*/)delegate;

-(nonnull NSString*)getName;



-(void)subscribeWithSuccess:(nullable void (^)(_Nullable id response))success withFail:(nullable void (^)( NSError*  _Nullable error,_Nullable id response))fail;

-(void)unsubscribeWithSuccess:(nullable void (^)(void))success;
-(BOOL) isEqual:(nonnull SCChannel*)object;

@end
