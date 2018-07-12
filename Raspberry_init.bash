#!/bin/bash

#Prints version number and other info into logs. Other changes to this file are made throughout the log
cd ~
mkdir /home/pi/vmx-rtk
cd vmx-rtk
> master.log
cd ~

echo -e "\n*********************************************\n" >> /home/pi/vmx-rtk/master.log
echo -e "VMX_RTK_STD_V1_4 OFFICIAL\n" | sudo tee --append /home/pi/vmx-rtk/master.log
date | tee -a /home/pi/vmx-rtk/master.log
echo "Script started from $(pwd). More specific log files are located there" >> /home/pi/vmx-rtk/master.log
echo " " | sudo tee --append /home/pi/vmx-rtk/master.log

###
# Increase Raspberry Pi SWAP Size (TODO:  Currently Manual - automate this)
###

# Increase Swap size, to stop the system from hanging on multi-core builds
# 1) Edit /etc/dphys-swapfile to change this line to:
# CONF_SWAPSIZE=2048
#
# 2) Restart the swapfile service:
# sudo /etc/init.d/dphys-swapfile stop
# sudo /etc/init.d/dphys-swapfile start

steps[0]="All"
steps[1]="SUPPRIME -> Download and place VMX-RTK Desktop Icons"
steps[2]="Ensure that Raspbian is all up-to-date with ROS Dependencies"
steps[3]="SUPPRIME -> Raspberry Pi System Configuration"
steps[4]="SUPPRIME -> Raspi-Config loacalization settings"
steps[5]="Replace syslog with busybox"
steps[6]="Install VSCODE IDE"
steps[7]="Replace Openjdk with Oracle Java8 SDK"
steps[8]="Miscellaneous distribution installs"
steps[9]="SUPPRIME -> Add KauaiLabs gpg key and KauaiLabs apt site, and install VMX-pi HAL"
steps[10]="Build/Install SWIG"
steps[11]="SUPPRIME -> Enable VMX-RTK Splashscreen"
steps[12]="Custom FFMPEG Build"
steps[13]="Build OpenCV"
steps[14]="Build WPILIB"
steps[15]="Install Python ntcore, cscore"
steps[16]="VisionBuildSamples"
steps[17]="SUPPRIME -> Build ROS (Kinetic)"

function start_step() {
	set +x
	echo "Starting Step ${1}: ${steps[${1}]}" >> /home/pi/vmx-rtk/master.log
	echo "*********************"
	echo "**  Start Step ${1}  **"
	echo "*********************"
	set -x
}

function end_step() {
	set +x
	echo -e "Step ${1} Completed\n" >> /home/pi/vmx-rtk/master.log
	echo "*********************"
	echo "  End Step ${1}   "
	echo "*********************"
	set -x
}	

function usage() {
	echo "./vmx-rtk_script.sh [-h] [<step #>][~][<step#>]"
	echo "     -h : Show this usage information"
	echo "     <step #> is one of the following:"
	echo "          (blank) - Run entire script"
	i=1
	while [ ${i} -lt ${#steps[@]} ]
	do
		echo "          ${i} - ${steps[${i}]}"
		((i++))
	done
	echo ""
	echo "Run Options:"
	echo "     <step#> : run step# only, then stop"
	echo "     <step#>~ : run from step# onward to end"
	echo "     ~<step#> : run from step 1 to step#"
	echo "     <step#>~<step#> : run from first step# through second step#, then stop"
	exit 0;
}

start=""
end=""
laststep=16

while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
		-h*|--help*)
			usage
		;;	
		*)
			start=$(echo ${key} | cut -d"~" -f1)
			if [ "${start}" == "" ]
			then
				start=1
			fi
			
			if [ "$(echo ${key} | grep "~")" == "" ]
			then
				end=${start}
			else
				end=$(echo ${key} | cut -d"~" -f2)
				if [ "${end}" == "" ]
				then
					end=${laststep}
				fi	
			fi
			
			break
		;;
	esac
done

