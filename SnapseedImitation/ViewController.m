//
//  ViewController.m
//  CoreImageDemo
//
//  Created by Gejiaxin on 16/12/25.
//  Copyright © 2016 VincentJac. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import "SnapseedDropMenu.h"
#import <math.h>
#import "GPUImage.h"


@interface ViewController () <SnapseedDropMenuDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    BOOL _change;
}

@property (nonatomic, strong) CALayer * imgLayer;
@property (nonatomic, strong) UIImage * originImg;
@property (nonatomic, strong) UIView * gestureView;
@property (nonatomic, strong) MBProgressHUD *tipHud;
@property (nonatomic, strong) UIScrollView * tabScrollView;
@property (nonatomic, strong) SnapseedDropMenu * menu;
@property (nonatomic, strong) UILabel * selectFilterNameLab;
@property (nonatomic, copy) NSArray<SnapseedDropMenuModel *> * colorFilterArray;
@property (nonatomic, copy) NSArray * tabbarFilterArray;
@property (nonatomic, strong) UIButton * leftbtn;
@property (nonatomic, strong) UIButton * rightbtn;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) GPUImageBrightnessFilter * brighterFilter;
@property (nonatomic, strong) GPUImageExposureFilter * exposureFilter;
@property (nonatomic, strong) GPUImageContrastFilter * constrastFilter;
@property (nonatomic, strong) GPUImageHighlightShadowFilter * lightShadowFilter;
@property (nonatomic, strong) GPUImageHighlightShadowFilter * highLightFilter;
@property (nonatomic, strong) GPUImageFilterPipeline  * filterPipeline;
@property (nonatomic, strong) GPUImagePicture * gpuOriginImage;
@property (nonatomic, strong) GPUImageView * previewImageView;
@property (nonatomic, strong) NSMutableArray * filtersArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initUI {
    self.view.backgroundColor = BACKGROUNDCOLOR;
    //loading tip
    _tipHud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_tipHud];
    
    self.leftbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftbtn.frame = CGRectMake(0, 30, 100, 30);
    [self.leftbtn setTitle:@"Save" forState:UIControlStateNormal];
    [self.leftbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.leftbtn addTarget:self action:@selector(saveImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leftbtn];
    
    self.rightbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightbtn.frame = CGRectMake(SCREEN_WIDTH - 100, 30, 100, 30);
    [self.rightbtn setTitle:@"Open" forState:UIControlStateNormal];
    [self.rightbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rightbtn addTarget:self action:@selector(openAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rightbtn];
    
    
    
    self.selectFilterNameLab = [[UILabel alloc]  initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NAV_VIEW_HEIGHT + 30)];
    self.selectFilterNameLab.textColor = [UIColor whiteColor];
    self.selectFilterNameLab.backgroundColor = [UIColor clearColor];
    self.selectFilterNameLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.selectFilterNameLab];
    
    self.gestureView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:self.gestureView];
    
    //Snapseed menu
    CGPoint point = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    self.menu = [[SnapseedDropMenu alloc]initWithArray:self.colorFilterArray  viewCenterPoint:point inView:self.gestureView];
    self.menu.dropMenuDelegate = self;
    [self.view addSubview:self.menu];
    
    
}

