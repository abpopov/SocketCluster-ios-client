//
//  SocketClusterClientViewController.m
//  SocketCluster-ios-client
//
//  Created by Anatoliy on 12/22/2015.
//  Copyright (c) 2015 Anatoliy. All rights reserved.
//

#import "SocketClusterClientViewController.h"
@import SocketCluster_ios_client;

@interface SocketClusterClientViewController ()<SocketClusterDelegate,SCChannelDelegate>

@end

@implementation SocketClusterClientViewController{
    SCChannel*channel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[SCSocket client] initWithHost:@"localhost" onPort:1330 securely:NO];
    [SCSocket client].delegate=self;
    [[SCSocket client] connect];
    
  
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)socketClusterConnectEvent{
    
    NSLog(@"connected");
    channel = [[SCChannel alloc]initWithChannelName:@"test" andDelegate:self];

    
    [channel subscribeWithSuccess:^(id response) {
        [[[UIAlertView alloc ] initWithTitle:nil message:@"subscribed to test" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    } withFail:^(NSError *error, id response) {
        
    }];
}
- (IBAction)onSendTestAction:(id)sender {
    
    if (channel.state==CHANNEL_STATE_SUBSCRIBED) {
        
        SCMessage*testMessage = [[SCMessage alloc]initWithEventName:nil andData:@{@"testString":@"string"}];
        
        [testMessage sendToChannel:channel];
    }
    
}

-(void)SCChannel:(SCChannel*)channel receiveData:(id)data{
    
    [[[UIAlertView alloc] initWithTitle:@"Message recieved" message:[NSString stringWithFormat:@"%@",data] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil] show];
    
}
@end
