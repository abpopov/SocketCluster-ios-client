## 2.1.0 (2016-04-25)

* Code cleanup
* Bug fix
* Added SCSocket -(void)setRestoreWaitForAuth:(BOOL)wait  - to set wait or not auth before restore channels and resend messages
* Changed -(void)socketClusterConnectEvent SocketClusterDelegate method to -(void)socketClusterConnectEvent:(BOOL)reconnecting; To check is it new connection or reconnection;

## 2.0.0 (2016-04-25)

* SC v4 ready
* This version NOT working with SC v3


## 1.0.2 (2016-03-26)

* bug fix :)

## 1.0.1 (2016-03-26)

* docs fix

## 1.0.0 (2016-03-26)

* reconnect time now are random. Just set min and max reconnection time
* added channel unsubscribe method
* added getSubscribedChannels to SCSocket. Use for get list of channels
* code cleanup
* Update example project

## 0.1 (2015-12-22)

* initial version