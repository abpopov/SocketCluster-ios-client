//
//  SCSocket.m
// 
//
//  Created by Anatoliy Popov on 03.12.15.
//  Copyright © 2015 Anatoliy Popov. All rights reserved.
//

#import "SCSocket.h"
#import <SocketRocket/SRWebSocket.h>

#import "SCChannel.h"
#import "SCMessage.h"

@interface SCSocket()<SRWebSocketDelegate>{
    
    NSString*SCHost;
    NSInteger SCPort;

    NSInteger SCReconnectTime;
    NSInteger MaxSCReconnectTime;
    
    NSString*JWTToken;
    NSInteger cid;

    NSMutableArray*channelsArray;
    NSMutableArray*messagesArray;
    
    BOOL isAuthenticated;
    BOOL secure;
    
    BOOL waitResendUntilAuth;
    BOOL restoreChannels;
    
    BOOL reconnecting;
    
    
    SRWebSocket *wS;
}

@end

@implementation SCSocket


+(instancetype)client{
    static SCSocket* client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!client) {
            
            client = [[SCSocket alloc] init];
        }
    });
    return client;
    
}



-(void) initWebSocketWithUrl:(NSString*)url{
    
    
    wS.delegate = nil;
    
    [wS close];
    
    wS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@/?transport=websocket",url]]]];
    
    wS.delegate = self;
    
    
}

-(void) initWebSocketWithSecureUrl:(NSString*)url{
    
    wS.delegate = nil;
    [wS close];
    
    wS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"wss://%@/?transport=websocket",url]]]];
    wS.delegate = self;
    
    
}

-(void)initWithHost:(NSString *)host onPort:(NSInteger)port securely:(BOOL)isSecureConnection{
    
     
        SCHost = host;
        SCPort = port;
        SCReconnectTime=5;
        MaxSCReconnectTime=10;
    
        secure = isSecureConnection;
        channelsArray=[[NSMutableArray alloc]init];
        messagesArray=[[NSMutableArray alloc]init];

    
}





#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    
    [self WSMessageHandler:message];

}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    
    [self WSConnectedHandler];
    
}


- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    
    if (SCReconnectTime>0) {
       
        NSInteger randReconnectTime = arc4random() % (MaxSCReconnectTime - SCReconnectTime) + SCReconnectTime;

        reconnecting =YES;
        
        [self performSelector:@selector(connect) withObject:nil afterDelay:randReconnectTime];
    }
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
   
    if (SCReconnectTime>0) {
        
        reconnecting =YES;
        
        NSInteger randReconnectTime = arc4random() % (MaxSCReconnectTime - SCReconnectTime) + SCReconnectTime;
        
        [self performSelector:@selector(connect) withObject:nil afterDelay:randReconnectTime];
    }
    
    
}



- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    
}




#pragma mark - SCSocket methods




-(NSInteger) emitEvent:(NSString*)event withData:(id)data{
    
    NSInteger currentCid =cid=cid+1;
    
    NSMutableDictionary*sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:event,@"event",[NSNumber numberWithInteger:currentCid],@"cid", nil];
    
    if (data) {
        [sendData setObject:data forKey:@"data"];
    }
    if (wS.readyState == SR_OPEN) {
            [wS send:[self getJSONFromDict:sendData]];
    }
    

    
    return currentCid;
    
}

-(void) sendMessage:(NSString*)message{


    [wS send:message];


}

-(NSString*)getJSONFromDict:(NSDictionary*)data{
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString=@"";
    
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
    
}

-(void)sendPong{
    
    [wS send:@"2"];
    
}

- (void)connect{
    
    
    if (secure) {
        [self initWebSocketWithSecureUrl:[NSString stringWithFormat:@"%@:%d",SCHost,(int)SCPort]];
        
    }else{
        [self initWebSocketWithUrl:[NSString stringWithFormat:@"%@:%d",SCHost,(int)SCPort]];
    }
    
    [wS open];
    
}


- (void)disconnect{
    
    [channelsArray removeAllObjects];
    [messagesArray removeAllObjects];
    
    JWTToken=nil;
    isAuthenticated=NO;
    
    SCReconnectTime=-1;
    [wS close];
    
    

}

