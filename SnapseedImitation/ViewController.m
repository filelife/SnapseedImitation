//
//  ViewController.m
//  CoreImageDemo
//
//  Created by Gejiaxin on 16/12/25.
//  Copyright © 2016 VincentJac. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>
#import "MBProgressHUD.h"
#import "SnapseedDropMenu.h"
#import <math.h>
#import "GPUImage.h"

#define FilterCellWidth 120
#define MoveZoom 20
#define TabbarHeight 40
NSString * const cellId = @"FilterCell";

typedef NS_ENUM(NSInteger, ColorFilterType) {
    SaturationFilter = 101,
    BrightnessFilter,
    ContrastFilter,
    LightShadow
};

typedef NS_ENUM(NSInteger, FilterType) {
    GaussianBlur = 201,
    SepiaTone,
    AffineTransform,
    ModTransition
};

@interface ViewController () <SnapseedDropMenuDelegate,UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    BOOL _change;
    
    UIActivityIndicatorView * _activityIndicator;
    dispatch_queue_t _serialQueue;
    CIFilter * _colorFilter;
}
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) CALayer * imgLayer;
@property (nonatomic, strong) UIImage * originImg;
@property (nonatomic, strong) UIView * gestureView;
@property (nonatomic, strong) MBProgressHUD *tipHud;
@property (nonatomic, strong) UIScrollView * tabScrollView;
@property (nonatomic, strong) SnapseedDropMenu * menu;
@property (nonatomic, strong) UILabel * selectFilterNameLab;
@property (nonatomic, copy) NSArray<SnapseedDropMenuModel *> * colorFilterArray;
@property (nonatomic, copy) NSArray * tabbarFilterArray;
@property (nonatomic, strong) NSMutableArray<NSNumber *> * colorFilterValueArray;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UIButton * leftbtn;
@property (nonatomic, strong) UIButton * rightbtn;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) GPUImageBrightnessFilter * brighterFilter;
@property (nonatomic, strong) GPUImageExposureFilter * exposureFilter;
@property (nonatomic, strong) GPUImageContrastFilter * constrastFilter;
@property (nonatomic, strong) GPUImageHighlightShadowFilter * lightShadowFilter;

@property (nonatomic, strong) GPUImagePicture * gpuOriginImage;
@property (nonatomic, weak) UIImage * cacheImg;
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
    // Pic
    
    self.originImg = [UIImage imageNamed:@"Duck.jpg"];
    self.imageView = [[UIImageView alloc]initWithImage:self.originImg];
    self.imageView.width = SCREEN_WIDTH - 30;
    self.imageView.height = SCREEN_HEIGHT / 3 * 2;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.centerX = SCREEN_WIDTH / 2;
    self.imageView.y = SCREEN_HEIGHT / 6;
    [self.view addSubview:self.imageView];
    
    
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
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(SCREEN_WIDTH / self.tabbarFilterArray.count - 20, TabbarHeight - 10);
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - TabbarHeight, SCREEN_WIDTH, TabbarHeight) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellId];
    self.collectionView.backgroundColor = HEX_RGBA(0xdddddd,0.50);
    self.collectionView.contentInset = UIEdgeInsetsMake(5, 10, 5, 10);
    self.collectionView.scrollEnabled = YES;
    [self.view addSubview:self.collectionView];
    
 
    
    self.selectFilterNameLab = [[UILabel alloc]  initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NAV_VIEW_HEIGHT + 30)];
    self.selectFilterNameLab.textColor = [UIColor whiteColor];
    self.selectFilterNameLab.backgroundColor = [UIColor clearColor];
    self.selectFilterNameLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.selectFilterNameLab];
    
    self.gestureView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, SCREEN_WIDTH, self.collectionView.y - 60)];
    
    [self.view addSubview:self.gestureView];
    
    
    //Snapseed menu
    _colorFilterValueArray = [NSMutableArray arrayWithCapacity:_colorFilterArray.count];
    CGPoint point = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    self.menu = [[SnapseedDropMenu alloc]initWithArray:self.colorFilterArray  viewCenterPoint:point inView:self.gestureView];
    self.menu.dropMenuDelegate = self;
    [self.view addSubview:self.menu];
    
    
}

