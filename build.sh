#!/usr/bin/env bash
installer_dir=..
docker_context=`pwd`

echo "Start to build orb_slam3 docker image ..."
echo "-----------------------------------------------"
if [ "$1 " != " " ]; then
    installer_dir=$1
fi

cd $installer_dir
python3 -m http.server &
server_pid=$!

cd $docker_context
installer_ip=`ifconfig docker0 | grep 'inet\s' | awk '{print $2}'`
echo set installer_url=http://${installer_ip}:8000
docker build -f Dockerfile -t lxzheng/orbslam3:ros-melodic \
             --build-arg installer_url=http://${installer_ip}:8000 \
	     --build-arg git_proxy="" \
	     --build-arg LOCAL_BUILD=true \
             .

kill $server_pid
echo "---------------"
echo "  Finish. ^_^  "
echo "---------------"
