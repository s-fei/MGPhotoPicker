//
//  BQCamera.m
//  BQCommunity
//
//  Created by ZL on 14-9-11.
//  Copyright (c) 2014年 beiqing. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <objc/message.h>
#import "ZLCameraViewController.h"
#import "ZLCameraImageView.h"
#import "ZLCameraView.h"
#import "LGCameraImageView.h"
#import "SCSlider.h"
#import <MGProgressHUD/MGProgressHUD-Swift.h>
#import "LGPhotoPickerCommon.h"

typedef void(^codeBlock)();
//static CGFloat BOTTOM_HEIGHT = 60;

@interface ZLCameraViewController () <UIActionSheetDelegate,AVCaptureMetadataOutputObjectsDelegate,ZLCameraImageViewDelegate,ZLCameraViewDelegate,LGCameraImageViewDelegate>

@property (weak,nonatomic) ZLCameraView *caramView;
@property (strong, nonatomic) UIViewController *currentViewController;

// Datas
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableDictionary *dictM;

// AVFoundation
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureStillImageOutput *captureOutput;
@property (strong, nonatomic) AVCaptureDevice *device;

@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@property (nonatomic, assign) XGImageOrientation imageOrientation;
@property (nonatomic, assign) NSInteger flashCameraState;

@property (nonatomic, strong) UIButton *flashBtn;
@property (nonatomic, strong) UIButton *cameraBtn;

@property (nonatomic, strong) SCSlider *scSlider;


@property (nonatomic, assign) double scSliderValue;

@property (nonatomic, assign) CGFloat cameraScale;

@property (nonatomic, strong)UIPinchGestureRecognizer *pinch;

@property (nonatomic, assign) int failIndex;

@end

@implementation ZLCameraViewController

#pragma mark - Getter
#pragma mark Data
- (NSMutableArray *)images{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (NSMutableDictionary *)dictM{
    if (!_dictM) {
        _dictM = [NSMutableDictionary dictionary];
    }
    return _dictM;
}

- (void) initialize
{
    //1.创建会话层
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    self.captureOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [self.captureOutput setOutputSettings:outputSettings];
    
    // Session
    self.session = [[AVCaptureSession alloc]init];
    
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:_captureOutput])
    {
        [self.session addOutput:_captureOutput];
    }
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = viewWidth / 480 * 640;;
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    viewHeight = viewHeight > (self.view.frame.size.height - 50 - 60) ? (self.view.frame.size.height - 50 - 60) :viewHeight;
    self.preview.frame = CGRectMake(0, 50,viewWidth, viewHeight);
    
    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    ZLCameraView *caramView = [[ZLCameraView alloc] initWithFrame:self.preview.frame];
    caramView.backgroundColor = [UIColor clearColor];
    caramView.delegate = self;
    [self.contentView addSubview:caramView];
    [self.contentView.layer insertSublayer:self.preview atIndex:0];
    self.caramView = caramView;
}

//伸缩镜头的手势
- (void)addPinchGesture {
    //横向
    CGFloat width = self.caramView.frame.size.width - 100;
    CGFloat height = 40;
    SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - width) / 2, self.caramView.frame.size.height - 60, width, height)];
    
    //竖向
    //    CGFloat width = 40;
    //    CGFloat height = self.caramView.frame.size.height - 100;
    //    SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake(self.caramView.frame.size.width - width, (self.caramView.frame.size.height + 44 - height) / 2, width, height) direction:SCSliderDirectionVertical];
    slider.alpha = 0.f;
    slider.minValue = 1;
    slider.maxValue = 3;
    
    __weak typeof(self) weakSelf = self;
    [slider buildDidChangeValueBlock:^(CGFloat value) {
        [weakSelf changeCamera];
    }];
    [slider buildTouchEndBlock:^(CGFloat value, BOOL isTouchEnd) {
        [weakSelf setSliderAlpha:isTouchEnd];
    }];
    
    [self.caramView addSubview:slider];
    
    self.scSlider = slider;
    
    self.pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.caramView addGestureRecognizer:self.pinch];
}

