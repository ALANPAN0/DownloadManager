//
//  ViewController.m
//  XYDownloadManger
//
//  Created by b5m on 15/8/13.
//  Copyright (c) 2015年 b5m.gzy. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import "XYDownloadManger.h"

@interface ViewController ()

@property (strong, nonatomic) NSOperation *opreation;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UITextView *urlTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)start {
    _opreation = [[XYDownloadManger sharedInstance] downloadFileWithUrlString:_urlTextView.text catchName:@"test.mp4" progress:^(CGFloat progress, CGFloat totalMBRead, CGFloat totalMBExpectedToRead) {
        _progressView.progress = progress;
        _progressLabel.text = [NSString stringWithFormat:@"%.1f%% \n %.1fMB/%.1fMB",progress*100,totalMBRead,totalMBExpectedToRead];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self showSuccessHUD];
    } fail:^(AFHTTPRequestOperation *opertion, NSError *error) {
        NSLog(@"%@",error.description);
    }];
}

- (IBAction)stop {
    [[XYDownloadManger sharedInstance] pauseWithOperation:_opreation];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)showSuccessHUD {
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_HUD];
    _HUD.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
    _HUD.mode = MBProgressHUDModeCustomView;
    _HUD.labelText = @"Success";
    [_HUD show:YES];
    [_HUD hide:YES afterDelay:2.0f];
}

@end