if [ -z "${start}" ]
then
	start=1
fi

if [ -z "${end}" ]
then
	end=${laststep}
fi

echo "Starting at step ${start} and ending on step ${end}" | sudo tee --append /home/pi/vmx-rtk/master.log

# Echo commands to console
#set -x
# Abort the script if any commands fail
set -e

step=${start}

#Starts logging output and errors to the logfile
exec &> >(tee "master-$(date +%m-%d-%Y-%R).log")

####
### Download and place VMX-RTK Desktop Icons
####
if [ ${step} -eq 1 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
	cd ~
	end_step ${step}
	((step++))
fi

####
### Ensure that Raspbian is all up-to-date with ROS Dependencies
####
if [ ${step} -eq 2 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
	sudo apt-get -y update
	sudo apt-get -y --allow-unauthenticated upgrade

	cd ~
	end_step ${step}
	((step++))
fi

#####
### Raspberry Pi System Configuration
#####

if [ ${step} -eq 3 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
	end_step ${step}
	((step++))
fi

####
### Raspi-Config loacalization settings
####
if [ ${step} -eq 4 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
	end_step ${step}
	((step++))
fi

####
### Replace syslog with busybox, avoiding writes to the hard disk for system logs
### (this is needed when configuring VMX Robotics Toolkit in 'headless' mode)
####
if [ ${step} -eq 5 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
	sudo apt-get install busybox-syslogd; sudo dpkg --purge rsyslog
	end_step ${step}
	((step++))
fi

####
### Install VSCODE IDE
###
### Run your instance with ./scripts/code.sh from the vscode folder
####
if [ ${step} -eq 6 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
	if [ -d "./vscode" ] && [ -e "./vscode/code.sh" ]
	then
		echo -e "VSCODE is already installed.\n" | tee -a /home/pi/vmx-rtk/master.log
	else
		sudo rm -fr vscode
		sudo apt-get -y remove node nodejs-legacy
		sudo apt-get -y install yarn
		sudo rm -fr node_latest_armhf.deb*
		wget http://node-arm.herokuapp.com/node_latest_armhf.deb && sudo dpkg -i node_latest_armhf.deb
		sudo apt-get install libx11-dev
		#git clone https://github.com/microsoft/vscode
		#cd vscode
		#sudo ./scripts/npm.sh install --arch=armhf
		sudo rm -f apt.sh
		wget https://code.headmelted.com/installers/apt.sh && sudo chmod a+x apt.sh && sudo ./apt.sh
	fi
	
	end_step ${step}
	((step++))
fi
	
####
### Replace openjdk with oracle java8 sdk - this avoids some issues with opencv
####
if [ ${step} -eq 7 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
	sudo apt-get -y purge openjdk*
	sudo apt -y autoremove
	sudo apt-get -y install oracle-java8-jdk*
	export JAVA_HOME=/usr/lib/jvm/jdk-8-oracle-arm32-vfp-hflt
	end_step ${step}
	((step++))
fi

####
### Miscellaneous distribution installs
####
if [ ${step} -eq 8 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
	sudo mkdir /usr/lib/jvm/java-8-openjdk-armhf/jre/lib/arm/server
	sudo cp /usr/lib/jvm/java-8-openjdk-armhf/jre/lib/arm/client/libjvm.so 	/usr/lib/jvm/java-8-openjdk-armhf/jre/lib/arm/server

	sudo apt-get -y install eclipse eclipse-jdt eclipse-cdt
	sudo apt-get -y install git
	sudo apt-get -y install git-gui
	sudo apt-get -y install ftp
	sudo apt-get -y install libboost1.62-all
	sudo apt-get -y install ntp
	sudo apt-get -y install xgalaga
	sudo apt-get -y install tcl-dev
	sudo apt-get -y install mono-runtime
	sudo apt-get -y install libpcre3 libpcre3-dev
	sudo apt-get -y install cmake
	sudo apt-get -y install mono-devel
	sudo apt-get -y install gradle

	# XML Components (for C++ and Python)
	sudo apt-get -y install libxml2-dev
	sudo apt-get -y install python3-lxml || sudo pip3 install lxml

	end_step ${step}
	((step++))
fi

####
### Add KauaiLabs gpg key, add KauaiLabs apt site, and install VMX-pi HAL
### (This can be updated later via:  sudo apt-get install --only-upgrade vmxpi-hal)
####
if [ ${step} -eq 9 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
	end_step ${step}
	((step++))
fi

####
### Build/Install SWIG
####
if [ ${step} -eq 10 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
	cd ~
	
#Added by M. Mann on 3/11/2018 to clean up from any previous install
	rm -fr swig*

	wget http://prdownloads.sourceforge.net/swig/swig-3.0.12.tar.gz
	tar xzf swig-3.0.12.tar.gz
	cd swig-3.0.12
	./configure
	make
	sudo make install
	cd ~
	rm swig-3.0.12.tar.gz
	end_step ${step}
	((step++))
fi

####
### Enable VMX-RTK Splashscreen
####
if [ ${step} -eq 11 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
	end_step ${step}
	((step++))
fi

####
### Custom FFMPEG Build.  This step is necessary in order to work around a conflict
### that occurs when using OpenCV from Java.  The issue is that the default build
### of FFMPEG (installed typically via apt) for Raspbian Stretch [v.3.2.9 as of this
### writing] is built to be dependent upon libopenmpt - which causes an exception
### when loaded from Java.
###
### Therefore, this custom build disables the references to libopenmpt.
####
if [ ${step} -eq 12 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
# To help keep things clean, uninstall any existing ffmpeg
	sudo apt-get -y remove ffmpeg

# Checkout FFMPEG
	cd ~

#Added by M. Mann on 3/12/2018 to clean up from any previous install
	rm -fr *n3.2.9*
	
	wget https://github.com/FFmpeg/FFmpeg/archive/n3.2.9.zip
	unzip n3.2.9.zip
	cd FFmpeg-n3.2.9

# Configure build to build .so files, and to NOT include the build of libopenmpt
	./configure --disable-libopenmpt --enable-shared
# Build & Install
	make -j5
	sudo make install
	end_step ${step}
	((step++))
fi

####
### OpenCV - build from source, with a special set of options for performance
####
if [ ${step} -eq 13 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
	sudo apt-get -y install build-essential
	wget https://bootstrap.pypa.io/get-pip.py
	sudo python get-pip.py	
	sudo python -m pip install -U numpy
	sudo apt-get -y install python-dev
	
# Added by M. Mann on 3/11/18 to ensure latest version of proper numpy is installed
#	sudo pip3 install numpy --upgrade
	sudo python3 get-pip.py
	rm get-pip.py
	sudo python3 -m pip install -U numpy
	sudo apt-get install libatlas-base-dev
	
	sudo apt-get -y install python-scipy python-matplotlib libgtk2.0-dev

	cd ~
	
	rm -fr opencv*
	OPENCV_VER="3.4.2"
	sudo wget https://github.com/opencv/opencv/archive/${OPENCV_VER}.zip
	mv ${OPENCV_VER}.zip opencv.zip
	
	unzip opencv.zip
	cd opencv-${OPENCV_VER}/
	if [ -d build ]
	then
		rm -fr build
	fi
	
	mkdir build
	cd build

# ENABLE_NEON and ENABLE_VFPV3 to optimize performance on Raspberry Pi platform
	cmake -DENABLE_NEON=ON -DENABLE_VFPV3=ON -D CMAKE_BUILD_TYPE=RELEASE -D BUILD_PERF_TESTS=OFF -D BUILD_SHARED_LIBRARY=ON -D BUILD_TESTS=OFF -D BUILD_opencv_python2=ON -D BUILD_opencv_python3=ON -D JAVA_INCLUDE_PATH=/usr/lib/jvm/jdk-8-oracle-arm32-vfp-hflt/include/ -D JAVA_AWT_INCLUDE_PATH=/usr/lib/jvm/jdk-8-oracle-arm32-vfp-hflt/include/ -D JAVA_AWT_LIBRARY=/usr/lib/jvm/jdk-8-oracle-arm32-vfp-hflt/include/jawt.h -D JAVA_JVM_LIBRARY=/usr/lib/jvm/jdk-8-oracle-arm32-vfp-hflt/include/jni.h /home/pi/opencv-${OPENCV_VER}

	make -j5
	sudo make install
	cd ~
	rm -f opencv.zip
	end_step ${step}
	((step++))
fi

####
###Cmake wpilib (Includes cscore, ntcore, and wpiutil)
### NOTE:  wpilib build must occur ~after~ the opencv (>= 3.3.1) build, since cscore is dependent upon opencv
###
### This builds the wpi library ntcore, cscore and wpiutil components,
### builds them using cmake and installs the files to:
###
###   /usr/local/wpilib
####
if [ ${step} -eq 14 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
	rm -fr wpilib_cmake && mkdir wpilib_cmake
	
# Added by M. Mann on 3/10 to avoid wpilib finding OpenCV in previous ROS build
	if [ -e "/opt/ros/kinetic" ]
	then
		sudo rm -fr /opt/ros/kinetic
		sudo rm -fr /usr/local/wpilib
	fi
	
	pushd wpilib_cmake
	git clone --recursive https://github.com/ThadHouse/CmakeWpilib.git .

	mkdir build
	cd build
# Set JAVA_HOME to avoid "Could not find JNI" error (M. Mann 1/15/18)
	export JAVA_HOME=/usr/lib/jvm/jdk-8-oracle-arm32-vfp-hflt
	cmake ..
	make -j5
	sudo make install
	popd
	end_step ${step}
	((step++))
fi

####
### Install Python ntcore, cscore (and dependencies)
### This uses the instructions at http://robotpy.readthedocs.io/en/stable/install/cscore.html
### (in the "Compile from Source" section)
###
### NOTE:  This assumes opencv3.3.1 has been previously built/installed
####
if [ ${step} -eq 15 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
# Added by M. Mann to fix libf77blas.so missing error
	sudo apt-get -y install libatlas-base-dev pybind11-dev
# Added by K. Keep to update dependecies required for Raspberry Pi 3 B+ version of Stretch
	sudo pip3 install 'pybind11>=2.2'
	sudo pip3 install 'pybind11>=2.2'
	sudo pip3 install robotpy-cscore
	end_step ${step}     
	((step++))
fi

####
### VisionBuildSamples (helpers for integrating GRIP-generated pipelines on Raspberry Pi)
####
if [ ${step} -eq 16 ] && [ ${step} -le ${end} ]
then
	start_step ${step}
	if [ -d VisionBuildSamples ]
	then
		rm -fr VisionBuildSamples
	fi

	git clone https://github.com/wpilibsuite/VisionBuildSamples.git
	cd ~
	
	end_step ${step}
	((step++))
fi

####
### ROS (Kinetic) [NOTE that this build can take many hours to complete]
####
if [ ${step} -eq 17 ] && [ ${step} -le ${end} ]
then
	start_step ${step}

	cd ~
	
	end_step ${step}
	((step++))
fi

####
### JavaFX Embedded Port (Experimental)
####
if [ ${step} -eq 18 ] && [ ${step} -le ${end} ]
then
	#start_step ${step}
	#wget http://gluonhq.com/download/javafx-embedded-sdk/
	#end_step ${step}
	#((step++))
	echo ""
fi

if [ ${step} -gt ${laststep} ]
then
	set +x
	echo "VMX-RTK Build Completed" | sudo tee --append /home/pi/vmx-rtk/master.log
	echo -e "\n*********************************************\n" >> /home/pi/vmx-rtk/master.log
else
	set +x
	echo "Script run is complete." | sudo tee --append /home/pi/vmx-rtk/master.log
	echo -e "\n*********************************************\n" >> /home/pi/vmx-rtk/master.log
fi
