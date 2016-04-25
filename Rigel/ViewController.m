//
//  ViewController.m
//  Rigel
//
//  Created by Cesar Barscevicius on 4/24/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "ViewController.h"

#import "MultipeerController.h"

@interface ViewController ()

@property (nonatomic, strong) MultipeerController *multipeerController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _multipeerController = [[MultipeerController alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