- (void) initData {
    _change = YES;
    _serialQueue = dispatch_queue_create("com.gcd.concurrentQueue", DISPATCH_QUEUE_SERIAL);
    _colorFilter = [CIFilter filterWithName:@"CIColorControls"];
    [_colorFilter setDefaults];
    
    SnapseedDropMenuModel * brightModel = [[SnapseedDropMenuModel alloc]initWithTitle:@"Bright" defaultValue:0 maxValue:1 minValue:-1];
    
    SnapseedDropMenuModel * constrastModel = [[SnapseedDropMenuModel alloc]initWithTitle:@"Constrast" defaultValue:0 maxValue:4 minValue:0];
    
    SnapseedDropMenuModel * exposureModel = [[SnapseedDropMenuModel alloc]initWithTitle:@"Exposure" defaultValue:1 maxValue:4 minValue:0];
    
    SnapseedDropMenuModel * shadowModel = [[SnapseedDropMenuModel alloc]initWithTitle:@"Shadow" defaultValue:0 maxValue:1 minValue:0];
    
    SnapseedDropMenuModel * hightLightMolde = [[SnapseedDropMenuModel alloc]initWithTitle:@"HightLight" defaultValue:1 maxValue:1 minValue:0];
    
    self.colorFilterArray = @[brightModel,constrastModel,exposureModel,shadowModel,hightLightMolde];
    
    
    self.tabbarFilterArray = @[@"Gaussian",@"Old photo",@"Enlargement"];
    
    self.brighterFilter = [[GPUImageBrightnessFilter alloc] init];
    self.constrastFilter = [[GPUImageContrastFilter alloc] init];
    self.exposureFilter = [[GPUImageExposureFilter alloc] init];
    self.lightShadowFilter = [[GPUImageHighlightShadowFilter alloc] init];
    
    
    self.gpuOriginImage = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"Duck.jpg"]];
    [self.gpuOriginImage addTarget:self.brighterFilter];
    [self.gpuOriginImage addTarget:self.constrastFilter];
    [self.gpuOriginImage addTarget:self.exposureFilter];
    [self.gpuOriginImage addTarget:self.lightShadowFilter];
    
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
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self,selectorToCall, NULL);
}

#pragma mark UIImagePicker Delegate

- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        NSLog(@"Image was saved successfully.");
    } else {
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
    self.gpuOriginImage = [[GPUImagePicture alloc] initWithImage:pickerImg];
    [self.gpuOriginImage addTarget:self.brighterFilter];
    [self.gpuOriginImage addTarget:self.constrastFilter];
    [self.gpuOriginImage addTarget:self.exposureFilter];
    [self.gpuOriginImage addTarget:self.lightShadowFilter];
    self.imageView.image = pickerImg;
    
    
    //Compression Quality
//    NSData *dataEdited = UIImageJPEGRepresentation(self.imageView.image, 0.3);
    [_picker dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"Cancel");
    [_picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark CollectionView Delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.tabbarFilterArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.backgroundColor = HEX_RGBA(0x000000,0.80);
    [cell.contentView removeAllSubviews];
    UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, cell.width - 5,12)];
    lab.text = [self.tabbarFilterArray objectAtIndex:indexPath.row];
    lab.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];;
    lab.textAlignment = NSTextAlignmentLeft;
    lab.textColor = [UIColor whiteColor];
    [cell addSubview:lab];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(_change) {
        dispatch_async(_serialQueue,^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showLoadingTips];
            });
            UIImage * img = [self setFilter:(FilterType)(indexPath.row + 201)];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageView setImage:img];
                [self dismissLoadingTips];
            });
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = self.originImg;
        });
    }
    _change = !_change;
}



#pragma mark SnapseedDropMenu Delegate
- (void)snapseedDropMenu:(SnapseedDropMenu *)sender didSelectCellAtIndex:(NSInteger)index value:(CGFloat)value{
    SnapseedDropMenuModel * model = [self.colorFilterArray objectAtIndex:index];
    NSString * colorFilterName = [NSString stringWithFormat:@"%@  %.1f",model.title,value];
    self.selectFilterNameLab.text = colorFilterName;
}

- (void)snapseedDropMenu:(SnapseedDropMenu *)sender atIndex:(NSInteger)index valueDidChange:(CGFloat)value {
//    [self.imageView setImage:[self setColorFilter:value filterType:(index + 101)]];
    
    
}

- (void)snapseedDropMenu:(SnapseedDropMenu *)sender atIndex:(NSInteger)index isChanging:(CGFloat)value {
    SnapseedDropMenuModel * model = [self.colorFilterArray objectAtIndex:index];
    NSString * colorFilterName = [NSString stringWithFormat:@"%@  %.1f",model.title,value];
    self.selectFilterNameLab.text = colorFilterName;
    [self randerImageWithFilter:index value:value];
}

#pragma mark - Filter

- (void)randerImageWithFilter:(NSInteger)index value:(CGFloat)value{
    switch (index) {
        case 0: {
            _brighterFilter.brightness = value ;
            [_brighterFilter useNextFrameForImageCapture];
            [_gpuOriginImage processImage];
            _cacheImg = [_brighterFilter imageFromCurrentFramebuffer];
        }
            break;
        case 1: {
            
            _constrastFilter.contrast = value;
            [_constrastFilter useNextFrameForImageCapture];
            [_gpuOriginImage processImage];
            _cacheImg = [_constrastFilter imageFromCurrentFramebuffer];
        }
            break;
        case 2: {
            _exposureFilter.exposure = value ;
            [_exposureFilter useNextFrameForImageCapture];
            [_gpuOriginImage processImage];
            _cacheImg = [_exposureFilter imageFromCurrentFramebuffer];
        }
            break;
        case 3: {
            _lightShadowFilter.shadows = value;
            [_lightShadowFilter useNextFrameForImageCapture];
            [_gpuOriginImage processImage];
            _cacheImg = [_lightShadowFilter imageFromCurrentFramebuffer];
        } break;
        case 4: {
            _lightShadowFilter.highlights = value;
            [_lightShadowFilter useNextFrameForImageCapture];
            [_gpuOriginImage processImage];
            _cacheImg = [_lightShadowFilter imageFromCurrentFramebuffer];
        }
        default:
            break;
    }
    self.imageView.image = _cacheImg;
}

