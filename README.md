# Orb_Slam3 Ros Docker

## 镜像下载

以下操作需使用docker，如果未安装，需要先安装Docker。）

```
docker push lxzheng/orbslam3:ros-melodic
```

## 启动容器

```
docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
lxzheng/orbslam3:ros-melodic bash
```



## 软件及版本

镜像使用了以下软件

- ubuntu 18.04
- ROS Melodic
- opencv 4.4.0
- Pangolin
  - https://github.com/stevenlovegrove/Pangolin
- ORB SLAM3
  - https://github.com/UZ-SLAMLab/ORB_SLAM3


## 自己制作Docker 镜像

- 下载[opencv 4.4.0](https://github.com/opencv/opencv/archive/4.4.0.zip) ，及[ippicv_2020_lnx_intel64_20191018_general.tgz](https://github.com/opencv/opencv_3rdparty/blob/ippicv/master_20191018/ippicv/ippicv_2020_lnx_intel64_20191018_general.tgz)到本地(默认为Dockerfile上一级目录) 。由于在Dockerfile中使用copy会浪费空间，导致镜像过大，它改用启动一个python的http服务用于镜像制作过程中下载相关软件。

  * 使用方法：`./buildimage.sh <软件目录>（默认为上一给目录）`

  * 如果github代码下载出错，可自行在buildimage.sh中设置代理
  
    

## License许可协议

项目使用[GNU General Public License v3.0](LICENSE)协议发布

