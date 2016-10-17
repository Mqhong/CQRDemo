//
//  ViewController.m
//  二维码功能实现
//
//  Created by mm on 2016/10/17.
//  Copyright © 2016年 mm. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic,strong) UIView *viewPreview;
@property (nonatomic,strong) UILabel *lblStatus;
@property (nonatomic,strong) UIButton *startBtn;
-(void)startStopReading:(id)sender;

@property (nonatomic,strong) UIView *boxView;
@property (nonatomic,assign) BOOL isReading;
@property (nonatomic,strong) CALayer *scanLayer;

-(BOOL)startReading;
-(void)stopReading;

//捕捉会话
@property (nonatomic,strong) AVCaptureSession *captureSession;
//展示layer
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"扫描二维码";
    _captureSession = nil;
    _isReading = NO;
    
    self.viewPreview = [[UIView alloc] init];
    self.viewPreview.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.width * 0.6);
    self.viewPreview.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.viewPreview];
    
    self.lblStatus = [[UILabel alloc] init];
    self.lblStatus.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
    self.lblStatus.backgroundColor = [UIColor orangeColor];
    [self.viewPreview addSubview:self.lblStatus];
    
    
    self.startBtn = [[UIButton alloc] init];
    CGFloat btny = CGRectGetMaxY(self.viewPreview.frame);
    self.startBtn.frame = CGRectMake(0, btny+20, self.view.bounds.size.width, 44);
    self.startBtn.backgroundColor = [UIColor orangeColor];
    [self.startBtn setTitle:@"start" forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(startStopReading:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.startBtn];
    
//    UIButton *btn = [[UIButton alloc] init];
//    btn.frame = CGRectMake(100, 100, 150, 150);
//    btn.backgroundColor = [UIColor orangeColor];
//    [btn setTitle:@"实现二维码" forState:UIControlStateNormal];
//    [self.view addSubview:btn];
}


-(BOOL)startReading{
    
    NSError *error;
    //1.初始化捕捉设备(AVCaptureDevice),类型为AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.用captureDevice创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@",[error localizedDescription]);
        return NO;
    }
    
    //3.创建媒体数据输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    //4.实例化捕捉会话
    _captureSession = [[AVCaptureSession alloc] init];
    
    //4.1.将输入流添加到会话
    [_captureSession addInput:input];
    
    //4.2.将媒体输出流添加到回话中
    [_captureSession addOutput:captureMetadataOutput];
    
    //5.创建串行队列，并加媒体输出流添加到队列当中
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    
    //5.1.设置代理
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    //5.2.设置输出媒体数据类型为QRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    //6.实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    
    //7.设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //8.设置图层的frame
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    
    //9.将图层添加到预览view的图层上
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    //10.设置扫描范围
    captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
    
    //10.1.扫描框
    _boxView = [[UIView alloc] initWithFrame:CGRectMake(_viewPreview.bounds.size.width * 0.2f, _viewPreview.bounds.size.height * 0.2f, _viewPreview.bounds.size.width - _viewPreview.bounds.size.width * 0.4f, _viewPreview.bounds.size.height - _viewPreview.bounds.size.height * 0.4f)];
    _boxView.layer.borderColor = [UIColor greenColor].CGColor;
    _boxView.layer.borderWidth = 1.0f;
    
    [_viewPreview addSubview:_boxView];
    
    //10.2.扫描线
    _scanLayer = [[CALayer alloc] init];
    _scanLayer.frame = CGRectMake(0, 0, _boxView.bounds.size.width, 1);
    _scanLayer.backgroundColor = [UIColor brownColor].CGColor;
    
    [_boxView.layer addSublayer:_scanLayer];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(moveScanLayer:) userInfo:nil repeats:YES];
    
    [timer fire];
    
    //10.开始扫描
    [_captureSession startRunning];
    
    return YES;
    
}


-(void)startStopReading:(id)sender{
    if (!_isReading) {
        if ([self startReading]) {
            [_startBtn setTitle:@"Stop" forState:UIControlStateNormal];
            [_lblStatus setText:@"Scanning for QR Code"];
        }
    }else{
        [self stopReading];
        [_startBtn setTitle:@"Start!" forState:UIControlStateNormal];
    }
    
    _isReading = !_isReading;
}

-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    [_scanLayer removeFromSuperlayer];
    [_videoPreviewLayer removeFromSuperlayer];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSLog(@"???");
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSLog(@"[metadataObj stringValue]:\t%@",[metadataObj stringValue]);
        //判断回传的数据类型
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            _isReading = NO;
        }
    }
}

-(void)moveScanLayer:(NSTimer *)timer{
    CGRect frame = _scanLayer.frame;
    
    if (_boxView.frame.size.height < _scanLayer.frame.origin.y) {
        frame.origin.y = 0;
        _scanLayer.frame = frame;
    }else{
        frame.origin.y += 5;
        [UIView animateWithDuration:0.1 animations:^{
            _scanLayer.frame = frame;
        }];
    }
}

-(BOOL)shouldAutorotate{
    return NO;
}































- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
