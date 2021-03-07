# altStore免越狱自签名安装ipa

测试电脑是win10, 

安装的是flutter打包的无签名ipa， [https://github.com/AoEiuV020/FlutterDemo/releases/tag/FlutterDemo-20210307140334](https://github.com/AoEiuV020/FlutterDemo/releases/tag/FlutterDemo-20210307140334)

爱思靠不住，先签名再安装上闪退，

所以用altStore的altServer,

[https://altstore.io/](https://altstore.io/) 这里下载altserver,

依赖icloud但是不要自己装，打开altserver会打开浏览器下载合适的icloud,

网上能找到AltServerPatcher.exe但这东西不行，会导致altserver下载ipa失败，provided uri invalid,

所以直接用altserver安装altstore,

然后在手机上打开altstore，要允许网络发现才能找到电脑的altserver, 

然后把要签名安装的ipa通过icloud或者爱思助手传到手机上，，
在altstore → my apps → + 选择添加ipa，或者直接手机上下载用altstore打开，

就会自动签名安装上了，一切顺利，只要在同个wifi下，续期也正常，
