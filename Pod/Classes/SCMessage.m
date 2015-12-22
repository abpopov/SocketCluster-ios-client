//
//  SCMessage.m
//
//
//  Created by Anatoliy Popov on 20.12.15.
//  Copyright © 2015 Anatoliy Popov. All rights reserved.
//

#import "SCMessage.h"

#import "SCSocket.h"
@implementation SCMessage

-(nonnull instancetype) initWithEventName:(nullable NSString*)eventName andData:(nullable id)data{
  
    self = [super init];
    if (self) {
        self.data=data;
        self.event=eventName;
    }
    return self;
    
    
}

-(NSInteger)sendToChannel:(SCChannel*)channel{
 
    return  [self sendToChannel:channel withSuccess:nil withFail:nil];
    
}

-(NSInteger)send{
    return  [self sendToChannel:nil withSuccess:nil withFail:nil];
}


-(NSInteger)sendWithSuccess:(nullable void (^)(SCMessage* message,id response))success withFail:(nullable void (^)(SCMessage* message,id response))fail{
  
        return  [self sendToChannel:nil withSuccess:success withFail:fail];
    
}




-(NSInteger)sendToChannel:(SCChannel*)channel withSuccess:(nullable void (^)(SCMessage* message,id response))success withFail:(nullable void (^)(SCMessage* message,id response))fail{
    
    self.sendFailBlock=fail;
    self.sentBlock=success;
    self.channel= channel;
    
    return [[SCSocket client] sendMessage:self toChannel:channel];
}


-(BOOL) isEqual:(nonnull SCMessage*)object{
    
    if (self.cid == object.cid) {
        return YES;
    }
    else
    {
        return NO;
    }
}


@end
