# altStore免越狱自签名安装ipa

测试电脑是win11, 

安装的是flutter打包的无签名ipa，  
[https://github.com/AoEiuV020/FlutterDemo/releases/tag/filePicker](https://github.com/AoEiuV020/FlutterDemo/releases/tag/filePicker)

爱思靠不住，先签名再安装上闪退，

所以用altStore的altServer,

[https://altstore.io/](https://altstore.io/) 这里下载altserver,

依赖icloud但是不要自己装，打开altserver会打开浏览器下载合适的icloud,   
安装到默认目录然后不需要登录不需要自启动，

依赖itunes会自动下载，安装后有线连接手机，登录连接上后开启wifi同步，  
最后要重启电脑才能wifi连上手机，

有线连上手机后直接用altserver安装altstore,

然后在手机上打开altstore，要允许网络发现才能找到电脑的altserver,   
要开启开发者模式才能打开自签名app，

下载无签名的ipa到手机上，打开方式直接选择AltStore，  
或者直接在altstore → my apps → + 选择添加ipa，

就会自动签名安装上了，一切顺利，只要在同个wifi下，续期也正常，
