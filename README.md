# VHLNavigation

微信动态模糊样式，微信红包两种导航栏样式切换，颜色过渡切换，导航栏背景图片切换，导航栏透明度切换，有无导航栏切换.

OC 版 [VHLNavigation](https://github.com/huanglins/VHLNavigation)

![微信动态模糊](https://github.com/huanglins/VHLNavigation_Swift/raw/master/screenshots/自定义View.gif)
![微信样式](https://github.com/huanglins/VHLNavigation_Swift/raw/master/screenshots/微信样式.gif)
![颜色过渡](https://github.com/huanglins/VHLNavigation_Swift/raw/master/screenshots/颜色过渡.gif)
![背景图片](https://github.com/huanglins/VHLNavigation_Swift/raw/master/screenshots/背景图片.gif)
![隐藏导航栏](https://github.com/huanglins/VHLNavigation_Swift/raw/master/screenshots/隐藏导航栏.gif)
![导航栏透明度](https://github.com/huanglins/VHLNavigation_Swift/raw/master/screenshots/透明度.gif)
![导航栏滚动](https://github.com/huanglins/VHLNavigation_Swift/raw/master/screenshots/导航栏滚动.gif)

参考学习 

[透明与半透明 NavigationBar 切换的三种方案](http://www.jianshu.com/p/e3ca1b7b6cec)

[HansNavController](https://github.com/CrazyGitter/HansNavController)

[WRNavigationBar](https://github.com/wangrui460/WRNavigationBar)

# 如何使用
手动拖入 将 `VHLNavigation` 文件夹拽入项目中

~~或者通过 pod 导入 `pod 'VHLNavigation'`~~

导入头文件：`#import "VHLNavigation.h"`


#### 相关用法
用法和 `VHLNavigation` OC 版一致

```
设置导航栏背景图片
self.vhl_navBarBackgroundImage = UIImage(named: "navbg")
设置导航栏背景颜色
self.vhl_navBarBackgroundColor = getRandomColor()
设置导航栏透明度
self.vhl_navBarBackgroundAlpha = CGFloat(arc4random()) / CGFloat(UInt32.max)
设置导航栏标题颜色
self.vhl_navBarTitleColor = getRandomColor()
设置导航栏按钮颜色
self.vhl_navBarTintColor = getRandomColor()
设置是否隐藏分割线
self.vhl_navBarShadowImageHide = false

隐藏导航栏
self.vhl_navBarHide = true
```
#### 设置为微信红包样式切换
```
self.vhl_navSwitchStyle = .fakeNavBar
```

#### 设置自定义的View (微信动态模糊样式)
```
let blurBGColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.9)

let blurEffect = UIBlurEffect(style: .light)
let bgView = UIVisualEffectView(effect: blurEffect)
bgView.backgroundColor = blurBGColor

// ** 给自定义的 View 标记tag, 如果两个 vc 的自定义view tag一样,那么不会以假导航栏样式过渡
bgView.tag = 788 //Int(arc4random())

self.vhl_navBarBackgroundView = bgView
```

## 更新


# 关于
- **blog**: https://www.vincents.cn
- **email**: gvincent@163.com
- **qq**: 2801818138


