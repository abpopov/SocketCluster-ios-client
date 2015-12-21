//
//  SCMessage.h
//  
//
//  Created by Anatoliy Popov on 20.12.15.
//  Copyright © 2015 Anatoliy Popov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCChannel;

typedef void(^SCMessageSentHandler)(id/*<SCMessage>*/ message, id response);

typedef void(^SCMessageSendFailHandler)(id/*<SCMessage>*/ message, id response);


@interface SCMessage : NSObject

-(nonnull instancetype) initWithEventName:(nonnull NSString*)eventName andData:(nullable id)data;

@property NSInteger cid;

@property (nonatomic, strong) SCChannel* channel;
@property (nonatomic, strong) NSString* event;
@property (nonatomic, strong) id data;

@property (nonatomic, copy) SCMessageSentHandler sentBlock;
@property (nonatomic, copy) SCMessageSendFailHandler sendFailBlock;


-(NSInteger)send;
-(NSInteger)resend;

-(NSInteger)sendWithSuccess:(nullable void (^)(SCMessage* message,id response))success withFail:(nullable void (^)(SCMessage* message,id response))fail;


-(NSInteger)sendToChannel:(SCChannel*)channel;
-(NSInteger)sendToChannel:(SCChannel*)channel withSuccess:(nullable void (^)(SCMessage* message,id response))success withFail:(nullable void (^)(SCMessage* message,id response))fail;



-(BOOL) isEqual:(nonnull SCMessage*)object;


@end