-(void)showAllFilters{
    NSArray *filterNames=[CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    for (NSString *filterName in filterNames) {
        CIFilter *filter=[CIFilter filterWithName:filterName];
        NSLog(@"\rfilter:%@\rattributes:%@",filterName,[filter attributes]);
    }
}

- (UIImage *)setColorFilter:(CGFloat)value filterType:(ColorFilterType)type{
    if(_colorFilter == nil) {
        return nil;
    }
    switch (type) {
        case SaturationFilter:
        {
            CGFloat finalValue = 1 + value / 100;
            [_colorFilter setValue:[NSNumber numberWithFloat:finalValue] forKey:@"inputSaturation"];
        }
            break;
        case BrightnessFilter:
        {
            CGFloat finalValue = value / 100;
            [_colorFilter setValue:[NSNumber numberWithFloat:finalValue] forKey:@"inputBrightness"];
        }
            break;
        case ContrastFilter:
        {
            CGFloat finalValue = 1 + value / 100;
            [_colorFilter setValue:[NSNumber numberWithFloat:finalValue] forKey:@"inputContrast"];
        }
            break;
        case LightShadow:
            break;
        default:
        {
            return nil;
        }
    }
    CIImage * inputImage;
    @autoreleasepool {
        NSData *imageData = UIImagePNGRepresentation(self.originImg);
        inputImage = [CIImage imageWithData:imageData];
        imageData = nil;
        
    }
    [_colorFilter setValue:inputImage forKey:@"inputImage"];
    return [self useFilter:_colorFilter toCreateImageWiehCIImage:inputImage];
}


- (UIImage *)setFilter :(FilterType) type{
    UIImage * resImage;
    __weak id weakSelf = self;
    @autoreleasepool {
        
        NSData *imageData = UIImagePNGRepresentation(((ViewController *)weakSelf).originImg);
        CIImage * inputImage = [CIImage imageWithData:imageData];
        CIFilter * filter;
        switch (type) {
            case GaussianBlur: {
                filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                    keysAndValues:@"inputRadius",@50,
                                                  @"inputImage",inputImage,nil];
            }
                break;
            case SepiaTone: {
                filter = [CIFilter filterWithName:@"CISepiaTone"
                                    keysAndValues:@"inputIntensity",@0.9,
                                                  @"inputImage", inputImage,nil];
            }
                break;
            case AffineTransform: {
                CGFloat width = self.imageView.image.size.width;
                CGAffineTransform trans = CGAffineTransformMake(3, 0, 0, 3, - width,  - width);
                filter = [CIFilter filterWithName:@"CIAffineTransform"
                                    keysAndValues:@"inputImage",inputImage,
                                                  @"inputTransform",[NSValue valueWithCGAffineTransform:trans],nil];
            }
                break;
            case ModTransition: {
                filter = [CIFilter filterWithName: @"CIModTransition"
                                    keysAndValues: @"inputCenter",[CIVector vectorWithX:0.5*((ViewController *)weakSelf).originImg.size.width Y:0.5 * ((ViewController *)weakSelf).originImg.size.height],
                                                   @"inputAngle", @(M_PI*0.1),
                                                   @"inputRadius", @30.0,
                                                   @"inputCompression", @10.0,
                                                   @"inputImage",inputImage,
                                                   nil];
            }
                break;
            default:
                break;
        }
        
        resImage = [self useFilter:filter toCreateImageWiehCIImage:inputImage];
        inputImage = nil;
        imageData = nil;
    }
    return resImage;
}

- (UIImage * )useFilter:(CIFilter *)filter toCreateImageWiehCIImage:(CIImage*)inputImage {
    CIContext * ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ciContext createCGImage:filter.outputImage fromRect:inputImage.extent];
    UIImage * resImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    [ciContext clearCaches];
    return resImage;
}


#pragma mark - HUD

- (void)showTextTips:(NSString *)tips {
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    [self.view addSubview:_tipHud];
    [self.view bringSubviewToFront:_tipHud];
    
    _tipHud.mode = MBProgressHUDModeText;
    _tipHud.labelText = tips;
    [_tipHud show:YES];
    [_tipHud hide:YES afterDelay:1];
}

- (void)showLoadingTips {
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    [self.view addSubview:_tipHud];
    [self.view bringSubviewToFront:_tipHud];
    
    _tipHud.labelText = nil;
    _tipHud.mode = MBProgressHUDModeIndeterminate;
    [_tipHud show:YES];
}

- (void)dismissLoadingTips {
    [_tipHud hide:YES];
}
@end