-(void)setRestoreWaitForAuth:(BOOL)wait{
    
    waitResendUntilAuth = wait;
}

-(void)setRestoreChannels:(BOOL)restore{

    restoreChannels=restore;
}

- (SOCKET_STATE)getState
{
    switch (wS.readyState) {
        case SR_OPEN:
            return SOCKET_STATE_OPEN;
            break;
        case SR_CONNECTING:
            return SOCKET_STATE_CONNECTING;
        case SR_CLOSED:
        case SR_CLOSING:
            return SOCKET_STATE_CLOSED;
        default:
            return SOCKET_STATE_CLOSED;
            break;
    }
    
}


-(void)WSConnectedHandler{
    SCMessage* handShakeMessage;
    
    if (JWTToken && ![JWTToken isKindOfClass:[NSNull class]]) {
        
        
     handShakeMessage =[[SCMessage alloc] initWithEventName:@"#handshake" andData:@{@"authToken":JWTToken}] ;
        
        
    }
    else{
          handShakeMessage =[[SCMessage alloc] initWithEventName:@"#handshake" andData:nil] ;
    }
    
   
    [handShakeMessage sendWithSuccess:^(SCMessage *message, id response) {
        if (![response isKindOfClass:[NSNull class]]) {
            
            id isAuthenticatedObj = [response objectForKey:@"isAuthenticated"];
            NSString* idx =[response objectForKey:@"id"] ;
            if (idx && isAuthenticatedObj && ![idx isKindOfClass:[NSNull class]]&& ![isAuthenticatedObj isKindOfClass:[NSNull class]] ) {
                
                
                _socketId =idx;
                isAuthenticated = [isAuthenticatedObj boolValue];
                
                
                if(!isAuthenticated){
                    
                    JWTToken= nil;
                }
                BOOL reconnect= reconnecting;
                if (reconnecting) {
                    
               
                if (!waitResendUntilAuth) {
                    
                    reconnecting = NO;
                    [self restoreChannels];
                    [self resendStoredMessages];
                }else if(isAuthenticated){
                     reconnecting = NO;
                    [self restoreChannels];
                    [self resendStoredMessages];
                
                }
            
                }
             
                
                if ([self.delegate respondsToSelector:@selector(socketClusterConnectEvent:)]){
                    [self.delegate socketClusterConnectEvent:reconnect];
                }
                
            }
            
            
        }
        
        
    } withFail:^(SCMessage *message, NSError *error) {
        
    }];

     

}


