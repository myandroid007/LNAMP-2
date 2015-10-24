@@@@@@@@@@@@ LNAMP一键安装包 [典藏版] @@@@@@@@@@@@ 因为年代久远，千万别用。

Apache configuration file:/usr/local/apache2/conf/httpd.conf

Nginx configuration file:/usr/local/nginx/conf/nginx.conf

Apache virtual host configuration file:/usr/local/apache2/conf/httpd.conf

Nginx virtual host configuration file:/usr/local/apache2/conf/httpd.conf

phpMyAdmin:http://.../phpmyadmin

PHP Prober:http://.../p.php

安装步骤：

1、 下载LNAMP一键安装包 wget -c http://hopol.googlecode.com/files/LNAMP_1.0_final.tar.gz

2、 解压tar zxvf LNAMP_1.0_final.tar.gz，您将得到CentOS、Debian和Ubuntu这三个文件夹，根据服务器选择的系统切换到相应目录下，目录中将有五个文件，main-install.sh是基本安装脚本；eaccelerator-install.sh（用于安装eaccelerator）、ZendOptimizer-install.sh（用于安装Zend Optimizer）和pure-ftp-install.sh（用于安装pureftpd）是可选的安装脚本；setup-vhost.sh是用于创建virtual host的脚本。

3、 赋予main-install.sh、eaccelerator-install.sh、ZendOptimizer-install.sh、pure-ftp-install.sh和setup-vhost.sh 这五个文件可执行权限，chmod +x .sh

4、 执行脚本./main-install.sh和您选择的安装脚本，将会自动安装各种程序。

详细步骤：

yum remove httpd

yum install screen

screen -S lnamp

wget -c http://hopol.googlecode.com/files/LNAMP_1.0_final.tar.gz

tar zxvf LNAMP_1.0_final.tar.gz

cd CentOS

chmod +x .sh

./main-install.sh

./eaccelerator-install.sh

./ZendOptimizer-install.sh <---记得去掉问号

/root/CentOS/setup-vhost.sh

[编辑]如何管理？

1、Nginx管理：/etc/init.d/nginx {start|restart|stop} （注：执行/etc/init.d/nginx时会对httpd起作用）

2、Apache管理：/etc/init.d/httpd {start|restart|stop}

3、启动pure-ftp：/usr/local/pureftpd/sbin/pure-config.pl /usr/local/pureftpd/etc/pure-ftpd.conf –daemonize

4、创建virtual host：./setupvm-without-pure-ftp.sh或者./setupvm-with-pure-ftp.sh，输入域名、ip、FTP用户名等相关信息即可。

5、PHP探针URL：http://{your_ip_address}/p.php

6、phpMyAdmin URL：http://{your_ip_address}/phpmyadmin