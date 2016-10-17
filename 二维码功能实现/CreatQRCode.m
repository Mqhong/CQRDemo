//
//  CreatQRCode.m
//  二维码功能实现
//
//  Created by mm on 2016/10/17.
//  Copyright © 2016年 mm. All rights reserved.
//

#import "CreatQRCode.h"

@interface CreatQRCode ()

@property(nonatomic,strong) UIImageView *imageview;

@property(nonatomic,strong) UITextField *textfield;

@property(nonatomic,strong) UIButton *btn;

@end

@implementation CreatQRCode

-(UIButton *)btn{
    if (_btn == nil) {
        _btn = [[UIButton alloc] init];
        _btn.backgroundColor = [UIColor orangeColor];
        [_btn setTitle:@"生成" forState:UIControlStateNormal];
    }
    return _btn;
}

-(UITextField *)textfield{
    if (_textfield == nil) {
        _textfield = [[UITextField alloc] init];
        _textfield.textAlignment = NSTextAlignmentCenter;
        _textfield.backgroundColor = [UIColor grayColor];
    }
    return _textfield;
}

-(UIImageView *)imageview{
    if (_imageview == nil) {
        _imageview = [[UIImageView alloc] init];
        CGFloat x = ([UIScreen mainScreen].bounds.size.width - 150 ) * 0.5;
        _imageview.frame = CGRectMake(x, 64 + 60, 150, 150);
    }
    return _imageview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"生成二维码";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.imageview];
    
    self.textfield.frame = CGRectMake(20, 64+10, [UIScreen mainScreen].bounds.size.width-40, 44);
    [self.view addSubview:self.textfield];
    CGFloat btnw = [UIScreen mainScreen].bounds.size.width * 0.6;
    CGFloat btnx = btnw/3;
    CGFloat btny = CGRectGetMaxY(self.imageview.frame) + 10;
    self.btn.frame = CGRectMake(btnx, btny, btnw, 44);
    [self.view addSubview:self.btn];
    [self.btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
}


-(void)btnClick{
    if (self.textfield.text.length ==0 ) {
        return ;
    }
    self.imageview.image = [self CreateQRCodeImage:self.textfield.text];
}



/**
 把字符串搞成二维码

 @param QRString 需要搞成的二维码

 @return 搞成的二维码image
 */
-(UIImage *)CreateQRCodeImage:(NSString *)QRString{
    //1.创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //2.恢复默认
    [filter setDefaults];
    
    //3.给过滤器添加数据
    NSString *dataString = QRString;
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    //4.通过KVO设置滤镜inputMessage数据
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    //5.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    
    //6.将CIImage转换成UIImage,并放大显示
    //    self.imageview.image = [UIImage imageWithCIImage:outputImage];
    return  [self createNonInterpolatedUIImageFormCIImage:outputImage withSie:150];
}


/**
 把生成的二维码更加清晰

 @param image 传入的原始图
 @param size  要放大的大侠

 @return 处理完毕的图
 */
-(UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSie:(CGFloat)size{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    //1.创建bitmap
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapimage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapimage);
    
    //2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapimage);
    return [UIImage imageWithCGImage:scaledImage];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