-(void)WSMessageHandler:(NSString*)message{
    
    if ([message isKindOfClass:[NSString class]]) {
        
        if ([message isEqualToString:@"#1"]) {
            [self sendPong];
            return;
        }
        
        NSError *error;
        NSData *objectData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:objectData options:kNilOptions error:&error];
    
        
        NSLog(@"%@",message);
        if (dictionary) {
            
            
            id ridObj =  [dictionary objectForKey:@"rid"];
            
            if (ridObj && ![ridObj isKindOfClass:[NSNull class]]) {
                
                NSInteger rid = [ridObj integerValue];
              
                
                SCChannel* channel = [self findChanneByRid:rid];
                if (channel) {
                    
                    id errorData =[dictionary objectForKey:@"error"] ;
                    
                    if (errorData && ![errorData isKindOfClass:[NSNull class]]) {
                        
                        if(channel.SubscribeFailBlock){
                            channel.SubscribeFailBlock(nil,errorData);
                        }
                        
                        [channelsArray removeObject:channel];
                        
                    }
                    
                    else{
                        
                        channel.state=CHANNEL_STATE_SUBSCRIBED;
                        
                        if(channel.SubsscribeSuccessBlock){
                            id responseData =[dictionary objectForKey:@"data"] ;
     
                            channel.SubsscribeSuccessBlock(responseData);
                        }
                    }
                    
                }
                
                SCMessage* messageObj =[self findMessageByRid:rid];
                
                if (messageObj) {

                    [messagesArray removeObject:messageObj];
                    
                    id errorData =[dictionary objectForKey:@"error"] ;
                    
                    if (errorData && ![errorData isKindOfClass:[NSNull class]]) {
                        
                        if(messageObj.sendFailBlock){
                            messageObj.sendFailBlock(message,errorData);
                        }
                        
                     
                        
                    }
                    
                    else{
                        if(messageObj.sentBlock){
                            id responseData =[dictionary objectForKey:@"data"] ;
                            
                            messageObj.sentBlock(message,responseData);
                        }
                        
                         [messagesArray removeObject:messageObj];
                        
                        
                    }
                    
                }
                
                return;
            
            }
            
            
           
            if ([dictionary objectForKey:@"event"]) {
                NSString*eventName = [dictionary objectForKey:@"event"];
                NSDictionary*dataObj =[dictionary objectForKey:@"data"];
                BOOL isStandartEvent = NO;
                
               
                
                
                
                if ([eventName isEqualToString:@"#setAuthToken"]) {
                    
                    isStandartEvent = YES;
                    
                    [self setAuthTokenEvent:dataObj];
                    
                }
                
                if ([eventName isEqualToString:@"#publish"]) {
                    isStandartEvent = YES;
                    [self processPublishEvent:dataObj];
                    
                }
                
                if ([eventName isEqualToString:@"#fail"]) {
                    isStandartEvent = YES;
                    
                    
                    
                }
                
                
                if ([eventName isEqualToString:@"#kickOut"]) {
                    isStandartEvent = YES;
                    
                   
                    [self processKickOutEvent:dataObj];
                    
                    
                }
                
                
                if ([eventName isEqualToString:@"#removeAuthToken"]) {
                    isStandartEvent = YES;
                    
                    [self processRemoveAuthToken];
                    
                    
                    
                }
                
                if ([eventName isEqualToString:@"#disconnect"]) {
                    isStandartEvent = YES;
                    
                    [self disconnect];
                    
                }
          
                if (![eventName isKindOfClass:[NSNull class]]) {
                    if ([self.delegate respondsToSelector:@selector(socketClusterReceivedEvent:WithData:isStandartEvent:)]){
                        [self.delegate socketClusterReceivedEvent:eventName WithData:dataObj isStandartEvent:isStandartEvent];
                    }
                    
                }

                
                
                return;
            
            }
            

        
            
        }
        
        
    }
    
}

-(void) processRemoveAuthToken{
 
    isAuthenticated =NO;
    JWTToken=nil;
    
}

-(void) processKickOutEvent:(NSDictionary*)data{

      NSString* channelName = [data objectForKey:@"channel"];
   
    if (channelName && ![channelName isKindOfClass:[NSNull class]]) {
        SCChannel* channel = [self findChanneByName:channelName];
        
        if (channel) {
            
            [channelsArray removeObject:channel];
            
            id message =  [data objectForKey:@"message"];
            
            
            if (channel.delegate) {
                if ([channel.delegate respondsToSelector:@selector(SCChannel:kickOutWithMessage:)]){
                    [channel.delegate SCChannel:channel kickOutWithMessage:message];
                }
                
            }
            
        }
    }

    
    
}
-(void)processPublishEvent:(NSDictionary*)data{
    //"data":{"channel":"foo","data":"sdsd"}
    
    NSString* channelName = [data objectForKey:@"channel"];

    if (channelName && ![channelName isKindOfClass:[NSNull class]]) {
        SCChannel* channel = [self findChanneByName:channelName];
        
        if (channel) {
            
            id channelData =  [data objectForKey:@"data"];
            
            
            if (![channel.delegate isKindOfClass:[NSNull class]]&& channel.delegate) {
                if ([channel.delegate respondsToSelector:@selector(SCChannel:receiveData:)]){
                    [channel.delegate SCChannel:channel receiveData:channelData];
                }

            }else{
                [channelsArray removeObject:channel];
            }
            
        }
    }
  
    
    
    
}

-(void)loginWithData:(nullable NSDictionary*)data withSuccess:(nullable void (^)(id response))success withFail:(nullable void (^)(id response))fail{
    
    
    [[[SCMessage alloc] initWithEventName:@"login" andData:data] sendWithSuccess:^(SCMessage *message, id response) {
        
       
        
        
        success(response);
     
        
        
    } withFail:^(SCMessage *message, NSError *error) {
        
        
    }];
    
}