//伸缩镜头
- (void)handlePinch:(UIPinchGestureRecognizer*)gesture {
    
    //    [_captureManager pinchCameraView:gesture];
    if(gesture.state == UIGestureRecognizerStateBegan){
        self.scSliderValue = self.scSlider.value;
    }
    else if(gesture.state == UIGestureRecognizerStateEnded){
        
    }
    
    if (_scSlider) {
        if (_scSlider.alpha != 1.f) {
            [UIView animateWithDuration:0.3f animations:^{
                _scSlider.alpha = 1.f;
            }];
        }
        float scale =  gesture.scale*self.scSliderValue >= 3 ? 3:gesture.scale*self.scSliderValue;
        scale =  scale <= 1 ? 1:gesture.scale*self.scSliderValue;
        self.cameraScale = scale;
        
        if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
            [self setSliderAlpha:YES];
        } else {
            [self setSliderAlpha:NO];
        }
    }
    [self changeCamera];
}

- (void)setSliderAlpha:(BOOL)isTouchEnd {
    if (_scSlider) {
        _scSlider.isSliding = !isTouchEnd;
        
        if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
            double delayInSeconds = 2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
                    [UIView animateWithDuration:0.3f animations:^{
                        _scSlider.alpha = 0.f;
                    }];
                }
            });
        }
    }
}

-(AVCaptureConnection *)fandVideoConnection{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    return videoConnection;
}

-(void)changeCamera{
    AVCaptureConnection *videoConnection = [self fandVideoConnection];
    CGFloat scale = self.cameraScale <= videoConnection.videoMaxScaleAndCropFactor ? self.cameraScale:videoConnection.videoMaxScaleAndCropFactor;
    videoConnection.videoScaleAndCropFactor = scale;
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [self.preview setAffineTransform:CGAffineTransformMakeScale(scale, scale)];
    [CATransaction commit];
    [_scSlider setValue: scale shouldCallBack:NO];
}

- (void)cameraDidSelected:(ZLCameraView *)camera{
    [self.device lockForConfiguration:nil];
    [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
    [self.device setFocusPointOfInterest:CGPointMake(50,50)];
    //操作完成后，记得进行unlock。
    [self.device unlockForConfiguration];
}

//对焦回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if( [keyPath isEqualToString:@"adjustingFocus"] ){
        
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.isReloadData = YES;
    self.view.backgroundColor = [UIColor blackColor];
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor blackColor];
    contentView.frame = self.view.bounds;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:contentView];
    self.contentView = contentView;
    
    [self initialize];
    [self setup];
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    [alertView setHidden:YES];
    if (buttonIndex == 0) {
        //关闭相册界面
    }else if (buttonIndex == 1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    if(self.callback){
        self.callback(nil);
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    AVCaptureConnection *videoConnection = [self fandVideoConnection];
    if (videoConnection.videoMaxScaleAndCropFactor > 3 && !self.pinch) {
        [self addPinchGesture];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.isReloadData) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (AVAuthorizationStatusDenied == authStatus || AVAuthorizationStatusRestricted == authStatus) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"通知"
                                                        message:@"需要打开拍照权限"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"去设置", nil];
        [alert setDelegate:self];
        [alert dismissWithClickedButtonIndex:0 animated:NO];
        [alert show];
        return;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.isReloadData) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

