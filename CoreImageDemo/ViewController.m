//
//  ViewController.m
//  CoreImageDemo
//
//  Created by Gejiaxin on 16/12/25.
//  Copyright © 2016年 VincentJac. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>
#import "MBProgressHUD.h"
#import "SnapseedDropMenu.h"
#import <math.h>
#define FilterCellWidth 120
#define MoveZoom 20
#define TabbarHeight 40
NSString * const cellId = @"FilterCell";

typedef NS_ENUM(NSInteger, ColorFilterType) {
    SaturationFilter = 101,
    BrightnessFilter,
    ContrastFilter
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
@property (nonatomic, strong) UIImage * orignImg;
@property (nonatomic, strong) UIView * gestureView;
@property (nonatomic, strong) MBProgressHUD *tipHud;
@property (nonatomic, strong) UIScrollView * tabScrollView;
@property (nonatomic, strong) SnapseedDropMenu * menu;
@property (nonatomic, strong) UILabel * selectFilterNameLab;
@property (nonatomic, copy) NSArray * colorFilterArray;
@property (nonatomic, copy) NSArray * tabbarFilterArray;
@property (nonatomic, strong) NSMutableArray<NSNumber *> * colorFilterValueArray;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UIButton * leftbtn;
@property (nonatomic, strong) UIButton * rightbtn;
@property (nonatomic, strong) UIImagePickerController *picker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initUI];

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
    
    self.imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Duck.jpg"]];
    self.imageView.width = SCREEN_WIDTH - 30;
    self.imageView.height = SCREEN_HEIGHT / 3 * 2;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.centerX = SCREEN_WIDTH / 2;
    self.imageView.y = SCREEN_HEIGHT / 6;
    [self.view addSubview:self.imageView];
    
    
    self.leftbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftbtn.frame = CGRectMake(0, 30, 100, 30);
    [self.leftbtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.leftbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.leftbtn addTarget:self action:@selector(saveImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leftbtn];
    
    self.rightbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightbtn.frame = CGRectMake(SCREEN_WIDTH - 100, 30, 100, 30);
    [self.rightbtn setTitle:@"打开" forState:UIControlStateNormal];
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
    
    self.colorFilterArray = @[@"饱和度",@"亮  度",@"对比度"];
    self.tabbarFilterArray = @[@"高斯模糊",@"对比色",@"放大一倍"];
}

#pragma mark button action block
- (void)openAlbum:(UIButton *)sender {
    self.picker = [[UIImagePickerController alloc] init];
    [self settingGeneralProperty];
    [self presentViewController:self.picker animated:YES completion:nil];

}

- (void)saveImage:(UIButton *)sender {

}

#pragma mark UIImagePicker Delegate
- (void)settingGeneralProperty {
    /**
        *  图片源, 运行相关接口前需要指明源类型.必须有效,否则抛出异常. picker已经显示的时候改变这个值,picker会相应改变来适应.
         UIImagePickerControllerSourceTypePhotoLibrary ,//来自图库
         UIImagePickerControllerSourceTypeCamera ,//来自相机
         UIImagePickerControllerSourceTypeSavedPhotosAlbum //来自相册
         */
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // 指示picker中显示的媒体类型.设置每种类型之前应用availableMediaTypesForSourceType:检查一下.如果为空或者array中类型都不可用,会发生异常.默认 kUTTypeImage, 只能显示图片.
    _picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];

    //是否允许编辑,默认 NO
    _picker.allowsEditing = YES;
    
    //是否支持某种图片源
//    BOOL isAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    //支持某种图片源的媒体类型
//    NSArray *sourceArr = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    _picker.delegate = self;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"已经完成");
    /*
         info 中的 key 对应的内容
         UIImagePickerControllerMediaType       //用户选择的媒体类型
         UIImagePickerControllerOriginalImage   //原始图片
         UIImagePickerControllerEditedImage     //修改后的图片
         UIImagePickerControllerCropRect        //裁剪尺寸
         UIImagePickerControllerMediaURL        //媒体的URL
         UIImagePickerControllerReferenceURL    //原始的URL
         UIImagePickerControllerMediaMetadata   //从相机获取的数据源
         UIImagePickerControllerLivePhoto       // a PHLivePhoto
     */
    UIImage * pickerImg = [info objectForKey:UIImagePickerControllerEditedImage];
    self.orignImg = pickerImg;
    self.imageView.image = pickerImg;
    [_picker dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"已经取消");
    [_picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark CollectionView Delegate
//返回分区个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
//返回每个分区的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.tabbarFilterArray.count;
}
//返回每个item
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
            self.imageView.image = self.orignImg;
        });
    }
    _change = !_change;
}



#pragma mark SnapseedDropMenu Delegate
- (void)snapseedDropMenu:(SnapseedDropMenu *)sender didSelectCellAtIndex:(NSInteger)index value:(CGFloat)value{
    NSString * colorFilterName = [NSString stringWithFormat:@"%@  %.f",[self.colorFilterArray objectAtIndex:index],value];
    self.selectFilterNameLab.text = colorFilterName;
}

- (void)snapseedDropMenu:(SnapseedDropMenu *)sender atIndex:(NSInteger)index valueDidChange:(CGFloat)value {
    [self.imageView setImage:[self setColorFilter:value filterType:(index + 101)]];
}

- (void)snapseedDropMenu:(SnapseedDropMenu *)sender atIndex:(NSInteger)index isChanging:(CGFloat)value {
    NSString * colorFilterName = [NSString stringWithFormat:@"%@  %.f",[self.colorFilterArray objectAtIndex:index],value];
    self.selectFilterNameLab.text = colorFilterName;
}

#pragma mark - Filter

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
        default:
        {
            return nil;
        }
    }
    CIImage * inputImage;
    @autoreleasepool {
        NSData *imageData = UIImagePNGRepresentation(self.orignImg);
        inputImage = [CIImage imageWithData:imageData];
        imageData = nil;
        
    }
    [_colorFilter setValue:inputImage forKey:@"inputImage"];
    return [self useFilter:_colorFilter toCreateImageWiehCIImage:inputImage];
}

//滤镜相关代码

- (UIImage *)setFilter :(FilterType) type{
    UIImage * resImage;
    __weak id weakSelf = self;
    @autoreleasepool {
        
        NSData *imageData = UIImagePNGRepresentation(((ViewController *)weakSelf).orignImg);
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
                                    keysAndValues: @"inputCenter",[CIVector vectorWithX:0.5*self.orignImg.size.width Y:0.5 * self.orignImg.size.height],
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


/*
 * 绘制
 */
- (UIImage * )useFilter:(CIFilter *)filter toCreateImageWiehCIImage:(CIImage*)inputImage {
    CIContext * ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ciContext createCGImage:filter.outputImage fromRect:inputImage.extent];
    UIImage * resImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);//释放CGImage对象
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
