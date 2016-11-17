---
title: Mac 环境下配置树莓派
date: 2015-10-17 14:14:46
categories: 工具
tags: [树莓派]
---

Raspberry Pi(中文名为“树莓派”,简写为RPi，(或者RasPi / RPI)。是为学生计算机编程教育而设计，只有信用卡大小的微型电脑，其系统基于Linux。自问世以来，受众多计算机发烧友和创客的追捧，曾经一“派”难求。别看其外表“娇小”，内“心”却很强大，视频、音频等功能通通皆有，可谓是“麻雀虽小，五脏俱全”。
<!--more-->
##### 系统安装
###### 下载系统镜像

访问树莓派官方网站 <https://www.raspberrypi.org/downloads> 下载 Raspbian 镜像

###### 安装镜像
Ray Vijoen 写了一个实用的脚本使得在 Mac 上制作一张操作系统 SD 卡非常简单。它是一个 Shell 脚本包含了创建操作系统 SD 卡的所有步骤，包括格式化。但你得使用命令行执行它。（自己格式化的话一定要选择FAT格式）

**步骤1.**

将 <https://github.com/RayViljoen/Raspberry-PI-SD-Installer-OS-X> 下载到本地

**步骤2.**

将 Raspbian 镜像移动到 ”Raspberry-PI-SD-Installer-OS-X” 文件夹下。

**步骤3.**

打开终端应用，cd 到 Raspberry-PI-SD-Installer-OS-X 文件夹路径下。

**步骤4.**

拔出所有插入到电脑上的其他存储设备。这将会使你更容易的认出你的SD卡。

插入SD卡，注意所有的数据将会被擦除。

**步骤5.**

通过下面的命令运行 Pi Installer:

```
sudo ./install Raspbian.img
```
“Raspbian.img” 是你要安装的发行版的镜像文件名。

输入你的 Mac 密码，终端会提示你选择一个路径

**步骤6.**

输入你的 SD 卡旁边的编号。确保输入是正确的，因为你选择的驱动器将会被擦除。

接下来你只需要等待所有镜像文件安装完成。这将会花费几分钟的时间。你可以通过按下 Ctrl+T 来查看进度。

安装完成时你会看到 "All Done!"，表示你的系统 SD 卡已经可以使用了。


##### 测试

将 SD 卡插入到小派上，然后连接一个键盘到 USB 口上，连接一个 NTSC/PAL 电视到 AV 输出或者 HDMI 显示器到 HDMI 接口上。然后通过一条 Micro USB 线另一端连接电脑或者充电器插头为小派供电。
接入电源后可以看到 PWD 指示灯红色常亮，表示供电成功；ACT 指示灯绿色闪烁表示 SD 卡正常活动（类似电脑的硬盘灯）；

如果你看到一个 Adafruit/Raspberry 的 logo 出现在显示器左上角，并有大量的文本输出，表示系统安装成功了。

##### 远程 SSH 访问

使用网线将树莓派连接至路由器，LNK 指示灯亮表示网络连接成功。

查询 IP，可以在树莓派的终端上输入命令 “hostname -I”。另外，如果你运行的树莓派没有显示器，你可以查看你的路由器上的设备列表。

打开 Mac 终端

```
ssh pi@<IP>
```

如果你接收到一个 connection timed out（连接超时）的错误，很有可能是你输错了你的树莓派 IP。

如果连接成功，你将会看到一个安全验证的警告。输入 yes 继续，你只会在第一次连接的时候看到这个警告。

有时候你的树莓派可能会占用了你的计算机以前曾经连接过（也有可能是在其它网络中连接过）的 IP 地址，你将会得到一个警告并要求清空你的已知设备列表。根据指示操作，然后再次使用 ssh 命令连接应该就能成功连接上。

下一步，你将会被提示输入 pi 用户的密码进行登录，Raspbian 默认的密码是 raspberry。现在，你应该能够看到树莓派的提示符，它代表了在树莓派上找到的一个用户。

```
pi@raspberrypi ~ $
```

如果你在树莓派上添加了其他用户，你也可以使用同样的方式连接，只需要将用户名替换，例如other@192.168.3.2

现在你已经远程登录了树莓派，可以直接在上面执行命令。
##### 安装 VIM
树莓派默认的 vi 编辑器比较怪异，用起来很不习惯，推荐安装 vim 编辑器

首先删除默认的 vi 编辑器

```
sudo apt-get remove vim-common
```

然后重新安装 vim

```
sudo apt-get install vim
```

##### 与 MacBook 直接连接
将网线与 MacBook 的 USB 网络转接口连接

打开系统偏好 -> 共享，勾选 Thunderbolt 网桥及 USB Ethernet，选择共享来源，打开互联网共享。

![互联网共享](http://7lrzeu.com1.z0.glb.clouddn.com/Mac%E7%BD%91%E7%BB%9C%E5%85%B1%E4%BA%AB.jpeg)

这样树莓派就可以直接访问 MacBook 的网络了。

##### 树莓派设置静态 IP
树莓派的 IP 是有路由器自动分配的，每次连入网络都有可能产生变化，有些不方便。为了达到脱离显示器使用的目的，可以给树莓派设置一个静态 IP，方便使用 SSH 连接树莓派。

**步骤1.**

**通过 SSH 连接到树莓派**

**步骤2.**

**检查现有设置**

```
cat /etc/network/interfaces
```

内容如下：

```
auto lo
iface lo inet loopback

auto eth0
allow-hotplug eth0
iface eth0 inet manual

auto wlan0
allow-hotplug wlan0
iface wlan0 inet manual
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

auto wlan1
allow-hotplug wlan1
iface wlan1 inet manual
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
```
其中，eth0 为网卡 1，我们修改的就是这个配置。

**步骤3.**

**收集必要信息**

先输入ifconfig命令来获取路由器信息

```
ifconfig
```
![ifconfig](http://7lrzeu.com1.z0.glb.clouddn.com/pi_ifconfig.jpeg)

记录 inet addr，Mask 的值。

然后利用netstat命令获取网关信息

```
netstat -nr
```
![netstat](http://7lrzeu.com1.z0.glb.clouddn.com/pi_netstat.jpeg)

记录 Gateway 的值。

**步骤4.**

**修改网络设置**

```
vim /etc/network/interfaces
```
把其中的 `iface eth0 inet manual` 修改为 `iface eth0 inet static`，然后换行输入

address &lowast;.&lowast;.&lowast;.&lowast;（你想分配给树莓派的 IP 地址，如果你的网关地址是 192.168.3.1，那么你只能设置为 192.168.3.*）

netmask &lowast;.&lowast;.&lowast;.&lowast;（Mask 的值）

gateway &lowast;.&lowast;.&lowast;.&lowast;（Gateway 的值）

输入完毕后 :wq 保存并退出编辑器

我的 eth0 配置修改后如下：

```
auto eth0
allow-hotplug eth0
iface eth0 inet static
address 192.168.3.2
netmask 255.255.255.0
gateway 192.168.3.1
```

至此，树莓派的IP已经更改为静态 IP，重启机器

```
sudo reboot
```