- (void) initData {
    _change = YES;
 
    SnapseedDropMenuModel * brightModel = [[SnapseedDropMenuModel alloc]initWithTitle:@"Bright" defaultValue:0 maxValue:1 minValue:-1];
    
    SnapseedDropMenuModel * constrastModel = [[SnapseedDropMenuModel alloc]initWithTitle:@"Constrast" defaultValue:1 maxValue:4 minValue:0];
    
    SnapseedDropMenuModel * exposureModel = [[SnapseedDropMenuModel alloc]initWithTitle:@"Exposure" defaultValue:1 maxValue:4 minValue:-2];
    
    SnapseedDropMenuModel * shadowModel = [[SnapseedDropMenuModel alloc]initWithTitle:@"Shadow" defaultValue:0 maxValue:4 minValue:0];
    
    SnapseedDropMenuModel * hightLightMolde = [[SnapseedDropMenuModel alloc]initWithTitle:@"HightLight" defaultValue:1 maxValue:1 minValue:0];
    
    self.colorFilterArray = @[brightModel,constrastModel,exposureModel,shadowModel,hightLightMolde];
    
    self.brighterFilter = [[GPUImageBrightnessFilter alloc] init];
    self.constrastFilter = [[GPUImageContrastFilter alloc] init];
    self.exposureFilter = [[GPUImageExposureFilter alloc] init];
    self.lightShadowFilter = [[GPUImageHighlightShadowFilter alloc] init];
    self.highLightFilter = [[GPUImageHighlightShadowFilter alloc] init];
    
    
    _filtersArray = [NSMutableArray arrayWithObjects:self.brighterFilter,self.constrastFilter,self.exposureFilter,self.lightShadowFilter,self.highLightFilter,nil];
    
    self.originImg = [UIImage imageNamed:@"Duck.jpg"];
    self.gpuOriginImage = [[GPUImagePicture alloc] initWithImage:self.originImg
                                             smoothlyScaleOutput:YES];
    [self.gpuOriginImage processImage];
    [self.gpuOriginImage addTarget:self.brighterFilter];
    [self.gpuOriginImage addTarget:self.constrastFilter];
    [self.gpuOriginImage addTarget:self.exposureFilter];
    [self.gpuOriginImage addTarget:self.lightShadowFilter];
    [self.gpuOriginImage addTarget:self.highLightFilter];
    
    
    self.previewImageView = [[GPUImageView alloc] initWithFrame:CGRectZero];
    self.previewImageView.width = SCREEN_WIDTH - 30;
    self.previewImageView.height = SCREEN_HEIGHT / 3 * 2;
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.previewImageView.centerX = SCREEN_WIDTH / 2;
    self.previewImageView.y = SCREEN_HEIGHT / 6;
    [self.view addSubview:self.previewImageView];
    
    
    
    self.filterPipeline = [[GPUImageFilterPipeline alloc]initWithOrderedFilters:_filtersArray input:self.gpuOriginImage output:_previewImageView];
    [_gpuOriginImage processImage];
}

#pragma mark button action block
- (void)openAlbum:(UIButton *)sender {
    self.picker = [[UIImagePickerController alloc] init];
    [self settingGeneralProperty];
    [self presentViewController:self.picker animated:YES completion:nil];

}

- (void)saveImage:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message" message:@"Save photo?" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
        [self showLoadingTips];
        
        [self saveEditImage];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    

}

- (void)saveEditImage {
    SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
    UIImage * saveImage = [self createFinalImage];
    UIImageWriteToSavedPhotosAlbum(saveImage, self,selectorToCall, NULL);
}

- (UIImage *)createFinalImage{
    
    UIImage * currentImage;
    GPUImagePicture * temp = [[GPUImagePicture alloc]initWithImage:self.originImg];
    for(GPUImageFilter * filter in self.filtersArray) {
        [temp addTarget:filter];
        [temp processImage];
        [filter useNextFrameForImageCapture];
        currentImage = [filter imageFromCurrentFramebuffer];
        if(!currentImage) {
            break;
        } else {
            temp = [[GPUImagePicture alloc]initWithImage:currentImage];
        }
    }
    return currentImage;
}

#pragma mark UIImagePicker Delegate

- (void) imageWasSavedSuccessfully:(UIImage *)paramImage
          didFinishSavingWithError:(NSError *)paramError
                       contextInfo:(void *)paramContextInfo {
    [self dismissLoadingTips];
    if (paramError == nil){
        [self showTextTips:@"Saving successfully"];
        NSLog(@"Image was saved successfully.");
    } else {
        [self showTextTips:@"Saved failure"];
        NSLog(@"An error happened while saving the image.");
        NSLog(@"Error = %@", paramError);
    }
    
    
}


