//
//  SCChannel.m
//  
//
//  Created by Anatoliy Popov on 20.12.15.
//  Copyright © 2015 Anatoliy Popov. All rights reserved.
//

#import "SCChannel.h"
#import "SCSocket.h"

@implementation SCChannel{
    
    NSString* channelName;
   
    
    
}

-(nonnull instancetype) initWithChannelName:(nonnull NSString*)chName andDelegate:(nullable id /*<SCChannelDelegate>*/)chDelegate{
    
    self = [super init];
    if (self) {
        
        channelName=chName;
        self.delegate=chDelegate;
       
    }
    return self;
}


-(NSString *)getName{
    
    return channelName;
}

-(void)unsubscribeWithSuccess:(nullable void (^)(void))success{
    self.UnsubsscribeSuccessBlock=success;
     [[SCSocket client] unSubscribeFromChannel:self];
    
}

-(void)subscribeWithSuccess:(nullable void (^)(id response))success withFail:(nullable void (^)(NSError* error,id response))fail{
    

    self.SubscribeFailBlock=fail;
    self.SubsscribeSuccessBlock=success;
    
    [[SCSocket client] subscribeToChannel:self];
    
    
    
}

-(BOOL) isEqual:(SCChannel*)object{
    
    if ([channelName isEqualToString:[object getName]]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
