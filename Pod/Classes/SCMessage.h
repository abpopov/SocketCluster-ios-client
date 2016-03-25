//
//  SCMessage.h
//  
//
//  Created by Anatoliy Popov on 20.12.15.
//  Copyright © 2015 Anatoliy Popov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCChannel;

typedef void(^SCMessageSentHandler)(_Nonnull id/*<SCMessage>*/ message,_Nullable id response);

typedef void(^SCMessageSendFailHandler)(_Nonnull id/*<SCMessage>*/ message, _Nullable id response);


@interface SCMessage : NSObject

-(nonnull instancetype) initWithEventName:(nullable NSString*)eventName andData:(nullable id)data;

@property NSInteger cid;

@property (nonatomic, strong)  SCChannel* _Nullable channel;
@property (nonatomic, strong) NSString* _Nullable event;
@property (nonatomic, strong) _Nullable id data;

@property (nonatomic, copy) _Nullable SCMessageSentHandler sentBlock;
@property (nonatomic, copy) _Nullable SCMessageSendFailHandler sendFailBlock;


-(NSInteger)send;

-(NSInteger)sendWithSuccess:(nullable void (^)(SCMessage* _Nonnull message,_Nullable id response))success withFail:(nullable void (^)( SCMessage* _Nonnull message,_Nullable id response))fail;


-(NSInteger)sendToChannel:( SCChannel* _Nonnull)channel;
-(NSInteger)sendToChannel:(SCChannel* _Nullable)channel withSuccess:(nullable void (^)(SCMessage* _Nonnull message,_Nullable id response))success withFail:(nullable void (^)(SCMessage* _Nonnull message,_Nullable id response))fail;



-(BOOL) isEqual:(nonnull SCMessage*)object;


@end
