#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
  echo "Error: You must be root to run this script, please use root to install mysql!"
  exit 1
fi

# Check if system is 32 bit
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
  echo "Error:You must use 32 bit system to run this script!"
  exit 1
fi
echo ""
echo -e "\033[7m"
echo " ********************************************************************"
echo " *      LNAMP(Linux+Nginx+Apache+MySQL+PHP) 1.0 for CentOS          *"
echo " ********************************************************************"
echo " * A tool to auto-compile & install Nginx+Apache+MySQL+PHP on Linux *"
echo " *                 For any queries please contact me.               *"
echo " *                                                                  *"
echo " ********************************************************************"
echo -e "\033[0m"
echo ""

# set the source url
url_zend_optimizer="http://git.oschina.net/hopol/LNAMP/raw/master/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz"

get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}

init()
{
#set work directory

echo "==========================="

wd="/usr/local/src"
echo "Please input the work directory:"
read -p "(Default work directory: $wd):" temp
if [ "$temp" != "" ]; then
  wd=$temp
fi
echo "==========================="

echo workdirectory="$wd"
}
install_zend_iptimizer()
{
echo "****************************************"
echo "*      install zend optimizer          *"
echo "****************************************"
cd $wd
if [ -s ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz ]; then
  echo "ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz [found]"
  else
  echo "Error: ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz not found!!!download now......"
  wget -c $url_zend_optimizer
  echo "ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz download finishing!"
fi
tar -zxf ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
mkdir -p /usr/local/Zend/lib/Optimizer-3.3.9/php-5.2.x
cp ZendOptimizer-3.3.9-linux-glibc23-i386/data/5_2_x_comp/ZendOptimizer.so /usr/local/Zend/lib/Optimizer-3.3.9/php-5.2.x/ZendOptimizer.so
}
create_zend_optimizer_config_file()
{
cd $wd
cat >>/etc/php.ini<<EOF
[Zend Optimizer]
zend_extension = "/usr/local/Zend/lib/Optimizer-3.3.9/php-5.2.x/ZendOptimizer.so"
EOF
}

init

install_zend_iptimizer

create_zend_optimizer_config_file

service nginx restart

echo ""
echo " ******************************************************************************"
echo " *                      For any queries please contact me                     *"
echo " ******************************************************************************"
echo ""