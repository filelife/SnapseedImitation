# SnapseedImitation
## App of imitation SnapSeed.
Base on GPUImage framework.

The use of dropmenu is like snapseed.

Only update some filters.

Repository is in the update.

UI:
 
<img src="http://p1.bpimg.com/567571/f1e3172f0464087d.png" width = "50%"/>

Edit Photo

<img src="http://i1.piimg.com/567571/084d868762e89302.png" width = "50%"/>

Gaussian Blur filter:

<img src="http://p1.bpimg.com/567571/873abae03f6b9d44.png" width = "30%"/>

Old photo filter:

<img src="http://p1.bpimg.com/567571/7371f08323ea477d.png" width = "30%"/>

## 附上个人整理的学习文档
# 打造自己美图软件：仿制Snapseed
######

###### 作者：葛佳欣  

###### 
### 前言
##### &emsp;&emsp;对于iOS开发者而言，想要打造一款美图App，最佳首选的开源框架莫过于GPUImage。它内嵌了上百种图像滤镜，能够满足市面上的一切美颜开发方案。同时也具备了实时美颜的功能。通过这样强大的开源框架，我们可以在其上层开发属于我们自己的美图应用。SnapseedImitation 是以Snapseed为原型，利用GPUImage框架开发的图像处理软件，目前仍在持续更新中，欢迎交流。联系QQ：455587429；WeChat：13559194285
###### SnapseedImitation 
###### Github地址：https://github.com/filelife/SnapseedImitation.git
##

### 0.拉取GPUImage源码
###### &emsp;&emsp;Checkout From Github:https://github.com/BradLarson/GPUImage.git
##
### 1. 准备需要的头文件
###### &emsp;&emsp;  这步骤比较简单，将需要的头文件从GPUImage的工程目录中提取出来即可。
##
### 2. 准备支持多种框架的.a文件

#### 2.1 静态库编方法：
###### &emsp;&emsp;官方文档：If you don't want to include the project as a dependency in your application's Xcode project, you can build a universal static library for the iOS Simulator or device. To do this, run build.sh at the command line. The resulting library and header files will be located at build/Release-iphone. You may also change the version of the iOS SDK by changing the IOSSDK_VER variable in build.sh (all available versions can be found using xcodebuild -showsdks).
###### 

#### 2.2 实际操作：

##### 2.2.1 选择工程 
###### &emsp;&emsp;如果官方文档提供的build.sh文件报错，我们也可选择使用工程进行静态库编译。仅需要开发iOS app，则选择GPUImage.xcode 进行编译即可。
 
###### ![](http://p1.bqimg.com/567571/cf499291b548c6fb.png)
###### &emsp;&emsp;编译后，每次编译产出的静态库仅支持一种框架。用iphone7模拟器编译出来的静态库在iphone5模拟器下就会报错（如下图）：
###### ![](http://p1.bqimg.com/567571/1ce09f5861d05bd2.png)
###### &emsp;&emsp;为了解决这个问题，我们需要编译多种框架的静态库，并将其合并成一个最终静态库，以保证未来在模拟器或是真机调试过程中都能正常编译。
##### 2.2.2 编译 
###### &emsp;&emsp;选定编译的target，Build。
###### ![](http://p1.bpimg.com/567571/f267b61f0f341ff0.png)
 
##### 2.2.3 查看静态库支持框架类型
###### &emsp;&emsp;编译后，在GPUImage的根目录下：build->Debug-iphonesimulator->libGPUImage.a  此时通过命令: 
        lipo -info libGPUImage.a  
###### 查看该静态库所支持的框架类型。如下图，通过iphone7模拟器编译出来的静态库，支持x86_64框架。
###### ![](http://i1.piimg.com/567571/3ea4173bd7457535.png)
###### 
###### &emsp;&emsp;注：选择模拟器时注意，通过iphone7等较新的模拟器编译出来的框架是不支持==i386==的，仅支持==x86_64==，在后续开发中会编译报错，需要使用iphone5模拟器进行编译，才能产出architecture为i386的静态库。
###### ![](http://p1.bpimg.com/567571/64fdac2393b63ce1.png)
##### 2.2.4 合并静态库
###### &emsp;&emsp;对上面两种模拟器，iphone7和iphone5编译出来的产物重新命名，然后在同一级目录下使用：
        lipo -create libGPUImagei386.a libGPUImagex86_64.a -output libGPUImageMerge.a
        
