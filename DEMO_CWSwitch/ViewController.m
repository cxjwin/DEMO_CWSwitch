//
//  ViewController.m
//  DEMO_CWSwitch
//
//  Created by 蔡 雪钧 on 14-3-20.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

#import "ViewController.h"
#import "CWSwitch.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CWSwitch *swi = [[[CWSwitch alloc] initWithFrame:CGRectZero] autorelease];
    swi.enabled = YES;
    swi.center = self.view.center;
    [swi addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:swi];

    UISwitch *swi2 = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
    swi2.enabled = YES;
    swi2.center = CGPointMake(self.view.center.x, self.view.center.y - 40);
    [swi2 addTarget:self action:@selector(test2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:swi2];
}

- (void)test {
    NSLog(@"%s", __func__);
}

- (void)test2 {
    NSLog(@"%s", __func__);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
