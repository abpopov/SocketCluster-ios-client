//
//  SocketClusterClientViewController.h
//  SocketCluster-ios-client
//
//  Created by Anatoliy on 12/22/2015.
//  Copyright (c) 2015 Anatoliy. All rights reserved.
//

@import UIKit;


@interface SocketClusterClientViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *randMessageLbl;

@property (weak, nonatomic) IBOutlet UITextField *ChannelTittle;
@property (weak, nonatomic) IBOutlet UITextField *testMessageText;

@property (weak, nonatomic) IBOutlet UILabel *customChannelMessageLbl;
@property (weak, nonatomic) IBOutlet UILabel *customChannelLbl;
@end
