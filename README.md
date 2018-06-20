# SnapseedImitation
## App of imitation SnapSeed.
### 0.Repository introduction.
Base on GPUImage framework,support some picture editing operation.

The same drop menu user interface as Snapseed.

Can beauty user's photograph with different filters.



### 1.Import GPUImage
CocoaPods
```
pod 'GPUImage'
```

## 

### 2.Useing GPUImage
### 1.Process description
###### Use GPUImagePicture category to get picture.Render a frame with filters by GPUImageFilter category.Notice by pipline when it render finish.Finally we can show edited photo in GPUImageView,or maybe we can get picture by GPUImageFilter.

```
graph LR
GPUImageInput-->GPUImageFilter;
GPUImageFilter-->GPUImageOutput;
```
###### Example：
```
    //@Stretch filter
    //Input photo.
    GPUImagePicture * gpupicture = [[GPUImagePicture alloc]initWithImage:[UIImage imageNamed:@"Duck.jpg"]];
    //Init Filter
    PUImageStretchDistortionFilter * stretchDistortionFilter = [GPUImageStretchDistortionFilter new];
    //Set filter parama
    stretchDistortionFilter.center = CGPointMake(0.2, 0.2);
    //Binding it.
    [gpupicture addTarget:stretchDistortionFilter];
    //Process photo
    [gpupicture processImage];
    //Let filter get next frame(That's the final frame.)
    [stretchDistortionFilter useNextFrameForImageCapture];
    //Get photo.
    UIImage *image = [stretchDistortionFilter imageFromCurrentFramebuffer];
```
###### Impression comparison  :
![](https://upload-images.jianshu.io/upload_images/1647887-507c937ab8882497.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)

#### 2. Multiple Filter
###### Users have different filter options when editing pictures.This may requires control of brightness, contrast, and exposure.Every time we add a filter, the picture renders once, which means we lose the original image if we render twice. This is why we need to do multiple filters but make it render for only one time.

###### All we need is GPUImageFilterPipeline category.
###### GPUImageFilterPipeline can do multi filters but only one-time rendering . After many times of adding filters,we can still get origin picture.

###### Example：
```
    //get origin
    GPUImagePicture * gpupicture = [[GPUImagePicture alloc]initWithImage:[UIImage imageNamed:@"Duck.jpg"]];
    GPUImageView * gpuimageView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 60, 320, 320)];
    [self.view addSubview:gpuimageView];
    //ToonFilter
    GPUImageToonFilter * toonFilter = [GPUImageToonFilter new];
    toonFilter.threshold = 0.1;
    //StreStretchDistortionFilter
    GPUImageStretchDistortionFilter * stretchDistortionFilter = [GPUImageStretchDistortionFilter new];
    stretchDistortionFilter.center = CGPointMake(0.5, 0.5);
    // Get the combination array.
    NSArray * filters = @[toonFilter,stretchDistortionFilter];
    //binding pipline
    GPUImageFilterPipeline * pipLine = [[GPUImageFilterPipeline alloc]initWithOrderedFilters:filters input:self.gpupicture output:self.gpuimageView];
    //process
    [self.gpupicture processImage];
    [stretchDistortionFilter useNextFrameForImageCapture];
    UIImage * image = [self.pipLine currentFilteredFrame];
```
![](https://upload-images.jianshu.io/upload_images/1647887-2ed90da3be4de5b5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)
###### 
#### 3.Multiple Filter use in the app demo.
###### With the drop menu,user can edit photo with different filters,and the
![](https://upload-images.jianshu.io/upload_images/1647887-5fa6719ff2f7ca52.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/414)
## 
