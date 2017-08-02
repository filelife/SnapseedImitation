# SnapseedImitation
## App of imitation SnapSeed.
### 0.Repository introduction.
Base on GPUImage framework,support some photo edit operation.

The same drop menu user interface as Snapseed.

Can beauty user's photograph with different filters.

UI:
 
<img src="http://p1.bpimg.com/567571/f1e3172f0464087d.png" width = "50%"/>

Edit Photo

<img src="http://i1.piimg.com/567571/084d868762e89302.png" width = "50%"/>

Gaussian Blur filter:

<img src="http://p1.bpimg.com/567571/873abae03f6b9d44.png" width = "30%"/>

Old photo filter:

<img src="http://p1.bpimg.com/567571/7371f08323ea477d.png" width = "30%"/>

### 1.Import GPUImage
CocoaPods
```
pod 'GPUImage'
```

## 

### 2.Useing GPUImage
### 1.Process description
###### Use GPUImagePicture category to get photo.Render a frame with filters by GPUImageFilter category.Notice by pipline when it render finish.Finally we can show edited photo in GPUImageView,or maybe we can get photo by GPUImageFilter.

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
![](http://i1.piimg.com/567571/09cbdd9243e6da17.png)

#### 2. Multiple Filter
###### Users have different filter options when editing pictures.This may requires control of brightness, contrast, and exposure.Every time we add a filter, the picture renders once, which means we lose the original image if we render twice. This is why we need to do multiple filters but make it render for only one time.

###### All we need is GPUImageFilterPipeline category.
###### GPUImageFilterPipeline can import multi filters but rendering once. After many times of rendering,we still can get origin picture.

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
![](http://i1.piimg.com/567571/679834edceb5cc12.png)
###### 
#### 3.Multiple Filter use in the app demo.
###### With the drop menu,user can edit photo with different filters,and the
![](http://i1.piimg.com/567571/084d868762e89302.png)
## 