![](http://p1.bqimg.com/567571/3bee767e4d6bcf9a.png)
###### &emsp;&emsp;完成这一步后，我们便可以对我们所需要的静态库进行合并。如果期望支持真机环境，则需要支持：==armv7 i386 x86_64 arm64==
##

### 3. 创建自己的GPUImage  Demo工程
#### 3.1 导入静态库及头文件
###### &emsp;&emsp;创建一个简单的iOS应用工程后，我们将头文件和静态库.a 文件拉入工程中。
###### &emsp;&emsp;在Target的Bulid Phases Link Binary With Libraries中
![](http://i1.piimg.com/567571/274fa0bd2ad54458.png)
###### &emsp;&emsp;improt 导入GPUImage.h后编译即可。
![](http://i1.piimg.com/567571/15c096ddb7f9cf19.png)

## 

### 4.GPUImage
#### 4.1 GPUImage简单上手
###### 通过GPUImagePicture获取待编辑图像，再经过GPUImageFilter渲染后产出一帧frame，经由消息管道通知后，便可在GPUImageView显示编辑后的图片，或者我们可以通过GPUImageFilter直接导出渲染后的UIImage。
```
graph LR
GPUImageInput-->GPUImageFilter;
GPUImageFilter-->GPUImageOutput;
```
###### 以拉升变形滤镜为例：

    //@拉升变形镜滤镜
    //创造输入源
    GPUImagePicture * gpupicture = [[GPUImagePicture alloc]initWithImage:[UIImage imageNamed:@"Duck.jpg"]];
    //创建滤镜
    PUImageStretchDistortionFilter * stretchDistortionFilter = [GPUImageStretchDistortionFilter new];
    //为滤镜赋值
    stretchDistortionFilter.center = CGPointMake(0.2, 0.2);
    //将输入源和滤镜绑定
    [gpupicture addTarget:stretchDistortionFilter];
    //为原图附上滤镜效果
    [gpupicture processImage];
    //滤镜收到原图产生的一个frame，并将它作为自己的当前图像缓存
    [stretchDistortionFilter useNextFrameForImageCapture];
    //通过滤镜，获取当前的图像。
    UIImage *image = [stretchDistortionFilter imageFromCurrentFramebuffer];
###### 图像拉升变形前后对比 :
![](http://i1.piimg.com/567571/09cbdd9243e6da17.png)

#### 4.2 复合滤镜
###### 开发过程中，必然会有多种滤镜复合的需求，例如一个可以变化亮度、对比度、曝光的图像调节程序。但是依照上一个示例，我们每添加一种滤镜，便会代替之前的滤镜效果。如果每次处理的都是上一次的filter导出的UIImage图片的话，又会导致无法恢复到原图样子，导致失真。（可参考在绘画板中，把图片缩小到最小，再放大，图片变成为了一个像素块。）

###### 这时候，我们需要一个很好用的类：==GPUImageFilterPipeline==
###### GPUImageFilterPipeline可以将多个滤镜进行复合，并且在多次处理后，仍然能够恢复成为原图不失真。

###### 仍然以拉升变形和卡通描边效果为例 ：

    //获取原图
    GPUImagePicture * gpupicture = [[GPUImagePicture alloc]initWithImage:[UIImage imageNamed:@"Duck.jpg"]];
    //输出图像的View
    GPUImageView * gpuimageView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 60, 320, 320)];
    [self.view addSubview:gpuimageView];
    //卡通描边滤镜
    GPUImageToonFilter * toonFilter = [GPUImageToonFilter new];
    toonFilter.threshold = 0.1;
    //拉升变形滤镜
    GPUImageStretchDistortionFilter * stretchDistortionFilter = [GPUImageStretchDistortionFilter new];
    stretchDistortionFilter.center = CGPointMake(0.5, 0.5);
    //将滤镜组成数组
    NSArray * filters = @[toonFilter,stretchDistortionFilter];
    //通过pipline，将输入源，输出，滤镜，三方绑定
    GPUImageFilterPipeline * pipLine = [[GPUImageFilterPipeline alloc]initWithOrderedFilters:filters input:self.gpupicture output:self.gpuimageView];
    //绘制产出最终带有复合滤镜的图像。
    [self.gpupicture processImage];
    //获取产出的UIImage图像
    //此时调用useNextFrameForImageCapture的可以是任一在数组中的Filter。
    [stretchDistortionFilter useNextFrameForImageCapture];
    UIImage * image = [self.pipLine currentFilteredFrame];

![](http://i1.piimg.com/567571/679834edceb5cc12.png)
###### 
#### 4.3 复合滤镜的应用
###### 基于GPUImage框架，我为其添加了一套了Snapseed的UI，通过手势识别方案对图像滤镜进行调节拖控。
![](http://i1.piimg.com/567571/084d868762e89302.png)
## 
