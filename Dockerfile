FROM ros:melodic-ros-base-bionic
LABEL maintainer="Lingxiang Zheng<lxzheng@xmu.edu.cn>"

ARG cn_repo=ftp.sjtu.edu.cn
ARG py_repo=https://mirrors.sjtug.sjtu.edu.cn/pypi/web/simple
ARG installer_url=https://github.com/opencv/opencv/archive/
ARG git_proxy=socks5://127.0.0.1:1080
ARG LOCAL_BUILD=false

RUN if [ "$LOCAL_BUILD " = "true " ];then \
	sed -i s@/archive.ubuntu.com/@/${cn_repo}/@g /etc/apt/sources.list 	&& \
    	sed -i s@/security.ubuntu.com/@/${cn_repo}/@g /etc/apt/sources.list	&& \
	sudo sh -c '. /etc/lsb-release && echo \
	"deb http://mirrors.tuna.tsinghua.edu.cn/ros/ubuntu/ $DISTRIB_CODENAME main" \
	   > /etc/apt/sources.list.d/ros-latest.list'				&& \
        apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80'     		   \
	     --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654;  		   \
    fi	&& \
    apt update && apt upgrade -y && apt install -y 		\
        vim zip unzip wget git cmake libeigen3-dev libboost-dev \
        libglew-dev libssl-dev libboost-all-dev libgtk2.0-dev	\
        libsuitesparse-dev python3-pip python-pip		\
	ros-melodic-pcl-ros ros-melodic-image-transport 	\
	ros-melodic-cv-bridge ros-melodic-pcl-conversions	\
	ros-melodic-eigen-conversions ros-melodic-tf-conversions\
 	ros-melodic-random-numbers			     && \
     apt clean 						     && \
     rm -rf /var/lib/apt/lists/*

RUN  pip3 install -U pip --no-cache-dir			     && \
     pip3 config set --global global.index-url ${py_repo}    &&	\
     pip3 config set --global global.trusted-host ${py_repo} &&	\
     pip3 install --no-cache-dir scipy numpy opencv-python 	\
	  numpy-quaternion 				    

RUN pip2 install -U pip --no-cache-dir                       && \
    pip2 install --no-cache-dir scipy numpy 			\
	 opencv-python==4.2.0.32 numpy-quaternion

WORKDIR /home

# OpenCV
ARG OPENCV_VERSION=4.4.0
RUN set -x && \
  wget -q ${installer_url}/${OPENCV_VERSION}.zip && \
  unzip -q ${OPENCV_VERSION}.zip 		 && \
  rm -rf ${OPENCV_VERSION}.zip 			 && \
  cd opencv-${OPENCV_VERSION} 			 && \
  mkdir -p build 				 && \
  cd build 					 && \
  cmake 					    \
    -DCMAKE_BUILD_TYPE=Release -DBUILD_DOCS=OFF     \
    -DBUILD_EXAMPLES=OFF     -DBUILD_JASPER=OFF     \
    -DBUILD_OPENEXR=OFF      -DBUILD_PERF_TESTS=OFF \
    -DBUILD_TESTS=OFF 	     -DBUILD_opencv_apps=OFF\
    -DBUILD_opencv_dnn=OFF   -DBUILD_opencv_ml=OFF  \
    -DBUILD_opencv_python_bindings_generator=OFF    \
    -DENABLE_CXX11=ON 	     -DENABLE_FAST_MATH=ON  \
    -DWITH_EIGEN=ON -DWITH_FFMPEG=ON -DWITH_OPENMP=ON \
    -DOPENCV_ENABLE_NONFREE=ON			    \
    -DOPENCV_IPPICV_URL=${installer_url}/	    \
    .. && \
  make -j${NUM_THREADS} && \
  make install && \
  ldconfig && \
  cd ../.. && \
  rm -rf opencv-${OPENCV_VERSION}


# Pangolin
RUN set -x && \
  git config --global http.proxy ${git_proxy}  && \
  git config --global https.proxy ${git_proxy}  && \
  git clone https://github.com/stevenlovegrove/Pangolin.git && \
  cd Pangolin && \
  mkdir -p build && \
  cd build && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_PANGOLIN_DEPTHSENSE=OFF \
    -DBUILD_PANGOLIN_FFMPEG=OFF \
    -DBUILD_PANGOLIN_LIBDC1394=OFF \
    -DBUILD_PANGOLIN_LIBJPEG=OFF \
    -DBUILD_PANGOLIN_LIBOPENEXR=OFF \
    -DBUILD_PANGOLIN_LIBPNG=OFF \
    -DBUILD_PANGOLIN_LIBREALSENSE=OFF \
    -DBUILD_PANGOLIN_LIBREALSENSE2=OFF \
    -DBUILD_PANGOLIN_LIBTIFF=OFF \
    -DBUILD_PANGOLIN_LIBUVC=OFF \
    -DBUILD_PANGOLIN_LZ4=OFF \
    -DBUILD_PANGOLIN_OPENNI=OFF \
    -DBUILD_PANGOLIN_OPENNI2=OFF \
    -DBUILD_PANGOLIN_PLEORA=OFF \
    -DBUILD_PANGOLIN_PYTHON=OFF \
    -DBUILD_PANGOLIN_TELICAM=OFF \
    -DBUILD_PANGOLIN_TOON=OFF \
    -DBUILD_PANGOLIN_UVC_MEDIAFOUNDATION=OFF \
    -DBUILD_PANGOLIN_V4L=OFF \
    -DBUILD_PANGOLIN_VIDEO=OFF \
    -DBUILD_PANGOLIN_ZSTD=OFF \
    -DBUILD_PYPANGOLIN_MODULE=OFF \
    .. && \
  make -j${NUM_THREADS} && \
  make install && \
  cd ../.. && \
  rm -rf Pangolin

WORKDIR /home
RUN git clone https://github.com/UZ-SLAMLab/ORB_SLAM3.git ORB_SLAM3 && \
  cd ORB_SLAM3 		&& \
  chmod +x build*.sh 	&& \
  ./build.sh 		

WORKDIR /home/ORB_SLAM3
RUN . /opt/ros/melodic/setup.sh && \
    export ROS_PACKAGE_PATH=${ROS_PACKAGE_PATH}:/home/ORB_SLAM3/Examples/ROS/ORB_SLAM3 &&\
    ./build_ros.sh