- (void)settingGeneralProperty {
    /*
        UIImagePickerControllerSourceTypePhotoLibrary
        UIImagePickerControllerSourceTypeCamera
        UIImagePickerControllerSourceTypeSavedPhotosAlbum
     */
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    _picker.allowsEditing = YES;
    _picker.delegate = self;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    /*
         info   key
         UIImagePickerControllerMediaType
         UIImagePickerControllerOriginalImage
         UIImagePickerControllerEditedImage
         UIImagePickerControllerCropRect
         UIImagePickerControllerMediaURL
         UIImagePickerControllerReferenceURL
         UIImagePickerControllerMediaMetadata
         UIImagePickerControllerLivePhoto       // a PHLivePhoto
     */
    __weak UIImage * pickerImg = [info objectForKey:UIImagePickerControllerEditedImage];
    self.originImg = pickerImg;
    
    
    
    //Compression Quality
//    NSData *dataEdited = UIImageJPEGRepresentation(self.imageView.image, 0.3);
    [_picker dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"Cancel");
    [_picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark SnapseedDropMenu Delegate
- (void)snapseedDropMenu:(SnapseedDropMenu *)sender
    didSelectCellAtIndex:(NSInteger)index
                   value:(CGFloat)value{
    SnapseedDropMenuModel * model = [self.colorFilterArray objectAtIndex:index];
    NSString * colorFilterName = [NSString stringWithFormat:@"%@  %.1f",model.title,value];
    self.selectFilterNameLab.text = colorFilterName;
}

- (void)snapseedDropMenu:(SnapseedDropMenu *)sender
                 atIndex:(NSInteger)index
          valueDidChange:(CGFloat)value {

}

- (void)snapseedDropMenu:(SnapseedDropMenu *)sender
                 atIndex:(NSInteger)index
              isChanging:(CGFloat)value {
    SnapseedDropMenuModel * model = [self.colorFilterArray objectAtIndex:index];
    NSString * colorFilterName = [NSString stringWithFormat:@"%@  %.1f",model.title,value];
    self.selectFilterNameLab.text = colorFilterName;
    [self randerImageWithFilter:index value:value];
}

#pragma mark - Filter

- (void)randerImageWithFilter:(NSInteger)index value:(CGFloat)value{
    switch (index) {
        case 0: {
            if(_brighterFilter) {
                _brighterFilter.brightness = value ;
                [_gpuOriginImage processImage];
                [_brighterFilter useNextFrameForImageCapture];
            }
        }
            break;
        case 1: {
            if(_constrastFilter) {
                _constrastFilter.contrast = value;
                [_gpuOriginImage processImage];
                [_constrastFilter useNextFrameForImageCapture];
            }
        }
            break;
        case 2: {
            if(_exposureFilter) {
                _exposureFilter.exposure = value ;
                [_gpuOriginImage processImage];
                [_exposureFilter useNextFrameForImageCapture];

            }
        }
            break;
        case 3: {
            if(_lightShadowFilter) {
                _lightShadowFilter.shadows = value;
                [_gpuOriginImage processImage];
                [_lightShadowFilter useNextFrameForImageCapture];
            }
        } break;
        case 4: {
            if(self.highLightFilter) {
                self.highLightFilter.highlights = value;
                [_gpuOriginImage processImage];
                [self.highLightFilter useNextFrameForImageCapture];
            }
        }
        default:
            break;
    }
   
}






#pragma mark - HUD

- (void)showTextTips:(NSString *)tips {
    if(!_tipHud) {
        _tipHud = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    }
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:NO];
    [[UIApplication sharedApplication].keyWindow addSubview:_tipHud];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_tipHud];
    _tipHud.mode = MBProgressHUDModeText;
    _tipHud.labelText = tips;
    [_tipHud show:YES];
    [_tipHud hide:YES afterDelay:1];
}

- (void)showLoadingTips {
    if(!_tipHud) {
        _tipHud = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    }
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:NO];
    [[UIApplication sharedApplication].keyWindow addSubview:_tipHud];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_tipHud];
    _tipHud.labelText = nil;
    _tipHud.mode = MBProgressHUDModeIndeterminate;
    [_tipHud show:YES];

}

- (void)dismissLoadingTips {
    [_tipHud hide:YES];
}
@end
