# SocketCluster-ios-client

Native iOS client for SocketCluster http://socketcluster.io/

Notice: Client support SocketCluster v.3. Also tested on SocketCluster v.4

### Setup 

Use CocoaPods

pod "SocketCluster-ios-client";

### Usage
 
**Connect**
```objective-c
[[SCSocket client] initWithHost:@«host» onPort:portNo securely:YES];   
//set delegate
[SCSocket client].delegate=self;   
//use this, if you want restore subscriptions on reconnect
[[SCSocket client] setRestoreChannels:YES];
[[SCSocket client]  connect];
```

**channels**

use ``SCChannel`` class

```objective-c
SCChannel* channel = [[SCChannel alloc] initWithChannelName:@"test" andDelegate:nil];

    [channel subscribeWithSuccess:^(id response) {
        
    } withFail:^(NSError *error, id response) {

    }];
```

``SCChannel`` methods

```objective-c
//create channel with name and delegate
-(nonnull instancetype) initWithChannelName:(nonnull NSString*)channelName andDelegate:(nullable id /*<SCChannelDelegate>*/)delegate;
```


```objective-c
//return channel name
-(nonnull NSString*)getName;

```

```objective-c
// subscribe to channel with success and fail block
-(void)subscribeWithSuccess:(nullable void (^)(id response))success withFail:(nullable void (^)(NSError* error,id response))fail;
```

```objective-c
// unsubscribe from channel with success block
-(void)unsubscribeWithSuccess:(nullable void (^)(void))success;
```

``SCChannelDelegate`` methods

```objective-c
//fires when some publish data to channel
-(void)SCChannel:(nonnull id/*<SCChannel>*/) channel receiveData:(nullable id)data;
```

```objective-c
//fires when server send kickOut event
-(void)SCChannel:(nonnull id/*<SCChannel>*/) channel kickOutWithMessage:(nullable id)message;
```


**messages**

use ``SCMessage `` class

```objective-c
[[[SCMessage alloc] initWithEventName:@«eventName» andData:@{@"data":@"test" }] send]
```


``SCMessage `` methods

```objective-c
// init message with event name and data
-(nonnull instancetype) initWithEventName:(nonnull NSString*)eventName andData:(nullable id)data
```

```objective-c
//send message without success and fail block
//return message cid
-(NSInteger)send;
```

```objective-c
//send message with success and fail block
//return message cid
-(NSInteger)sendWithSuccess:(nullable void (^)(SCMessage* message,id response))success withFail:(nullable void (^)(SCMessage* message,id response))fail;
```

```objective-c
//send message without success and fail block to channel
//return message cid
-(NSInteger)sendToChannel:(SCChannel*)channel;
```

```objective-c
//send message with success and fail block to channel
//return message cid
-(NSInteger)sendToChannel:(SCChannel*)channel withSuccess:(nullable void (^)(SCMessage* message,id response))success withFail:(nullable void (^)(SCMessage* message,id response))fail;
```

**additional methods of ``SCSocket`` class**

```objective-c
// emit ‘login’ event with data and success/fail blocks
-(void)loginWithData:(nullable NSDictionary*)data withSuccess:(nullable void (^)(id response))success withFail:(nullable void (^)(id response))fail;
```

```objective-c
//subscribe to channel without success/fail blocks
-(void)subscribeToChannel:(SCChannel*)channel
```

```objective-c
//send SCMessage to SCChannel
-(NSInteger)sendMessage:(SCMessage*)message toChannel:(nullable SCChannel*)channel;
```

```objective-c
//emit event 
//this method don’t add message to queue, so if connection lost it will not resend 
-(NSInteger) emitEvent:(NSString*)event withData:(id)data
```

``SocketClusterDelegate`` methods

```objective-c
//call after  client connect to server and #handshake event
-(void)socketClusterConnectEvent;
```

```objective-c
//call after #setAuthToken event
-(void)socketClusterAuthenticateEvent:(NSString*)token
```

```objective-c
//call every time, when client receive event from server
-(void)socketClusterReceivedEvent:(NSString *)eventName WithData:(NSDictionary *)data isStandartEvent:(BOOL)isStandartEvent;
```