-(void)dealloc{
    if (self.isReloadData) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

#pragma mark 初始化按钮
- (UIButton *) setupButtonWithImageName : (NSString *) imageName andX : (CGFloat ) x{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:GetImage(imageName) forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(x, 0, 80, self.topView.frame.size.height);
    [self.topView addSubview:button];
    return button;
}

#pragma mark -初始化界面
- (void) setup{
    CGFloat width = 50;
    CGFloat margin = 20;
    
    
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor blackColor];
    topView.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    [self.contentView addSubview:topView];
    self.topView = topView;
    
    // 头部View
    UIButton *deviceBtn = [self setupButtonWithImageName:@"xiang.png" andX:self.view.frame.size.width - margin - width];
    [deviceBtn addTarget:self action:@selector(changeCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *flashBtn = [self setupButtonWithImageName:@"shanguangdeng2.png" andX:10];
    [flashBtn addTarget:self action:@selector(flashCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
    __weak typeof(self) weakSelf = self;
    [self flashLightModel:^{
        if ([weakSelf.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            weakSelf.flashCameraState = 2;
            [weakSelf.device setFlashMode:AVCaptureFlashModeAuto];
            [flashBtn setTitle:@"自动" forState:UIControlStateNormal];
        }else
        {
            flashBtn.hidden =YES;
            
        }

    }];
    _flashBtn = flashBtn;
    
    //    UIButton *closeBtn = [self setupButtonWithImageName:@"shanguangdeng2" andX:60];
    //    [closeBtn addTarget:self action:@selector(closeFlashlight:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 底部View
    UIView *controlView = [[UIView alloc] initWithFrame:CGRectMake(0,  self.caramView.frame.size.height + 50 , self.view.frame.size.width, self.view.frame.size.height-(self.caramView.frame.size.height + 50))];
    controlView.backgroundColor = [UIColor blackColor];
    controlView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.controlView = controlView;
    
    UIView *contentView1 = [[UIView alloc] init];
    contentView1.frame = controlView.bounds;
    contentView1.backgroundColor = [UIColor blackColor];
    contentView1.alpha = 0.3;
    [controlView addSubview:contentView1];
    
    CGFloat x = (self.view.frame.size.width - width) / 3;
    //取消
    UIButton *cancalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancalBtn.frame = CGRectMake(0, 0, x, controlView.frame.size.height);
    [cancalBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancalBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:cancalBtn];
    //拍照
    self.cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraBtn.frame = CGRectMake(x+margin, margin / 4, x, controlView.frame.size.height - margin / 2);
    self.cameraBtn.showsTouchWhenHighlighted = YES;
    self.cameraBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.cameraBtn setImage:GetImage(@"paizhao.png") forState:UIControlStateNormal];
    [self.cameraBtn addTarget:self action:@selector(stillImage:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:self.cameraBtn];
    // 完成
    if (self.cameraType == ZLCameraContinuous) {
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = CGRectMake(self.view.frame.size.width - 2 * margin - width, 0, width, controlView.frame.size.height);
        [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
        [controlView addSubview:doneBtn];
    }
    
    [self.contentView addSubview:controlView];
}

- (void)showPickerVc:(UIViewController *)vc{
    __weak typeof(vc)weakVc = vc;
    if (weakVc != nil) {
        [weakVc presentViewController:self animated:YES completion:nil];
    }
}

-(void)Captureimage
{
    //get connection
    AVCaptureConnection *videoConnection = [self fandVideoConnection];
    //get UIImage
    [self.captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         
         if (error != nil)
         {
             if (self.failIndex == 2) {
                 [MGProgressHUD showTextAndHiddenView:self.contentView message:@"对不起,请您使用系统相机或直接在相册选照片!"];
             }else
             {
                 [MGProgressHUD showTextAndHiddenView:self.contentView message:@"再试一次额"];
                 self.failIndex ++;
             }
         }
         else
         {
             CFDictionaryRef exifAttachments =
             CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
             if (exifAttachments) {
                 // Do something with the attachments.
             }
             if (CMSampleBufferIsValid(imageSampleBuffer)) {
                 // Continue as appropriate.
                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                 UIImage *t_image = [UIImage imageWithData:imageData];
                 t_image = [self cutImage:t_image];
                 t_image = [self fixOrientation:t_image];
                 NSData *data = UIImageJPEGRepresentation(t_image, 0.3);
                 ZLCamera *camera = [[ZLCamera alloc] init];
                 camera.photoImage = t_image;
                 camera.thumbImage = [UIImage imageWithData:data];
                 
                 if (self.cameraType == ZLCameraSingle) {
                     [self.images removeAllObjects];//由于当前只需要一张图片2015-11-6
                     [self.images addObject:camera];
                     [self displayImage:camera.photoImage];
                 } else if (self.cameraType == ZLCameraContinuous) {
                     [self.images addObject:camera];
                 }
                 self.failIndex = 0;
             }
             else
             {
                 if (self.failIndex == 2) {
                     [MGProgressHUD showTextAndHiddenView:self.contentView message:@"对不起,请您使用系统相机或直接在相册选照片!"];
                 }else
                 {
                     [MGProgressHUD showTextAndHiddenView:self.contentView message:@"再试一次额"];
                     self.failIndex ++;
                 }
             }
         }
    }];
}

//裁剪image
- (UIImage *)cutImage:(UIImage *)srcImg {
    //注意：这个rect是指横屏时的rect，即屏幕对着自己，home建在右边
    CGRect rect = CGRectMake((srcImg.size.height / CGRectGetHeight(self.view.frame)) * 70, 0, srcImg.size.width * 1.33, srcImg.size.width);
    CGImageRef subImageRef = CGImageCreateWithImageInRect(srcImg.CGImage, rect);
    CGFloat subWidth = CGImageGetWidth(subImageRef);
    CGFloat subHeight = CGImageGetHeight(subImageRef);
    CGRect smallBounds = CGRectMake(0, 0, subWidth, subHeight);
    //旋转后，画出来
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, subWidth);
    transform = CGAffineTransformRotate(transform, -M_PI_2);
    CGContextRef ctx = CGBitmapContextCreate(NULL, subHeight, subWidth,
                                             CGImageGetBitsPerComponent(subImageRef), 0,
                                             CGImageGetColorSpace(subImageRef),
                                             CGImageGetBitmapInfo(subImageRef));
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx, smallBounds, subImageRef);
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
    
    //    CGImageRef subImageRef = CGImageCreateWithImageInRect(srcImg.CGImage, rect);
    //    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    //
    //    UIGraphicsBeginImageContext(smallBounds.size);
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextDrawImage(context, smallBounds, subImageRef);
    //    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef scale:1 orientation:UIImageOrientationRight];//由于直接从subImageRef中得到uiimage的方向是逆时针转了90°的
    //    UIGraphicsEndImageContext();
    //    CGImageRelease(subImageRef);
    //
    //    return smallImage;
}

//旋转image
- (UIImage *)fixOrientation:(UIImage *)srcImg
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat width = srcImg.size.width;
    CGFloat height = srcImg.size.height;
    
    CGContextRef ctx;
    
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown: //竖屏，不旋转
            ctx = CGBitmapContextCreate(NULL, width, height,
                                        CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                        CGImageGetColorSpace(srcImg.CGImage),
                                        CGImageGetBitmapInfo(srcImg.CGImage));
            break;
            
        case UIDeviceOrientationLandscapeLeft:  //横屏，home键在右手边，逆时针旋转90°
            transform = CGAffineTransformTranslate(transform, height, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            ctx = CGBitmapContextCreate(NULL, height, width,
                                        CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                        CGImageGetColorSpace(srcImg.CGImage),
                                        CGImageGetBitmapInfo(srcImg.CGImage));
            break;
            
        case UIDeviceOrientationLandscapeRight:  //横屏，home键在左手边，顺时针旋转90°
            transform = CGAffineTransformTranslate(transform, 0, width);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            ctx = CGBitmapContextCreate(NULL, height, width,
                                        CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                        CGImageGetColorSpace(srcImg.CGImage),
                                        CGImageGetBitmapInfo(srcImg.CGImage));
            break;
            
        default:
            break;
    }
    
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx, CGRectMake(0,0,width,height), srcImg.CGImage);
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}

//LG
- (void)displayImage:(UIImage *)images {
    LGCameraImageView *view = [[LGCameraImageView alloc] initWithFrame:self.view.frame];
    view.delegate = self;
    view.imageOrientation = _imageOrientation;
    view.imageToDisplay = images;
    [self.contentView addSubview:view];
    
}

-(void)CaptureStillImage
{
    [self  Captureimage];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

- (void)changeCameraDevice:(id)sender
{
    
    NSArray *inputs = self.session.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            [self.session beginConfiguration];
            if (newInput != nil) {
                // 翻转
                [UIView beginAnimations:@"animation" context:nil];
                [UIView setAnimationDuration:.5f];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.contentView cache:YES];
                [UIView commitAnimations];
                [self.session removeInput:input];
                [self.session addInput:newInput];
            }
            else
            {
                [MGProgressHUD showTextAndHiddenView:self.contentView message:@"请重试,或直接在相册选照片"];
            }
            [self.session commitConfiguration];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            break;
        }
    }
}