-(void)setAuthTokenEvent:(NSDictionary*)dataObj{
    
    
    if (dataObj&&![dataObj isKindOfClass:[NSNull class] ]) {
        NSString*token= [dataObj objectForKey:@"token"];
        
        if (token&& ![token isKindOfClass:[NSNull class]] &&[token length]>0) {
            
            JWTToken = token;
        
            
            if (waitResendUntilAuth && restoreChannels &&  reconnecting) {
                
                [self restoreChannels];
                [self resendStoredMessages];
            }
                 reconnecting = NO;
            
            
            if ([self.delegate respondsToSelector:@selector(socketClusterAuthenticateEvent:)]){
                [self.delegate socketClusterAuthenticateEvent:token];
            }
            
            
        }
    }
    

}

#pragma mark work with SCChannel

-(void)subscribeToChannel:(SCChannel*)channel{
    
    if ([channelsArray containsObject:channel]) {
       
    
        [channelsArray removeObject:channel];
    
    
    }
       
        [channelsArray addObject:channel];
        
        channel.cid = [[[SCMessage alloc] initWithEventName:@"#subscribe" andData:@{@"channel":[channel getName]}] send];
    
        channel.state=CHANNEL_STATE_PENDING;
        
    
    
    
    
}

-(void)unSubscribeFromChannel:(SCChannel* _Nonnull)channel{
    
    
    if ([channelsArray containsObject:channel]) {
       
        [[[SCMessage alloc] initWithEventName:@"#unsubscribe" andData:[channel getName]] sendWithSuccess:^(SCMessage * _Nonnull message, id  _Nullable response) {
            
            [channelsArray removeObject:channel];
            
            if (channel.UnsubsscribeSuccessBlock) {
                    channel.UnsubsscribeSuccessBlock();
            }
         
            
        } withFail:^(SCMessage * _Nonnull message, id  _Nullable response) {
            
        }];
        
        channel.state=CHANNEL_STATE_PENDING;
        
    }

    
    
    
}

-(SCChannel*)findChanneByRid:(NSInteger)rid{
    
    for (SCChannel *channel in channelsArray) {
        if (channel.cid == rid) {
            return channel;
        }
    }
    
    return nil;
}


-(SCChannel*)findChanneByName:(NSString*)name{
    
    for (SCChannel *channel in channelsArray) {
        if ([[channel getName] isEqualToString:name]) {
            return channel;
        }
    }
    
    return nil;
}

-(void)restoreChannels{
    if (restoreChannels) {
        
        for (SCChannel* channel in channelsArray) {
            
            if (channel.state == CHANNEL_STATE_SUBSCRIBED) {
                        
                        [self emitEvent:@"#subscribe" withData:@{@"channel":[channel getName]}];
            }
            
        }
        
    }
}


#pragma mark work with SCMessage

-(NSInteger)sendMessage:(SCMessage*)message toChannel:(nullable SCChannel*)channel{
    
    if (channel) {
    
        message.cid = [self emitEvent:@"#publish" withData:@{@"channel":[channel getName] ,@"data":message.data}];
        
        
    }
    else{
        message.cid= [self emitEvent:message.event withData:message.data];
    }
    
    
    [messagesArray addObject:message];
    
    return message.cid;
}


-(SCMessage*)findMessageByRid:(NSInteger)rid{
    
    for (SCMessage *message in messagesArray) {
        if (message.cid == rid) {
            return message;
        }
    }
    
    return nil;
}



-(void)resendStoredMessages{
    
    for(SCMessage* message in messagesArray){
        
        if (![message.event isEqualToString:@"#handshake"]) {
            
            if (message.channel) {
                
              [self emitEvent:@"#publish" withData:@{@"channel":[message.channel getName] ,@"data":message.data}];
                
                
            }
            else{
              [self emitEvent:message.event withData:message.data];
            }
            
        }
    }
    
}


-(void)setMinSCReconnectTime:(NSInteger)reconnectTime{
    SCReconnectTime=reconnectTime;
}

-(void)setMaxSCReconnectTime:(NSInteger)reconnectTime{
    MaxSCReconnectTime=reconnectTime;
}

-(NSArray*)getSubscribedChannels{
    
    return channelsArray;
}
- (BOOL) isAuthenticated{
    
    return isAuthenticated;
    
}

@end
