//
//  SocketClusterClientViewController.m
//  SocketCluster-ios-client
//
//  Created by Anatoliy on 12/22/2015.
//  Copyright (c) 2015 Anatoliy. All rights reserved.
//

#import "SocketClusterClientViewController.h"
@import SocketCluster_ios_client;

@interface SocketClusterClientViewController ()<SocketClusterDelegate,SCChannelDelegate>{
    

}

@end

@implementation SocketClusterClientViewController{
    SCChannel*channel;
    SCChannel*customChannel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[SCSocket client] initWithHost:@"socketcluster.io/socketcluster/" onPort:80 securely:NO];
    [SCSocket client].delegate=self;
    [[SCSocket client] connect];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)socketClusterConnectEvent{
    
    NSLog(@"connected");
    
    channel = [[SCChannel alloc]initWithChannelName:@"rand" andDelegate:self];
    
    [channel subscribeWithSuccess:^(id response) {
        
    
        
    } withFail:^(NSError *error, id response) {
        
    }];
}
- (IBAction)onSendTestAction:(id)sender {
    
    if (customChannel.state==CHANNEL_STATE_SUBSCRIBED) {
        
        SCMessage*testMessage = [[SCMessage alloc]initWithEventName:nil andData:self.testMessageText.text];
        
        [testMessage sendToChannel:customChannel];
    }
    
}

-(void)SCChannel:(SCChannel*)cn receiveData:(id)data{
    
    
    if ([cn isEqual:channel]) {
        self.randMessageLbl.text=[NSString stringWithFormat:@"%@",data];
    }else if ([cn isEqual:customChannel]){
       self.customChannelMessageLbl.text=[NSString stringWithFormat:@"%@",data];
    }
    
}

- (IBAction)subscribeToRandAction:(id)sender {
    
   SCChannel* randChannel = [[SCChannel alloc]initWithChannelName:@"rand" andDelegate:self];
    
    if (![[[SCSocket client] getSubscribedChannels] containsObject:randChannel]) {
        [channel subscribeWithSuccess:^(id response) {
            
            
            
        } withFail:^(NSError *error, id response) {
            
        }];
 
    }
    
}
- (IBAction)unsubscribeRandAction:(id)sender {
    
    SCChannel* randChannel = [[SCChannel alloc]initWithChannelName:@"rand" andDelegate:self];
    
    if ([[[SCSocket client] getSubscribedChannels] containsObject:randChannel]) {
        [channel unsubscribeWithSuccess:^{
            
        }];
        
    }

    
}

- (IBAction)createCustomChannel:(id)sender {

    if (customChannel) {
        [customChannel unsubscribeWithSuccess:^{
          
            
        }];
    }
    
    
    customChannel =[[SCChannel alloc]initWithChannelName:self.ChannelTittle.text andDelegate:self];
    
    
        [customChannel subscribeWithSuccess:^(id response) {
            
           
            self.customChannelLbl.text=[customChannel getName];
            [self.ChannelTittle resignFirstResponder];
            
        } withFail:^(NSError *error, id response) {
            
        }];
        
    

}

- (IBAction)subscribeCustomChannel:(id)sender {
   
    
    if (customChannel &&![[[SCSocket client] getSubscribedChannels] containsObject:customChannel]) {
        [customChannel subscribeWithSuccess:^(id response) {
            

        } withFail:^(NSError *error, id response) {
            
        }];
        
    }

    
    
}

- (IBAction)unsubscribeAction:(id)sender {
    if(customChannel && [[[SCSocket client] getSubscribedChannels] containsObject:customChannel]){
        
        [customChannel unsubscribeWithSuccess:^{
            
            
            
        }];
        
    }
    
}

@end