- (void) flashLightModel : (codeBlock) codeBlock{
    if (!codeBlock) return;
    [self.session beginConfiguration];
    [self.device lockForConfiguration:nil];
    codeBlock();
    [self.device unlockForConfiguration];
    [self.session commitConfiguration];
    [self.session startRunning];
}
- (void) flashCameraDevice:(UIButton *)sender{
    
    if (_flashCameraState < 0) {
        _flashCameraState = 0;
    }
    _flashCameraState ++;
    if (_flashCameraState >= 4) {
        _flashCameraState = 1;
    }
    AVCaptureFlashMode mode;
    
    switch (_flashCameraState) {
        case 1:
            mode = AVCaptureFlashModeOn;
            if ([self.device isFlashModeSupported:mode])
            {
                [_flashBtn setTitle:@"打开" forState:UIControlStateNormal];
                [self flashLightModel:^{
                    [self.device setFlashMode:mode];
                }];
            }
            break;
        case 2:
            mode = AVCaptureFlashModeAuto;
            if ([self.device isFlashModeSupported:mode])
            {
                [_flashBtn setTitle:@"自动" forState:UIControlStateNormal];
                [self flashLightModel:^{
                    [self.device setFlashMode:mode];
                }];
            }
            break;
        case 3:
            mode = AVCaptureFlashModeOff;
            if ([self.device isFlashModeSupported:mode])
            {
                [_flashBtn setTitle:@"关闭" forState:UIControlStateNormal];
                [self flashLightModel:^{
                    [self.device setFlashMode:mode];
                }];
            }
            break;
        default:
            mode = AVCaptureFlashModeOff;
            if ([self.device isFlashModeSupported:mode])
            {
                [_flashBtn setTitle:@"关闭" forState:UIControlStateNormal];
                [self flashLightModel:^{
                    [self.device setFlashMode:mode];
                }];
            }
            break;
    }
}

