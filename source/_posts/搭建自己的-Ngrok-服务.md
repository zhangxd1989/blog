---
title: 搭建自己的 Ngrok 服务
date: 2015-11-17 12:00:17
tags:
---

## 简介
作为一个Web开发者，我们有时候会需要临时地将一个本地的Web网站部署到外网，以供他人体验评价或协助调试，例如微信应用调试、支付宝接口调试等。这个时候，一个叫ngrok的神器可能会帮到你，它提供了一个能够在公网安全访问内网Web主机的工具，能捕获所有HTTP请求的内容，也支持TCP端口映射，支持Linux、Windows、Mac OS X 等平台。
<!--more-->
## Centos 安装 GO 语言环境

1. 建议使用源码方式安装:

   ```
   wget https://storage.googleapis.com/golang/go1.4.1.linux-amd64.tar.gz
   tar -C /usr/local -xzf go1.4.1.linux-amd64.tar.gz
   mkdir $HOME/go
   echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
   echo 'export GOPATH=$HOME/go' >> ~/.bashrc
   echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> ~/.bashrc
   source $HOME/.bashrc
   ```
2. 安装 go get 工具:

   ```
   yum install mercurial git bzr subversion
   ```
   **参考 *[海运的博客](http://www.haiyun.me/archives/1009.html)* **

## 域名解析设置
1. 将 tunnel.zhangxd.cn 指向 ngrok 服务器
如果未将此域名指向服务器，启动客户端时会报 Unknown Host 错误
2. 将 *.tunnel.zhangxd.cn 指向 ngrok 服务器

## 自编译 ngrok 服务器
1. 下载 ngrok 源码:

	```
	cd /usr/local/
	git clone https://github.com/inconshreveable/ngrok.git
	export GOPATH=/usr/local/ngrok/
	export NGROK_DOMAIN="tunnel.zhangxd.cn"
	```

2. 生成自签名 SSL 证书， ngrok 为 SSL 加密链接:

	```
	cd ngrok
	openssl genrsa -out rootCA.key 2048
	openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$NGROK_DOMAIN" -days 5000 -out rootCA.pem
	openssl genrsa -out server.key 2048
	openssl req -new -key server.key -subj "/CN=$NGROK_DOMAIN" -out server.csr
	openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 5000
	```
3. 在软件源代码目录下面会生成一些证书文件，把这些文件拷贝到指定位置

   ```
   cp rootCA.pem assets/client/tls/ngrokroot.crt
   cp server.crt assets/server/tls/snakeoil.crt
   cp server.key assets/server/tls/snakeoil.key
   ```
4. 编译服务端

	`指定编译环境变量，如何确认GOOS和GOARCH，可以通过go env来查看`

	```
	cd /usr/local/go/src
	GOOS=linux GOARCH=amd64 ./make.bash
	cd /usr/local/ngrok/
	GOOS=linux GOARCH=amd64 make release-server
	```
	国内服务器（我使用的阿里ECS北京节点）由于 GFW 原因，获取 log4go 时会报如下错误:

	```
	package code.google.com/p/log4go: Get https://code.google.com/p/log4go/source/checkout?repo=: dial tcp 216.58.221.46:443: i/o timeout
	make: *** [deps] 错误 1
	```
	修改代码src/ngrok/log/logger.go

	把地址code.google.com/p/log4go

	改为github.com/keepeye/log4go
5. 编译客户端 (使用相同环境下编译)

	`我的是 Mac OS 64 位操作系统，所以我的是下面的命令`

	```
	cd /usr/local/go/src
	GOOS=darwin GOARCH=amd64 ./make.bash
	cd /usr/local/ngrok/
	GOOS=darwin GOARCH=amd64 make release-client
	```
	`Windows 的客户端编译`

	```
	cd /usr/local/go/src
	GOOS=windows GOARCH=amd64 ./make.bash
	cd /usr/local/ngrok/
	GOOS=windows GOARCH=amd64 make release-client
	```

## 调试
1. 启动ngrokd

	由于我的服务器80端口被nginx占用，这里暂且使用8000端口启动

	```
	/usr/local/ngrok/bin/ngrokd -domain="$NGROK_DOMAIN" -httpAddr=":8000"
	```
2. 客户端创建文件 ngrok.cfg, 配置如下:

	```
	server_addr: "tunnel.zhangxd.cn:4443"
	trust_host_root_certs: false
	```

3. 启动客户端

	如果连接失败可以开启 log 查看错误日志

	```
	./ngrok -config=./ngrok.cfg [-log=./ngrok.log] -subdomain=test 8080
	```
	启动成功效果如下：

	![启动成功](http://7lrzeu.com1.z0.glb.clouddn.com/ngrok_success.png)

	连接成功后可以通过 http://127.0.0.1:4040 查看请求信息
4. 由于微信开发需要使用 80 端口，所以这里需要使用 nginx 对 ngrok 域名进行端口转发，我的配置如下:

	```
	upstream nodejs {
		server 127.0.0.1:8000;
		keepalive 64;
	}

	server
		{
			listen 80;
			#listen [::]:80;
			server_name *.tunnel.zhangxd.cn;

			access_log  /home/wwwlogs/tunnel.access.log  access;
			location / {
            	proxy_set_header X-Real-IP $remote_addr;
            	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            	proxy_set_header Host  $http_host:8000;
            	proxy_set_header X-Nginx-Proxy true;
            	proxy_set_header Connection "";
            	proxy_pass      http://nodejs;
			}
    	}
	```

## 参考

【1】<http://tonybai.com/2015/03/14/selfhost-ngrok-service/>

【2】<http://www.sunnyos.com/article-show-48.html>

【3】<http://www.haiyun.me/archives/1012.html>
