//
//  spgVideoCaptureViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/11/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgVideoCaptureViewController.h"

@interface spgVideoCaptureViewController ()

@end

@implementation spgVideoCaptureViewController
{
    AVCaptureSession *captureSession;
    AVCaptureDevice *captureDevice;
    BOOL firstFrame;
    int videoFps;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    videoFps=36;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - video capture

//reture the default video camera.
-(AVCaptureDevice *)getDefaultCamera
{
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    /*
    NSArray *cameras=[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *device in cameras)
    {
        if(device.position==AVCaptureDevicePositionBack)
            return device;
    }
     */
}

-(void)startVideoCapture
{
    if(captureDevice==nil)
    {
        captureDevice = [self getDefaultCamera];
    }
    
    if(captureDevice!=nil)
    {
        NSError *error=nil;
        AVCaptureDeviceInput *videoInput=[AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if(error!=nil||videoInput==nil)
        {
            captureDevice=nil;
            return;
        }
        
        captureSession=[[AVCaptureSession alloc] init];
        captureSession.sessionPreset=AVCaptureSessionPresetMedium;
        [captureSession addInput:videoInput];
        
        AVCaptureVideoDataOutput *dataOutput=[[AVCaptureVideoDataOutput alloc] init];
        NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:240], (id)kCVPixelBufferWidthKey,
                                  [NSNumber numberWithInt:320], (id)kCVPixelBufferHeightKey,
                                  nil];
        dataOutput.videoSettings=settings;
       
        dispatch_queue_t queue = dispatch_queue_create("spg.scooter.video", NULL);
        [dataOutput setSampleBufferDelegate:self queue:queue];
        [captureSession addOutput:dataOutput];
        
        
        AVCaptureVideoPreviewLayer *previewLayer=[AVCaptureVideoPreviewLayer layerWithSession:captureSession];
        previewLayer.frame=self.view.bounds;
        previewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    
        [self.view.layer addSublayer:previewLayer];
        
        firstFrame=YES;
        [captureSession startRunning];
    }
}

-(void)stopVideoCapture
{
    if(captureSession)
    {
        [captureSession stopRunning];
        captureSession=nil;
    }
    captureDevice=nil;
    
    for(UIView *view in self.view.subviews)
    {
        [view removeFromSuperview];
    }
}

#pragma mark - video output delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVPixelBufferRef pixelBuffer=CMSampleBufferGetImageBuffer(sampleBuffer);
    if(CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess)
    {
        //UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddress(pixelBuffer);
        //size_t buffeSize = CVPixelBufferGetDataSize(pixelBuffer);
        if(firstFrame)
        {
                //第一次数据要求：宽高，类型
                //int width = CVPixelBufferGetWidth(pixelBuffer);
                //int height = CVPixelBufferGetHeight(pixelBuffer);
                
                int pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
                switch (pixelFormat) {
                    case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_nv12; // iPhone 3GS or 4
                        NSLog(@"Capture pixel format=NV12");
                        break;
                    case kCVPixelFormatType_422YpCbCr8:
                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_uyvy422; // iPhone 3
                        NSLog(@"Capture pixel format=UYUY422");
                        break;
                    default:
                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_rgb32;
                        NSLog(@"Capture pixel format=RGB32");
                        break;
                }
                
                firstFrame = NO;
      }
        /*We unlock the buffer*/
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0); 
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