- (void)cancel:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [self flashLightModel:^{
        if ([weakSelf.device isFlashModeSupported:AVCaptureFlashModeOff]) {
            [weakSelf.device setFlashMode:AVCaptureFlashModeOff];
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//拍照
- (void)stillImage:(id)sender
{
    // 判断图片的限制个数
    if (self.maxCount > 0 && self.images.count >= self.maxCount) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"拍照的个数不能超过%ld",(long)self.maxCount]delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alertView show];
        return ;
    }
    
    [self Captureimage];
    //    UIView *maskView = [[UIView alloc] init];
    //    maskView.frame = self.view.bounds;
    //    maskView.backgroundColor = [UIColor whiteColor];
    //    [self.view addSubview:maskView];
    //    [UIView animateWithDuration:.5 animations:^{
    //        maskView.alpha = 0;
    //    } completion:^(BOOL finished) {
    //        [maskView removeFromSuperview];
    //    }];
}

- (BOOL)shouldAutorotate{
    return YES;
}

#pragma mark - 屏幕
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}
// 支持屏幕旋转
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
// 画面一开始加载时就是竖向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - XGCameraImageViewDelegate
- (void)xgCameraImageViewSendBtnTouched {
    [self doneAction];
}

- (void)xgCameraImageViewCancleBtnTouched {
    [self.images removeAllObjects];
}
//完成、取消
- (void)doneAction
{
    __weak typeof(self) weakSelf = self;
    [self flashLightModel:^{
        if ([weakSelf.device isFlashModeSupported:AVCaptureFlashModeOff]) {
            [weakSelf.device setFlashMode:AVCaptureFlashModeOff];
        }
    }];
    //关闭相册界面
    if(self.callback){
        self.callback(self.images);
    }
}
@end

