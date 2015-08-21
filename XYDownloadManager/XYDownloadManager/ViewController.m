//
//  ViewController.m
//  XYDownloadManager
//
//  Created by b5m on 15/8/18.
//  Copyright (c) 2015年 b5m.gzy. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import "XYDownloadManager.h"


/**
 *  测试链接：
 *  http://s2.dpsapi.com/book_test/cover/1439545183.jpg
 *  http://mw5.dwstatic.com/1/3/1528/133489-99-1436409822.mp4
 */

@interface ViewController ()

@property (strong, nonatomic) NSOperation *opreation;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UITextView *urlTextView;

@property (strong, nonatomic) NSOperation *opreation1;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView1;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel1;
@property (weak, nonatomic) IBOutlet UITextView *urlTextView1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)start:(UIButton *)sender {
    


    if (sender.tag == 10) {
        _opreation1 = [[XYDownloadManager sharedInstance] downloadFileWithUrlString:@"http://mw5.dwstatic.com/1/3/1528/133489-99-1436409822.mp4" catchName:@"2.MP4" progress:^(CGFloat progress, CGFloat totalMBRead, CGFloat totalMBExpectedToRead) {
            _progressView1.progress = progress;
            _progressLabel1.text = [NSString stringWithFormat:@"%.1f%% \n %.1fMB/%.1fMB",progress*100,totalMBRead,totalMBExpectedToRead];
            //        NSLog(@"**%@**",[NSString stringWithFormat:@"task2:%.1f%% \n %.1fMB/%.1fMB",progress*100,totalMBRead,totalMBExpectedToRead]);
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self showSuccessHUD];
        } fail:^(AFHTTPRequestOperation *opertion, NSError *error) {
            NSLog(@"%@",error.description);
        }];
        
    }else {
        _opreation = [[XYDownloadManager sharedInstance] downloadFileWithUrlString:@"http://s2.dpsapi.com/book_test/cover/1439545183.jpg" catchName:@"1.jpg" progress:^(CGFloat progress, CGFloat totalMBRead, CGFloat totalMBExpectedToRead) {
            _progressView.progress = progress;
            _progressLabel.text = [NSString stringWithFormat:@"%.1f%% \n %.1fMB/%.1fMB",progress*100,totalMBRead,totalMBExpectedToRead];
            //        NSLog(@"**%@**",[NSString stringWithFormat:@"task1:%.1f%% \n %.1fMB/%.1fMB",progress*100,totalMBRead,totalMBExpectedToRead]);
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self showSuccessHUD];
        } fail:^(AFHTTPRequestOperation *opertion, NSError *error) {
            NSLog(@"%@",error.description);
        }];
        
        
    }
}

- (IBAction)stop:(UIButton *)sender {
    
    if (sender.tag == 10) {
        [[XYDownloadManager sharedInstance] pauseWithOperation:_opreation1];

    }else {
         [[XYDownloadManager sharedInstance] pauseWithOperation:_opreation];
    }
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
