//
//  ViewController.m
//  PullAnimation
//
//  Created by Lois_pan on 16/7/5.
//  Copyright © 2016年 Lois_pan. All rights reserved.
//

#import "ViewController.h"
#import "PSAnimationView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    PSAnimationView *psView = [[PSAnimationView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    psView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:psView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
