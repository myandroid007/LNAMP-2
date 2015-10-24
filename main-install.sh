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
clear
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
url_mysql="http://git.oschina.net/hopol/LNAMP/raw/master/mysql-5.1.45.tar.gz"
url_httpd="http://git.oschina.net/hopol/LNAMP/raw/master/httpd-2.2.15.tar.gz"
#url_mod_fcgi="http://git.oschina.net/hopol/LNAMP/raw/master/mod_fcgid.2.2.tgz"
url_mod_rpaf="http://git.oschina.net/hopol/LNAMP/raw/master/mod_rpaf-0.6.tar.gz"
url_libiconv="http://git.oschina.net/hopol/LNAMP/raw/master/libiconv-1.13.1.tar.gz"
url_libmcrypt="http://git.oschina.net/hopol/LNAMP/raw/master/libmcrypt-2.5.8.tar.bz2"
url_mcrypt="http://git.oschina.net/hopol/LNAMP/raw/master/mcrypt-2.6.8.tar.gz"
url_mhash="http://git.oschina.net/hopol/LNAMP/raw/master/mhash-0.9.9.9.tar.bz2"
url_php="http://git.oschina.net/hopol/LNAMP/raw/master/php-5.2.14.tar.gz"
url_php5_mail_header_patch="http://git.oschina.net/hopol/LNAMP/raw/master/php5-mail-header.patch"
url_libiconv="http://git.oschina.net/hopol/LNAMP/raw/master/libiconv-1.13.1.tar.gz"
url_libmcrypt="http://git.oschina.net/hopol/LNAMP/raw/master/libmcrypt-2.5.8.tar.bz2"
url_mcrypt="http://git.oschina.net/hopol/LNAMP/raw/master/mcrypt-2.6.8.tar.gz"
url_pdo_mysql="http://git.oschina.net/hopol/LNAMP/raw/master/PDO_MYSQL-1.0.2.tgz"
url_mhash="http://git.oschina.net/hopol/LNAMP/raw/master/mhash-0.9.9.9.tar.bz2"
url_memcache="http://git.oschina.net/hopol/LNAMP/raw/master/memcache-2.2.5.tgz"
#url_suhosin="http://git.oschina.net/hopol/LNAMP/raw/master/suhosin-0.9.29.tgz"
url_suhosin_patch="http://git.oschina.net/hopol/LNAMP/raw/master/suhosin-patch-5.2.14-0.9.7.patch.gz"
url_ioncube_loaders="http://git.oschina.net/hopol/LNAMP/raw/master/ioncube_loaders_lin_x86.tar.gz"
url_pcre="http://git.oschina.net/hopol/LNAMP/raw/master/pcre-8.01.tar.gz"
url_nginx="http://git.oschina.net/hopol/LNAMP/raw/master/nginx-0.7.65.tar.gz"
url_php_iprober="http://git.oschina.net/hopol/LNAMP/raw/master/p.tar.gz"
url_phpmyadmin="http://git.oschina.net/hopol/LNAMP/raw/master/phpMyAdmin-3.3.8-all-languages.tar.gz"

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
	
#set mysql root password

echo "==========================="

mysqlrootpwd="root"
echo "Please input the root password of mysql:"
read -p "(Default password: $mysqlrootpwd):" temp
if [ "$temp" != "" ]; then
  mysqlrootpwd=$temp
fi
echo "==========================="

echo mysqlrootpwd="$mysqlrootpwd"
#set host main IP address

echo "==========================="

ipaddress=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk 'NR==1 { print $1}'`
echo "Please input the main IP address:"
read -p "(Default IP address: $ipaddress):" temp 
if [ "$temp" != "" ]; then
  ipaddress=$temp
fi
echo "==========================="

echo ipaddress="$ipaddress"
#set server name

echo "==========================="

servername="host.18883.com"
echo "Please input the server name:"
read -p "(Default server name: $servername):" temp 
if [ "$temp" != "" ]; then
  servername=$temp
fi
echo "==========================="

echo servername="$servername"
#set server admin email

echo "==========================="

serveradminemail="webmaster@18883.com"
echo "Please input the server admin email:"
read -p "(Default server admin email: $serveradminemail):" temp 
if [ "$temp" != "" ]; then
  serveradminemail=$temp
fi
echo "==========================="

echo serveradminemail="$serveradminemail"

echo "==========================="

echo ""
echo "Press any key to start..."
get_char
}

remove_installed()
{
rpm -qa|grep  httpd
rpm -e httpd
rpm -qa|grep mysql
rpm -e mysql
rpm -qa|grep php
rpm -e php

yum -y remove httpd
yum -y remove httpd*
yum -y remove mysql*
yum -y remove php*

#yum -y install yum-fastestmirror
yum -y remove httpd
}
install_mysql()
{
echo "****************************************"
echo "*          install mysql               *"
echo "****************************************"
cd $wd
if [ -s mysql-5.1.45.tar.gz ]; then
  echo "mysql-5.1.45.tar.gz [found]"
else
  echo "Error: mysql-5.1.45.tar.gz not found!!!download now......"
  wget -c $url_mysql
  echo "mysql-5.1.45.tar.gz download finishing!"
fi
tar -zxf mysql-5.1.45.tar.gz
cd mysql-5.1.45
autoreconf --force --install
libtoolize --automake --force
automake --force --add-missing
./configure --prefix=/usr/local/mysql --with-extra-charsets=all --enable-thread-safe-client --enable-assembler --with-charset=utf8 --enable-thread-safe-client --with-extra-charsets=all --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile
make && make install
cd ../
groupadd mysql -g 27
useradd mysql -u 27 -g 27 -c "MySQL Server" -d /var/lib/mysql -M
cp /usr/local/mysql/share/mysql/my-medium.cnf /etc/my.cnf
sed -i 's/skip-locking/skip-external-locking/g' /etc/my.cnf
/usr/local/mysql/bin/mysql_install_db --user=mysql --basedir=/usr/local/mysql
chown -R mysql /usr/local/mysql/var
chgrp -R mysql /usr/local/mysql/.
cp /usr/local/mysql/share/mysql/mysql.server /etc/init.d/mysql
chmod u+x /etc/init.d/mysql
chkconfig --level 345 mysql on
echo "/usr/local/mysql/lib/mysql" >> /etc/ld.so.conf
echo "/usr/local/lib" >>/etc/ld.so.conf
ldconfig
ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql
ln -s /usr/local/mysql/include/mysql /usr/include/mysql
ln -s /usr/local/mysql/bin/mysql_config /usr/bin/mysql_config
service mysql start
service mysql stop
}
modify_mysql_pwd()
{
echo "*****************************************"
echo "*         modify mysql pwd              *"
echo "****************************************"
service mysql start
/usr/local/mysql/bin/mysqladmin -u root password $mysqlrootpwd
service mysql stop
}

install_httpd()
{
echo "****************************************"
echo "*          install httpd               *"
echo "****************************************"
cd $wd
if [ -s httpd-2.2.15.tar.gz ]; then
  echo "httpd-2.2.15.tar.gz [found]"
else
  echo "Error: httpd-2.2.15.tar.gz not found!!!download now......"
  wget -c $url_httpd
  echo "httpd-2.2.15.tar.gz download finishing!"
fi
groupadd nobody -g 99
tar -zxf httpd-2.2.15.tar.gz
cd httpd-2.2.15
./configure --prefix=/usr/local/apache --enable-headers --enable-so --enable-mime-magic --enable-proxy --enable-rewrite --enable-ssl --enable-suexec --disable-userdir --with-included-apr --with-mpm=prefork --with-ssl=/usr --with-suexec-caller=nobody --with-suexec-docroot=/ --with-suexec-gidmin=100 --with-suexec-logfile=/usr/local/apache/logs/suexec_log --with-suexec-uidmin=100 --with-suexec-userdir=public_html
make
make install
mkdir /usr/local/apache/domlogs
mkdir -p /var/www/html
cp /usr/local/apache/bin/apachectl /etc/init.d/httpd
}
install_php()
{
echo "****************************************"
echo "*           install php                *"
echo "****************************************"
cd $wd
if [ -s php-5.2.14.tar.gz ]; then
  echo "php-5.2.14.tar.gz [found]"
else
  echo "Error: php-5.2.14.tar.gz not found!!!download now......"
  wget -c $url_php
  echo "php-5.2.14.tar.gz download finishing!"
fi
if [ -s suhosin-patch-5.2.14-0.9.7.patch.gz ]; then
  echo "suhosin-patch-5.2.14-0.9.7.patch.gz [found]"
else
  echo "Error: suhosin-patch-5.2.14-0.9.7.patch.gz not found!!!download now......"
  wget -c $url_suhosin_patch
  echo "suhosin-patch-5.2.14-0.9.7.patch.gz download finishing!"
fi
if [ -s php5-mail-header.patch ]; then
  echo "php5-mail-header.patch [found]"
else
  echo "Error: php5-mail-header.patch found!!!download now......"
  wget -c $url_php5_mail_header_patch
  echo "php5-mail-header.patch download finishing!"
fi
if [ -s libiconv-1.13.1.tar.gz ]; then
  echo "libiconv-1.13.1.tar.gz [found]"
  else
  echo "Error: libiconv-1.13.1.tar.gz not found!!!download now......"
  wget -c $url_libiconv
  echo "libiconv-1.13.1.tar.gz download finishing!"
fi
if [ -s libmcrypt-2.5.8.tar.bz2 ]; then
  echo "libmcrypt-2.5.8.tar.bz2 [found]"
  else
  echo "Error: libmcrypt-2.5.8.tar.bz2 not found!!!download now......"
  wget -c $url_libmcrypt
  echo "libmcrypt-2.5.8.tar.bz2 download finishing!"
fi
if [ -s mcrypt-2.6.8.tar.gz ]; then
  echo "mcrypt-2.6.8.tar.gz [found]"
  else
  echo "Error: mcrypt-2.6.8.tar.gz not found!!!download now......"
  wget -c $url_mcrypt
  echo "mcrypt-2.6.8.tar.gz download finishing!"
fi
if [ -s mhash-0.9.9.9.tar.bz2 ]; then
  echo "mhash-0.9.9.9.tar.bz2 [found]"
  else
  echo "Error: mhash-0.9.9.9.tar.bz2 not found!!!download now......"
  wget -c $url_mhash
  echo "mhash-0.9.9.9.tar.bz2 download finishing!"
fi
tar -zxf libiconv-1.13.1.tar.gz
cd libiconv-1.13.1/
./configure
make
make install
cd ..
tar -jxf libmcrypt-2.5.8.tar.bz2
cd libmcrypt-2.5.8/
./configure
make
make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make
make install
cd ../../
tar -jxf mhash-0.9.9.9.tar.bz2
cd mhash-0.9.9.9/
./configure
make
make install
ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
cd ..
tar -zxf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8/
/sbin/ldconfig
./configure
make
make install
cd ..
tar -zxf php-5.2.14.tar.gz
gzip -d ./suhosin-patch-5.2.14-0.9.7.patch.gz
patch -d php-5.2.14 -p1 < php5-mail-header.patch
cd php-5.2.14
patch -p 1 -i ../suhosin-patch-5.2.14-0.9.7.patch
./buildconf --force
./configure --prefix=/usr/local --with-config-file-path=/etc --with-apxs2=/usr/local/apache/bin/apxs --enable-bcmath --enable-calendar --enable-exif --enable-ftp --enable-gd-native-ttf --enable-libxml --enable-magic-quotes --enable-mbstring --enable-pdo=shared --enable-soap --enable-sockets --enable-zip --with-bz2 --with-curl --with-curlwrappers --with-freetype-dir --with-gd --with-gettext --with-jpeg-dir --with-kerberos --with-libexpat-dir=/usr --with-libxml-dir=/usr --with-mcrypt=/usr --with-mhash=/usr --with-mysql=/usr --with-mysql-sock=/var/lib/mysql/mysql.sock --with-mysqli=/usr/bin/mysql_config --with-openssl=/usr --with-openssl-dir=/usr --with-pdo-mysql=shared --with-pdo-sqlite=shared --with-png-dir=/usr --with-sqlite=shared --with-ttf --with-xmlrpc --with-zlib -with-zlib-dir=/usr --enable-suhosin
make ZEND_EXTRA_LIBS='-liconv'
make install
}

install_php_ext()
{
echo "****************************************"
echo "*        install php extention         *"
echo "****************************************"
cd $wd
if [ -s memcache-2.2.5.tgz ]; then
  echo "memcache-2.2.5.tgz [found]"
else
  echo "Error: memcache-2.2.5.tgz not found!!!download now......"
  wget -c $url_memcache
  echo "memcache-2.2.5.tgz download finishing!"
fi
if [ -s ioncube_loaders_lin_x86.tar.gz ]; then
  echo "ioncube_loaders_lin_x86.tar.gz [found]"
else
  echo "Error: ioncube_loaders_lin_x86.tar.gz not found!!!download now......"
  wget -c $url_ioncube_loaders
  echo "ioncube_loaders_lin_x86.tar.gz download finishing!"
fi
if [ -s PDO_MYSQL-1.0.2.tgz ]; then
  echo "PDO_MYSQL-1.0.2.tgz [found]"
else
  echo "Error: PDO_MYSQL-1.0.2.tgz not found!!!download now......"
  wget -c $url_pdo_mysql
  echo "PDO_MYSQL-1.0.2.tgz download finishing!"
fi
tar -zxf memcache-2.2.5.tgz
cd memcache-2.2.5/
phpize
./configure --with-php-config=/usr/local/bin/php-config --with-zlib-dir --enable-memcache
make
make install
cd ../
tar -zxf ioncube_loaders_lin_x86.tar.gz
cd ioncube
mkdir /usr/local/ioncube
mv ioncube_loader_lin_5.2.so /usr/local/ioncube/
cd ../
tar zxf PDO_MYSQL-1.0.2.tgz
cd PDO_MYSQL-1.0.2/
phpize
./configure --with-php-config=/usr/local/bin/php-config --with-pdo-mysql=/usr/local/mysql
make && make install
cd ../
}
install_pcre()
{
echo "****************************************"
echo "*           install pcre               *"
echo "****************************************"
cd $wd
if [ -s pcre-8.01.tar.gz ]; then
  echo "pcre-8.01.tar.gz [found]"
else
  echo "Error: pcre-8.01.tar.gz not found!!!download now......"
  wget -c $url_pcre
  echo "pcre-8.01.tar.gz download finishing!"
fi
tar zxf pcre-8.01.tar.gz
cd pcre-8.01
./configure
make
make install
cd ..
ln -s /usr/local/lib/libpcre.so.0 /lib/libpcre.so.0
ln -s /usr/lib/libpcre.so.3 /usr/lib/libpcre.so.0
}
install_nginx()
{
echo "****************************************"
echo "*           install nginx              *"
echo "****************************************"
cd $wd
if [ -s nginx-0.7.65.tar.gz ]; then
  echo "nginx-0.7.65.tar.gz [found]"
else
  echo "Error: nginx-0.7.65.tar.gz not found!!!download now......"
  wget -c $url_nginx
  echo "nginx-0.7.65.tar.gz download finishing!"
fi
tar zxf nginx-0.7.65.tar.gz
cd nginx-0.7.65
sed -i 's/0.7.65/1.0/g' src/core/nginx.h
sed -i 's/"nginx/"LNAMP/g' src/core/nginx.h
sed -i 's/"NGINX/"LNAMP/g' src/core/nginx.h
./configure --user=nobody --group=nobody --prefix=/usr/local/nginx --pid-path=/usr/local/nginx/logs/nginx.pid --error-log-path=/usr/local/nginx/logs/error.log --http-log-path=/usr/local/nginx/logs/access.log --http-client-body-temp-path=/tmp/nginx_client --http-proxy-temp-path=/tmp/nginx_proxy --http-fastcgi-temp-path=/tmp/nginx_fastcgi --with-http_stub_status_module
make
make install
}

install_rpaf_module()
{
cd $wd
echo "****************************************"
echo "*           install rpaf               *"
echo "****************************************"
cd $wd
if [ -s mod_rpaf-0.6.tar.gz ]; then
  echo "mod_rpaf-0.6.tar.gz [found]"
else
  echo "Error: mod_rpaf-0.6.tar.gz not found!!!download now......"
  wget -c $url_mod_rpaf
  echo "mod_rpaf-0.6.tar.gz download finishing!"
fi
tar -zxf mod_rpaf-0.6.tar.gz
cd mod_rpaf-0.6
/usr/local/apache/bin/apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c
cd ../
}

install_phpmyadmin()
{
echo "****************************************"
echo "*         install phpmyadmin           *"
echo "****************************************"
cd $wd
if [ -s phpMyAdmin-3.3.8-all-languages.tar.gz ]; then
  echo "phpMyAdmin-3.3.8-all-languages.tar.gz [found]"
  else
  echo "Error: phpMyAdmin-3.3.8-all-languages.tar.gz not found!!!download now......"
  wget -c $url_phpmyadmin
  echo "phpMyAdmin-3.3.8-all-languages.tar.gz download finishing!"
fi
tar zxf phpMyAdmin-3.3.8-all-languages.tar.gz 
cp -Rf phpMyAdmin-3.3.8-all-languages /var/www/html/phpmyadmin
}

install_php_iprober()
{
echo "****************************************"
echo "*         install php iprober          *"
echo "****************************************"
cd $wd
if [ -s p.tar.gz ]; then
  echo "p.tar.gz [found]"
  else
  echo "Error: p.tar.gz not found!!!download now......"
  wget -c $url_php_iprober
  echo "p.tar.gz!"
fi
tar zxf p.tar.gz
cp p.php /var/www/html/
}

modify_php_config_file()
{
mv /etc/php.ini /etc/php.ini.bak
cat >>/etc/php.ini << EOF
[PHP]

;;;;;;;;;;;
; WARNING ;
;;;;;;;;;;;
; This is the default settings file for new PHP installations.
; By default, PHP installs itself with a configuration suitable for
; development purposes, and *NOT* for production purposes.
; For several security-oriented considerations that should be taken
; before going online with your site, please consult php.ini-recommended
; and http://php.net/manual/en/security.php.


;;;;;;;;;;;;;;;;;;;
; About php.ini   ;
;;;;;;;;;;;;;;;;;;;
; This file controls many aspects of PHP's behavior.  In order for PHP to
; read it, it must be named 'php.ini'.  PHP looks for it in the current
; working directory, in the path designated by the environment variable
; PHPRC, and in the path that was defined in compile time (in that order).
; Under Windows, the compile-time path is the Windows directory.  The
; path in which the php.ini file is looked for can be overridden using
; the -c argument in command line mode.
;
; The syntax of the file is extremely simple.  Whitespace and Lines
; beginning with a semicolon are silently ignored (as you probably guessed).
; Section headers (e.g. [Foo]) are also silently ignored, even though
; they might mean something in the future.
;
; Directives are specified using the following syntax:
; directive = value
; Directive names are *case sensitive* - foo=bar is different from FOO=bar.
;
; The value can be a string, a number, a PHP constant (e.g. E_ALL or M_PI), one
; of the INI constants (On, Off, True, False, Yes, No and None) or an expression
; (e.g. E_ALL & ~E_NOTICE), or a quoted string ("foo").
;
; Expressions in the INI file are limited to bitwise operators and parentheses:
; |        bitwise OR
; &        bitwise AND
; ~        bitwise NOT
; !        boolean NOT
;
; Boolean flags can be turned on using the values 1, On, True or Yes.
; They can be turned off using the values 0, Off, False or No.
;
; An empty string can be denoted by simply not writing anything after the equal
; sign, or by using the None keyword:
;
;  foo =         ; sets foo to an empty string
;  foo = none    ; sets foo to an empty string
;  foo = "none"  ; sets foo to the string 'none'
;
; If you use constants in your value, and these constants belong to a
; dynamically loaded extension (either a PHP extension or a Zend extension),
; you may only use these constants *after* the line that loads the extension.
;
;
;;;;;;;;;;;;;;;;;;;
; About this file ;
;;;;;;;;;;;;;;;;;;;
; All the values in the php.ini-dist file correspond to the builtin
; defaults (that is, if no php.ini is used, or if you delete these lines,
; the builtin defaults will be identical).


;;;;;;;;;;;;;;;;;;;;
; Language Options ;
;;;;;;;;;;;;;;;;;;;;

; Enable the PHP scripting language engine under Apache.
engine = On

; Enable compatibility mode with Zend Engine 1 (PHP 4.x)
zend.ze1_compatibility_mode = Off

; Allow the <? tag.  Otherwise, only <?php and <script> tags are recognized.
; NOTE: Using short tags should be avoided when developing applications or
; libraries that are meant for redistribution, or deployment on PHP
; servers which are not under your control, because short tags may not
; be supported on the target server. For portable, redistributable code,
; be sure not to use short tags.
short_open_tag = On

; Allow ASP-style <% %> tags.
asp_tags = Off

; The number of significant digits displayed in floating point numbers.
precision    =  12

; Enforce year 2000 compliance (will cause problems with non-compliant browsers)
y2k_compliance = On

; Output buffering allows you to send header lines (including cookies) even
; after you send body content, at the price of slowing PHP's output layer a
; bit.  You can enable output buffering during runtime by calling the output
; buffering functions.  You can also enable output buffering for all files by
; setting this directive to On.  If you wish to limit the size of the buffer
; to a certain size - you can use a maximum number of bytes instead of 'On', as
; a value for this directive (e.g., output_buffering=4096).
output_buffering = Off

; You can redirect all of the output of your scripts to a function.  For
; example, if you set output_handler to "mb_output_handler", character
; encoding will be transparently converted to the specified encoding.
; Setting any output handler automatically turns on output buffering.
; Note: People who wrote portable scripts should not depend on this ini
;       directive. Instead, explicitly set the output handler using ob_start().
;       Using this ini directive may cause problems unless you know what script
;       is doing.
; Note: You cannot use both "mb_output_handler" with "ob_iconv_handler"
;       and you cannot use both "ob_gzhandler" and "zlib.output_compression".
; Note: output_handler must be empty if this is set 'On' !!!!
;       Instead you must use zlib.output_handler.
;output_handler =

; Transparent output compression using the zlib library
; Valid values for this option are 'off', 'on', or a specific buffer size
; to be used for compression (default is 4KB)
; Note: Resulting chunk size may vary due to nature of compression. PHP
;       outputs chunks that are few hundreds bytes each as a result of
;       compression. If you prefer a larger chunk size for better
;       performance, enable output_buffering in addition.
; Note: You need to use zlib.output_handler instead of the standard
;       output_handler, or otherwise the output will be corrupted.
zlib.output_compression = Off
;zlib.output_compression_level = -1

; You cannot specify additional output handlers if zlib.output_compression
; is activated here. This setting does the same as output_handler but in
; a different order.
;zlib.output_handler =

; Implicit flush tells PHP to tell the output layer to flush itself
; automatically after every output block.  This is equivalent to calling the
; PHP function flush() after each and every call to print() or echo() and each
; and every HTML block.  Turning this option on has serious performance
; implications and is generally recommended for debugging purposes only.
implicit_flush = Off

; The unserialize callback function will be called (with the undefined class'
; name as parameter), if the unserializer finds an undefined class
; which should be instantiated.
; A warning appears if the specified function is not defined, or if the
; function doesn't include/implement the missing class.
; So only set this entry, if you really want to implement such a
; callback-function.
unserialize_callback_func=

; When floats & doubles are serialized store serialize_precision significant
; digits after the floating point. The default value ensures that when floats
; are decoded with unserialize, the data will remain the same.
serialize_precision = 100

; Whether to enable the ability to force arguments to be passed by reference
; at function call time.  This method is deprecated and is likely to be
; unsupported in future versions of PHP/Zend.  The encouraged method of
; specifying which arguments should be passed by reference is in the function
; declaration.  You're encouraged to try and turn this option Off and make
; sure your scripts work properly with it in order to ensure they will work
; with future versions of the language (you will receive a warning each time
; you use this feature, and the argument will be passed by value instead of by
; reference).
allow_call_time_pass_reference = On

;
; Safe Mode
;
safe_mode = Off

; By default, Safe Mode does a UID compare check when
; opening files. If you want to relax this to a GID compare,
; then turn on safe_mode_gid.
safe_mode_gid = Off

; When safe_mode is on, UID/GID checks are bypassed when
; including files from this directory and its subdirectories.
; (directory must also be in include_path or full path must
; be used when including)
safe_mode_include_dir =

; When safe_mode is on, only executables located in the safe_mode_exec_dir
; will be allowed to be executed via the exec family of functions.
safe_mode_exec_dir =

; Setting certain environment variables may be a potential security breach.
; This directive contains a comma-delimited list of prefixes.  In Safe Mode,
; the user may only alter environment variables whose names begin with the
; prefixes supplied here.  By default, users will only be able to set
; environment variables that begin with PHP_ (e.g. PHP_FOO=BAR).
;
; Note:  If this directive is empty, PHP will let the user modify ANY
; environment variable!
safe_mode_allowed_env_vars = PHP_

; This directive contains a comma-delimited list of environment variables that
; the end user won't be able to change using putenv().  These variables will be
; protected even if safe_mode_allowed_env_vars is set to allow to change them.
safe_mode_protected_env_vars = LD_LIBRARY_PATH

; open_basedir, if set, limits all file operations to the defined directory
; and below.  This directive makes most sense if used in a per-directory
; or per-virtualhost web server configuration file. This directive is
; *NOT* affected by whether Safe Mode is turned On or Off.
;open_basedir =

; This directive allows you to disable certain functions for security reasons.
; It receives a comma-delimited list of function names. This directive is
; *NOT* affected by whether Safe Mode is turned On or Off.
disable_functions =

; This directive allows you to disable certain classes for security reasons.
; It receives a comma-delimited list of class names. This directive is
; *NOT* affected by whether Safe Mode is turned On or Off.
disable_classes =

; Colors for Syntax Highlighting mode.  Anything that's acceptable in
; <span style="color: ???????"> would work.
;highlight.string  = #DD0000
;highlight.comment = #FF9900
;highlight.keyword = #007700
;highlight.bg      = #FFFFFF
;highlight.default = #0000BB
;highlight.html    = #000000

; If enabled, the request will be allowed to complete even if the user aborts
; the request. Consider enabling it if executing long request, which may end up
; being interrupted by the user or a browser timing out.
; ignore_user_abort = On

; Determines the size of the realpath cache to be used by PHP. This value should
; be increased on systems where PHP opens many files to reflect the quantity of
; the file operations performed.
; realpath_cache_size=16k

; Duration of time, in seconds for which to cache realpath information for a given
; file or directory. For systems with rarely changing files, consider increasing this
; value.
; realpath_cache_ttl=120

;
; Misc
;
; Decides whether PHP may expose the fact that it is installed on the server
; (e.g. by adding its signature to the Web server header).  It is no security
; threat in any way, but it makes it possible to determine whether you use PHP
; on your server or not.
expose_php = On


;;;;;;;;;;;;;;;;;;;
; Resource Limits ;
;;;;;;;;;;;;;;;;;;;

max_execution_time = 30     ; Maximum execution time of each script, in seconds
max_input_time = 60	; Maximum amount of time each script may spend parsing request data
;max_input_nesting_level = 64 ; Maximum input variable nesting level
memory_limit = 128M      ; Maximum amount of memory a script may consume (128MB)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Error handling and logging ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; error_reporting is a bit-field.  Or each number up to get desired error
; reporting level
; E_ALL             - All errors and warnings (doesn't include E_STRICT)
; E_ERROR           - fatal run-time errors
; E_RECOVERABLE_ERROR  - almost fatal run-time errors
; E_WARNING         - run-time warnings (non-fatal errors)
; E_PARSE           - compile-time parse errors
; E_NOTICE          - run-time notices (these are warnings which often result
;                     from a bug in your code, but it's possible that it was
;                     intentional (e.g., using an uninitialized variable and
;                     relying on the fact it's automatically initialized to an
;                     empty string)
; E_STRICT          - run-time notices, enable to have PHP suggest changes
;                     to your code which will ensure the best interoperability
;                     and forward compatibility of your code
; E_CORE_ERROR      - fatal errors that occur during PHP's initial startup
; E_CORE_WARNING    - warnings (non-fatal errors) that occur during PHP's
;                     initial startup
; E_COMPILE_ERROR   - fatal compile-time errors
; E_COMPILE_WARNING - compile-time warnings (non-fatal errors)
; E_USER_ERROR      - user-generated error message
; E_USER_WARNING    - user-generated warning message
; E_USER_NOTICE     - user-generated notice message
;
; Examples:
;
;   - Show all errors, except for notices and coding standards warnings
;
;error_reporting = E_ALL & ~E_NOTICE
;
;   - Show all errors, except for notices
;
;error_reporting = E_ALL & ~E_NOTICE | E_STRICT
;
;   - Show only errors
;
;error_reporting = E_COMPILE_ERROR|E_RECOVERABLE_ERROR|E_ERROR|E_CORE_ERROR
;
;   - Show all errors except for notices and coding standards warnings
;
error_reporting = E_ALL & ~E_NOTICE

; Print out errors (as a part of the output).  For production web sites,
; you're strongly encouraged to turn this feature off, and use error logging
; instead (see below).  Keeping display_errors enabled on a production web site
; may reveal security information to end users, such as file paths on your Web
; server, your database schema or other information.
;
; possible values for display_errors:
;
; Off        - Do not display any errors
; stderr     - Display errors to STDERR (affects only CGI/CLI binaries!)
;
;display_errors = "stderr"
;
; stdout (On) - Display errors to STDOUT
;
display_errors = Off

; Even when display_errors is on, errors that occur during PHP's startup
; sequence are not displayed.  It's strongly recommended to keep
; display_startup_errors off, except for when debugging.
display_startup_errors = Off

; Log errors into a log file (server-specific log, stderr, or error_log (below))
; As stated above, you're strongly advised to use error logging in place of
; error displaying on production web sites.
log_errors = Off

; Set maximum length of log_errors. In error_log information about the source is
; added. The default is 1024 and 0 allows to not apply any maximum length at all.
log_errors_max_len = 1024

; Do not log repeated messages. Repeated errors must occur in same file on same
; line unless ignore_repeated_source is set true.
ignore_repeated_errors = Off

; Ignore source of message when ignoring repeated messages. When this setting
; is On you will not log errors with repeated messages from different files or
; source lines.
ignore_repeated_source = Off

; If this parameter is set to Off, then memory leaks will not be shown (on
; stdout or in the log). This has only effect in a debug compile, and if
; error reporting includes E_WARNING in the allowed list
report_memleaks = On

;report_zend_debug = 0

; Store the last error/warning message in \$php_errormsg (boolean).
track_errors = Off

; Turn off normal error reporting and emit XML-RPC error XML
;xmlrpc_errors = 0
; An XML-RPC faultCode
;xmlrpc_error_number = 0

; Disable the inclusion of HTML tags in error messages.
; Note: Never use this feature for production boxes.
;html_errors = Off

; If html_errors is set On PHP produces clickable error messages that direct
; to a page describing the error or function causing the error in detail.
; You can download a copy of the PHP manual from http://www.php.net/docs.php
; and change docref_root to the base URL of your local copy including the
; leading '/'. You must also specify the file extension being used including
; the dot.
; Note: Never use this feature for production boxes.
;docref_root = "/phpmanual/"
;docref_ext = .html

; String to output before an error message.
;error_prepend_string = "<font color=#ff0000>"

; String to output after an error message.
;error_append_string = "</font>"

; Log errors to specified file.
;error_log = filename

; Log errors to syslog (Event Log on NT, not valid in Windows 95).
;error_log = syslog


;;;;;;;;;;;;;;;;;
; Data Handling ;
;;;;;;;;;;;;;;;;;
;
; Note - track_vars is ALWAYS enabled as of PHP 4.0.3

; The separator used in PHP generated URLs to separate arguments.
; Default is "&".
;arg_separator.output = "&amp;"

; List of separator(s) used by PHP to parse input URLs into variables.
; Default is "&".
; NOTE: Every character in this directive is considered as separator!
;arg_separator.input = ";&"

; This directive describes the order in which PHP registers GET, POST, Cookie,
; Environment and Built-in variables (G, P, C, E & S respectively, often
; referred to as EGPCS or GPC).  Registration is done from left to right, newer
; values override older values.
variables_order = "EGPCS"

; Whether or not to register the EGPCS variables as global variables.  You may
; want to turn this off if you don't want to clutter your scripts' global scope
; with user data.  This makes most sense when coupled with track_vars - in which
; case you can access all of the GPC variables through the \$HTTP_*_VARS[],
; variables.
;
; You should do your best to write your scripts so that they do not require
; register_globals to be on;  Using form variables as globals can easily lead
; to possible security problems, if the code is not very well thought of.
register_globals = Off

; Whether or not to register the old-style input arrays, HTTP_GET_VARS
; and friends.  If you're not using them, it's recommended to turn them off,
; for performance reasons.
register_long_arrays = On

; This directive tells PHP whether to declare the argv&argc variables (that
; would contain the GET information).  If you don't use these variables, you
; should turn it off for increased performance.
register_argc_argv = On

; When enabled, the SERVER and ENV variables are created when they're first
; used (Just In Time) instead of when the script starts. If these variables
; are not used within a script, having this directive on will result in a
; performance gain. The PHP directives register_globals, register_long_arrays,
; and register_argc_argv must be disabled for this directive to have any affect.
auto_globals_jit = On

; Maximum size of POST data that PHP will accept.
post_max_size = 8M

; Magic quotes
;

; Magic quotes for incoming GET/POST/Cookie data.
magic_quotes_gpc = On

; Magic quotes for runtime-generated data, e.g. data from SQL, from exec(), etc.
magic_quotes_runtime = Off

; Use Sybase-style magic quotes (escape ' with '' instead of \').
magic_quotes_sybase = Off

; Automatically add files before or after any PHP document.
auto_prepend_file =
auto_append_file =

; As of 4.0b4, PHP always outputs a character encoding by default in
; the Content-type: header.  To disable sending of the charset, simply
; set it to be empty.
;
; PHP's built-in default is text/html
default_mimetype = "text/html"
;default_charset = "iso-8859-1"

; Always populate the \$HTTP_RAW_POST_DATA variable.
;always_populate_raw_post_data = On


;;;;;;;;;;;;;;;;;;;;;;;;;
; Paths and Directories ;
;;;;;;;;;;;;;;;;;;;;;;;;;

; UNIX: "/path1:/path2"
include_path = ".:/usr/lib/php:/usr/local/lib/php"
;
; Windows: "\path1;\path2"
;include_path = ".;c:\php\includes"

; The root of the PHP pages, used only if nonempty.
; if PHP was not compiled with FORCE_REDIRECT, you SHOULD set doc_root
; if you are running php as a CGI under any web server (other than IIS)
; see documentation for security issues.  The alternate is to use the
; cgi.force_redirect configuration below
doc_root =

; The directory under which PHP opens the script using /~username used only
; if nonempty.
user_dir =

; Directory in which the loadable extensions (modules) reside.
extension_dir = "/usr/local/lib/php/extensions/no-debug-non-zts-20060613/"

; Whether or not to enable the dl() function.  The dl() function does NOT work
; properly in multithreaded servers, such as IIS or Zeus, and is automatically
; disabled on them.
enable_dl = On

; cgi.force_redirect is necessary to provide security running PHP as a CGI under
; most web servers.  Left undefined, PHP turns this on by default.  You can
; turn it off here AT YOUR OWN RISK
; **You CAN safely turn this off for IIS, in fact, you MUST.**
; cgi.force_redirect = 1

; if cgi.nph is enabled it will force cgi to always sent Status: 200 with
; every request.
; cgi.nph = 1

; if cgi.force_redirect is turned on, and you are not running under Apache or Netscape
; (iPlanet) web servers, you MAY need to set an environment variable name that PHP
; will look for to know it is OK to continue execution.  Setting this variable MAY
; cause security issues, KNOW WHAT YOU ARE DOING FIRST.
; cgi.redirect_status_env = ;

; cgi.fix_pathinfo provides *real* PATH_INFO/PATH_TRANSLATED support for CGI.  PHP's
; previous behaviour was to set PATH_TRANSLATED to SCRIPT_FILENAME, and to not grok
; what PATH_INFO is.  For more information on PATH_INFO, see the cgi specs.  Setting
; this to 1 will cause PHP CGI to fix it's paths to conform to the spec.  A setting
; of zero causes PHP to behave as before.  Default is 1.  You should fix your scripts
; to use SCRIPT_FILENAME rather than PATH_TRANSLATED.
; cgi.fix_pathinfo=0

; FastCGI under IIS (on WINNT based OS) supports the ability to impersonate
; security tokens of the calling client.  This allows IIS to define the
; security context that the request runs under.  mod_fastcgi under Apache
; does not currently support this feature (03/17/2002)
; Set to 1 if running under IIS.  Default is zero.
; fastcgi.impersonate = 1;

; Disable logging through FastCGI connection
; fastcgi.logging = 0

; cgi.rfc2616_headers configuration option tells PHP what type of headers to
; use when sending HTTP response code. If it's set 0 PHP sends Status: header that
; is supported by Apache. When this option is set to 1 PHP will send
; RFC2616 compliant header.
; Default is zero.
;cgi.rfc2616_headers = 0


;;;;;;;;;;;;;;;;
; File Uploads ;
;;;;;;;;;;;;;;;;

; Whether to allow HTTP file uploads.
file_uploads = On

; Temporary directory for HTTP uploaded files (will use system default if not
; specified).
;upload_tmp_dir =

; Maximum allowed size for uploaded files.
upload_max_filesize = 2M


; Maximum number of files that can be uploaded via a single request
max_file_uploads = 20

;;;;;;;;;;;;;;;;;;
; Fopen wrappers ;
;;;;;;;;;;;;;;;;;;

; Whether to allow the treatment of URLs (like http:// or ftp://) as files.
allow_url_fopen = On

; Whether to allow include/require to open URLs (like http:// or ftp://) as files.
allow_url_include = Off

; Define the anonymous ftp password (your email address)
;from="john@doe.com"

; Define the User-Agent string
; user_agent="PHP"

; Default timeout for socket based streams (seconds)
default_socket_timeout = 60

; If your scripts have to deal with files from Macintosh systems,
; or you are running on a Mac and need to deal with files from
; unix or win32 systems, setting this flag will cause PHP to
; automatically detect the EOL character in those files so that
; fgets() and file() will work regardless of the source of the file.
; auto_detect_line_endings = Off


;;;;;;;;;;;;;;;;;;;;;;
; Dynamic Extensions ;
;;;;;;;;;;;;;;;;;;;;;;
;
; If you wish to have an extension loaded automatically, use the following
; syntax:
;
;   extension=modulename.extension
;
; For example, on Windows:
;
;   extension=msql.dll
;
; ... or under UNIX:
;
;   extension=msql.so
;
; Note that it should be the name of the module only; no directory information
; needs to go here.  Specify the location of the extension with the
; extension_dir directive above.


; Windows Extensions
; Note that ODBC support is built in, so no dll is needed for it.
; Note that many DLL files are located in the extensions/ (PHP 4) ext/ (PHP 5)
; extension folders as well as the separate PECL DLL download (PHP 5).
; Be sure to appropriately set the extension_dir directive.

;extension=php_bz2.dll
;extension=php_curl.dll
;extension=php_dba.dll
;extension=php_dbase.dll
;extension=php_exif.dll
;extension=php_fdf.dll
;extension=php_gd2.dll
;extension=php_gettext.dll
;extension=php_gmp.dll
;extension=php_ifx.dll
;extension=php_imap.dll
;extension=php_interbase.dll
;extension=php_ldap.dll
;extension=php_mbstring.dll
;extension=php_mcrypt.dll
;extension=php_mhash.dll
;extension=php_mime_magic.dll
;extension=php_ming.dll
;extension=php_msql.dll
;extension=php_mssql.dll
;extension=php_mysql.dll
;extension=php_mysqli.dll
;extension=php_oci8.dll
;extension=php_openssl.dll
;extension=php_pdo.dll
;extension=php_pdo_firebird.dll
;extension=php_pdo_mssql.dll
;extension=php_pdo_mysql.dll
;extension=php_pdo_oci.dll
;extension=php_pdo_oci8.dll
;extension=php_pdo_odbc.dll
;extension=php_pdo_pgsql.dll
;extension=php_pdo_sqlite.dll
;extension=php_pgsql.dll
;extension=php_pspell.dll
;extension=php_shmop.dll
;extension=php_snmp.dll
;extension=php_soap.dll
;extension=php_sockets.dll
;extension=php_sqlite.dll
;extension=php_sybase_ct.dll
;extension=php_tidy.dll
;extension=php_xmlrpc.dll
;extension=php_xsl.dll
;extension=php_zip.dll

;;;;;;;;;;;;;;;;;;;
; Module Settings ;
;;;;;;;;;;;;;;;;;;;

[Date]
; Defines the default timezone used by the date functions
;date.timezone =

;date.default_latitude = 31.7667
;date.default_longitude = 35.2333

;date.sunrise_zenith = 90.583333
;date.sunset_zenith = 90.583333

[filter]
;filter.default = unsafe_raw
;filter.default_flags =

[iconv]
;iconv.input_encoding = ISO-8859-1
;iconv.internal_encoding = ISO-8859-1
;iconv.output_encoding = ISO-8859-1

[sqlite]
;sqlite.assoc_case = 0

[Pcre]
;PCRE library backtracking limit.
;pcre.backtrack_limit=100000

;PCRE library recursion limit. 
;Please note that if you set this value to a high number you may consume all 
;the available process stack and eventually crash PHP (due to reaching the 
;stack size limit imposed by the Operating System).
;pcre.recursion_limit=100000

[Syslog]
; Whether or not to define the various syslog variables (e.g. \$LOG_PID,
; \$LOG_CRON, etc.).  Turning it off is a good idea performance-wise.  In
; runtime, you can define these variables by calling define_syslog_variables().
define_syslog_variables  = Off

[mail function]
; For Win32 only.
SMTP = localhost
smtp_port = 25

; For Win32 only.
;sendmail_from = me@example.com

; For Unix only.  You may supply arguments as well (default: "sendmail -t -i").
;sendmail_path =

; Force the addition of the specified parameters to be passed as extra parameters
; to the sendmail binary. These parameters will always replace the value of
; the 5th parameter to mail(), even in safe mode.
;mail.force_extra_parameters =

[SQL]
sql.safe_mode = Off

[ODBC]
;odbc.default_db    =  Not yet implemented
;odbc.default_user  =  Not yet implemented
;odbc.default_pw    =  Not yet implemented

; Allow or prevent persistent links.
odbc.allow_persistent = On

; Check that a connection is still valid before reuse.
odbc.check_persistent = On

; Maximum number of persistent links.  -1 means no limit.
odbc.max_persistent = -1

; Maximum number of links (persistent + non-persistent).  -1 means no limit.
odbc.max_links = -1

; Handling of LONG fields.  Returns number of bytes to variables.  0 means
; passthru.
odbc.defaultlrl = 4096

; Handling of binary data.  0 means passthru, 1 return as is, 2 convert to char.
; See the documentation on odbc_binmode and odbc_longreadlen for an explanation
; of uodbc.defaultlrl and uodbc.defaultbinmode
odbc.defaultbinmode = 1

[MySQL]
; Allow or prevent persistent links.
mysql.allow_persistent = On

; Maximum number of persistent links.  -1 means no limit.
mysql.max_persistent = -1

; Maximum number of links (persistent + non-persistent).  -1 means no limit.
mysql.max_links = -1

; Default port number for mysql_connect().  If unset, mysql_connect() will use
; the \$MYSQL_TCP_PORT or the mysql-tcp entry in /etc/services or the
; compile-time value defined MYSQL_PORT (in that order).  Win32 will only look
; at MYSQL_PORT.
mysql.default_port =

; Default socket name for local MySQL connects.  If empty, uses the built-in
; MySQL defaults.
mysql.default_socket =

; Default host for mysql_connect() (doesn't apply in safe mode).
mysql.default_host =

; Default user for mysql_connect() (doesn't apply in safe mode).
mysql.default_user =

; Default password for mysql_connect() (doesn't apply in safe mode).
; Note that this is generally a *bad* idea to store passwords in this file.
; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
; and reveal this password!  And of course, any users with read access to this
; file will be able to reveal the password as well.
mysql.default_password =

; Maximum time (in seconds) for connect timeout. -1 means no limit
mysql.connect_timeout = 60

; Trace mode. When trace_mode is active (=On), warnings for table/index scans and
; SQL-Errors will be displayed.
mysql.trace_mode = Off

[MySQLi]

; Maximum number of links.  -1 means no limit.
mysqli.max_links = -1

; Default port number for mysqli_connect().  If unset, mysqli_connect() will use
; the \$MYSQL_TCP_PORT or the mysql-tcp entry in /etc/services or the
; compile-time value defined MYSQL_PORT (in that order).  Win32 will only look
; at MYSQL_PORT.
mysqli.default_port = 3306

; Default socket name for local MySQL connects.  If empty, uses the built-in
; MySQL defaults.
mysqli.default_socket =

; Default host for mysql_connect() (doesn't apply in safe mode).
mysqli.default_host =

; Default user for mysql_connect() (doesn't apply in safe mode).
mysqli.default_user =

; Default password for mysqli_connect() (doesn't apply in safe mode).
; Note that this is generally a *bad* idea to store passwords in this file.
; *Any* user with PHP access can run 'echo get_cfg_var("mysqli.default_pw")
; and reveal this password!  And of course, any users with read access to this
; file will be able to reveal the password as well.
mysqli.default_pw =

; Allow or prevent reconnect
mysqli.reconnect = Off

[mSQL]
; Allow or prevent persistent links.
msql.allow_persistent = On

; Maximum number of persistent links.  -1 means no limit.
msql.max_persistent = -1

; Maximum number of links (persistent+non persistent).  -1 means no limit.
msql.max_links = -1

[OCI8]
; enables privileged connections using external credentials (OCI_SYSOPER, OCI_SYSDBA)
;oci8.privileged_connect = Off

; Connection: The maximum number of persistent OCI8 connections per
; process. Using -1 means no limit.
;oci8.max_persistent = -1

; Connection: The maximum number of seconds a process is allowed to
; maintain an idle persistent connection. Using -1 means idle
; persistent connections will be maintained forever.
;oci8.persistent_timeout = -1

; Connection: The number of seconds that must pass before issuing a
; ping during oci_pconnect() to check the connection validity. When
; set to 0, each oci_pconnect() will cause a ping. Using -1 disables
; pings completely.
;oci8.ping_interval = 60

; Tuning: This option enables statement caching, and specifies how
; many statements to cache. Using 0 disables statement caching.
;oci8.statement_cache_size = 20

; Tuning: Enables statement prefetching and sets the default number of
; rows that will be fetched automatically after statement execution.
;oci8.default_prefetch = 10

; Compatibility. Using On means oci_close() will not close
; oci_connect() and oci_new_connect() connections.
;oci8.old_oci_close_semantics = Off

[PostgresSQL]
; Allow or prevent persistent links.
pgsql.allow_persistent = On

; Detect broken persistent links always with pg_pconnect().
; Auto reset feature requires a little overheads.
pgsql.auto_reset_persistent = Off

; Maximum number of persistent links.  -1 means no limit.
pgsql.max_persistent = -1

; Maximum number of links (persistent+non persistent).  -1 means no limit.
pgsql.max_links = -1

; Ignore PostgreSQL backends Notice message or not.
; Notice message logging require a little overheads.
pgsql.ignore_notice = 0

; Log PostgreSQL backends Notice message or not.
; Unless pgsql.ignore_notice=0, module cannot log notice message.
pgsql.log_notice = 0

[Sybase]
; Allow or prevent persistent links.
sybase.allow_persistent = On

; Maximum number of persistent links.  -1 means no limit.
sybase.max_persistent = -1

; Maximum number of links (persistent + non-persistent).  -1 means no limit.
sybase.max_links = -1

;sybase.interface_file = "/usr/sybase/interfaces"

; Minimum error severity to display.
sybase.min_error_severity = 10

; Minimum message severity to display.
sybase.min_message_severity = 10

; Compatibility mode with old versions of PHP 3.0.
; If on, this will cause PHP to automatically assign types to results according
; to their Sybase type, instead of treating them all as strings.  This
; compatibility mode will probably not stay around forever, so try applying
; whatever necessary changes to your code, and turn it off.
sybase.compatability_mode = Off

[Sybase-CT]
; Allow or prevent persistent links.
sybct.allow_persistent = On

; Maximum number of persistent links.  -1 means no limit.
sybct.max_persistent = -1

; Maximum number of links (persistent + non-persistent).  -1 means no limit.
sybct.max_links = -1

; Minimum server message severity to display.
sybct.min_server_severity = 10

; Minimum client message severity to display.
sybct.min_client_severity = 10

[bcmath]
; Number of decimal digits for all bcmath functions.
bcmath.scale = 0

[browscap]
;browscap = extra/browscap.ini

[Informix]
; Default host for ifx_connect() (doesn't apply in safe mode).
ifx.default_host =

; Default user for ifx_connect() (doesn't apply in safe mode).
ifx.default_user =

; Default password for ifx_connect() (doesn't apply in safe mode).
ifx.default_password =

; Allow or prevent persistent links.
ifx.allow_persistent = On

; Maximum number of persistent links.  -1 means no limit.
ifx.max_persistent = -1

; Maximum number of links (persistent + non-persistent).  -1 means no limit.
ifx.max_links = -1

; If on, select statements return the contents of a text blob instead of its id.
ifx.textasvarchar = 0

; If on, select statements return the contents of a byte blob instead of its id.
ifx.byteasvarchar = 0

; Trailing blanks are stripped from fixed-length char columns.  May help the
; life of Informix SE users.
ifx.charasvarchar = 0

; If on, the contents of text and byte blobs are dumped to a file instead of
; keeping them in memory.
ifx.blobinfile = 0

; NULL's are returned as empty strings, unless this is set to 1.  In that case,
; NULL's are returned as string 'NULL'.
ifx.nullformat = 0

[Session]
; Handler used to store/retrieve data.
session.save_handler = files

; Argument passed to save_handler.  In the case of files, this is the path
; where data files are stored. Note: Windows users have to change this
; variable in order to use PHP's session functions.
;
; As of PHP 4.0.1, you can define the path as:
;
;     session.save_path = "N;/path"
;
; where N is an integer.  Instead of storing all the session files in
; /path, what this will do is use subdirectories N-levels deep, and
; store the session data in those directories.  This is useful if you
; or your OS have problems with lots of files in one directory, and is
; a more efficient layout for servers that handle lots of sessions.
;
; NOTE 1: PHP will not create this directory structure automatically.
;         You can use the script in the ext/session dir for that purpose.
; NOTE 2: See the section on garbage collection below if you choose to
;         use subdirectories for session storage
;
; The file storage module creates files using mode 600 by default.
; You can change that by using
;
;     session.save_path = "N;MODE;/path"
;
; where MODE is the octal representation of the mode. Note that this
; does not overwrite the process's umask.
;session.save_path = "/tmp"

; Whether to use cookies.
session.use_cookies = 1

;session.cookie_secure = 

; This option enables administrators to make their users invulnerable to
; attacks which involve passing session ids in URLs; defaults to 0.
; session.use_only_cookies = 1

; Name of the session (used as cookie name).
session.name = PHPSESSID

; Initialize session on request startup.
session.auto_start = 0

; Lifetime in seconds of cookie or, if 0, until browser is restarted.
session.cookie_lifetime = 0

; The path for which the cookie is valid.
session.cookie_path = /

; The domain for which the cookie is valid.
session.cookie_domain =

; Whether or not to add the httpOnly flag to the cookie, which makes it inaccessible to browser scripting languages such as JavaScript.
session.cookie_httponly = 

; Handler used to serialize data.  php is the standard serializer of PHP.
session.serialize_handler = php

; Define the probability that the 'garbage collection' process is started
; on every session initialization.
; The probability is calculated by using gc_probability/gc_divisor,
; e.g. 1/100 means there is a 1% chance that the GC process starts
; on each request.

session.gc_probability = 1
session.gc_divisor     = 100

; After this number of seconds, stored data will be seen as 'garbage' and
; cleaned up by the garbage collection process.
session.gc_maxlifetime = 1440

; NOTE: If you are using the subdirectory option for storing session files
;       (see session.save_path above), then garbage collection does *not*
;       happen automatically.  You will need to do your own garbage
;       collection through a shell script, cron entry, or some other method.
;       For example, the following script would is the equivalent of
;       setting session.gc_maxlifetime to 1440 (1440 seconds = 24 minutes):
;          cd /path/to/sessions; find -cmin +24 | xargs rm

; PHP 4.2 and less have an undocumented feature/bug that allows you to
; to initialize a session variable in the global scope, albeit register_globals
; is disabled.  PHP 4.3 and later will warn you, if this feature is used.
; You can disable the feature and the warning separately. At this time,
; the warning is only displayed, if bug_compat_42 is enabled.

session.bug_compat_42 = 1
session.bug_compat_warn = 1

; Check HTTP Referer to invalidate externally stored URLs containing ids.
; HTTP_REFERER has to contain this substring for the session to be
; considered as valid.
session.referer_check =

; How many bytes to read from the file.
session.entropy_length = 0

; Specified here to create the session id.
session.entropy_file =

;session.entropy_length = 16

;session.entropy_file = /dev/urandom

; Set to {nocache,private,public,} to determine HTTP caching aspects
; or leave this empty to avoid sending anti-caching headers.
session.cache_limiter = nocache

; Document expires after n minutes.
session.cache_expire = 180

; trans sid support is disabled by default.
; Use of trans sid may risk your users security.
; Use this option with caution.
; - User may send URL contains active session ID
;   to other person via. email/irc/etc.
; - URL that contains active session ID may be stored
;   in publically accessible computer.
; - User may access your site with the same session ID
;   always using URL stored in browser's history or bookmarks.
session.use_trans_sid = 0

; Select a hash function
; 0: MD5   (128 bits)
; 1: SHA-1 (160 bits)
session.hash_function = 0

; Define how many bits are stored in each character when converting
; the binary hash data to something readable.
;
; 4 bits: 0-9, a-f
; 5 bits: 0-9, a-v
; 6 bits: 0-9, a-z, A-Z, "-", ","
session.hash_bits_per_character = 4

; The URL rewriter will look for URLs in a defined set of HTML tags.
; form/fieldset are special; if you include them here, the rewriter will
; add a hidden <input> field with the info which is otherwise appended
; to URLs.  If you want XHTML conformity, remove the form entry.
; Note that all valid entries require a "=", even if no value follows.
url_rewriter.tags = "a=href,area=href,frame=src,input=src,form=,fieldset="

[MSSQL]
; Allow or prevent persistent links.
mssql.allow_persistent = On

; Maximum number of persistent links.  -1 means no limit.
mssql.max_persistent = -1

; Maximum number of links (persistent+non persistent).  -1 means no limit.
mssql.max_links = -1

; Minimum error severity to display.
mssql.min_error_severity = 10

; Minimum message severity to display.
mssql.min_message_severity = 10

; Compatibility mode with old versions of PHP 3.0.
mssql.compatability_mode = Off

; Connect timeout
;mssql.connect_timeout = 5

; Query timeout
;mssql.timeout = 60

; Valid range 0 - 2147483647.  Default = 4096.
;mssql.textlimit = 4096

; Valid range 0 - 2147483647.  Default = 4096.
;mssql.textsize = 4096

; Limits the number of records in each batch.  0 = all records in one batch.
;mssql.batchsize = 0

; Specify how datetime and datetim4 columns are returned
; On => Returns data converted to SQL server settings
; Off => Returns values as YYYY-MM-DD hh:mm:ss
;mssql.datetimeconvert = On

; Use NT authentication when connecting to the server
mssql.secure_connection = Off

; Specify max number of processes. -1 = library default
; msdlib defaults to 25
; FreeTDS defaults to 4096
;mssql.max_procs = -1

; Specify client character set. 
; If empty or not set the client charset from freetds.comf is used
; This is only used when compiled with FreeTDS
;mssql.charset = "ISO-8859-1"

[Assertion]
; Assert(expr); active by default.
;assert.active = On

; Issue a PHP warning for each failed assertion.
;assert.warning = On

; Don't bail out by default.
;assert.bail = Off

; User-function to be called if an assertion fails.
;assert.callback = 0

; Eval the expression with current error_reporting().  Set to true if you want
; error_reporting(0) around the eval().
;assert.quiet_eval = 0

[COM]
; path to a file containing GUIDs, IIDs or filenames of files with TypeLibs
;com.typelib_file =
; allow Distributed-COM calls
;com.allow_dcom = true
; autoregister constants of a components typlib on com_load()
;com.autoregister_typelib = true
; register constants casesensitive
;com.autoregister_casesensitive = false
; show warnings on duplicate constant registrations
;com.autoregister_verbose = true

[mbstring]
; language for internal character representation.
;mbstring.language = Japanese

; internal/script encoding.
; Some encoding cannot work as internal encoding.
; (e.g. SJIS, BIG5, ISO-2022-*)
;mbstring.internal_encoding = EUC-JP

; http input encoding.
;mbstring.http_input = auto

; http output encoding. mb_output_handler must be
; registered as output buffer to function
;mbstring.http_output = SJIS

; enable automatic encoding translation according to
; mbstring.internal_encoding setting. Input chars are
; converted to internal encoding by setting this to On.
; Note: Do _not_ use automatic encoding translation for
;       portable libs/applications.
;mbstring.encoding_translation = Off

; automatic encoding detection order.
; auto means
;mbstring.detect_order = auto

; substitute_character used when character cannot be converted
; one from another
;mbstring.substitute_character = none;

; overload(replace) single byte functions by mbstring functions.
; mail(), ereg(), etc are overloaded by mb_send_mail(), mb_ereg(),
; etc. Possible values are 0,1,2,4 or combination of them.
; For example, 7 for overload everything.
; 0: No overload
; 1: Overload mail() function
; 2: Overload str*() functions
; 4: Overload ereg*() functions
;mbstring.func_overload = 0

[FrontBase]
;fbsql.allow_persistent = On
;fbsql.autocommit = On
;fbsql.show_timestamp_decimals = Off
;fbsql.default_database =
;fbsql.default_database_password =
;fbsql.default_host =
;fbsql.default_password =
;fbsql.default_user = "_SYSTEM"
;fbsql.generate_warnings = Off
;fbsql.max_connections = 128
;fbsql.max_links = 128
;fbsql.max_persistent = -1
;fbsql.max_results = 128

[gd]
; Tell the jpeg decode to libjpeg warnings and try to create
; a gd image. The warning will then be displayed as notices
; disabled by default
;gd.jpeg_ignore_warning = 0

[exif]
; Exif UNICODE user comments are handled as UCS-2BE/UCS-2LE and JIS as JIS.
; With mbstring support this will automatically be converted into the encoding
; given by corresponding encode setting. When empty mbstring.internal_encoding
; is used. For the decode settings you can distinguish between motorola and
; intel byte order. A decode setting cannot be empty.
;exif.encode_unicode = ISO-8859-15
;exif.decode_unicode_motorola = UCS-2BE
;exif.decode_unicode_intel    = UCS-2LE
;exif.encode_jis =
;exif.decode_jis_motorola = JIS
;exif.decode_jis_intel    = JIS

[Tidy]
; The path to a default tidy configuration file to use when using tidy
;tidy.default_config = /usr/local/lib/php/default.tcfg

; Should tidy clean and repair output automatically?
; WARNING: Do not use this option if you are generating non-html content
; such as dynamic images
tidy.clean_output = Off

[soap]
; Enables or disables WSDL caching feature.
soap.wsdl_cache_enabled=1
; Sets the directory name where SOAP extension will put cache files.
soap.wsdl_cache_dir="/tmp"
; (time to live) Sets the number of second while cached file will be used 
; instead of original one.
soap.wsdl_cache_ttl=86400

; Local Variables:
; tab-width: 4
; End:
extension = "memcache.so"
extension = "pdo.so"
extension = "pdo_mysql.so"
extension = "pdo_sqlite.so"
extension = "sqlite.so"
[ioncube]
zend_extension = "/usr/local/ioncube/ioncube_loader_lin_5.2.so"
EOF
}

modify_httpd_config_file()
{
mv /usr/local/apache/conf/httpd.conf /usr/local/apache/conf/httpd.conf.bak
mkdir /usr/local/apache/conf/vhosts
cat >>/usr/local/apache/conf/httpd.conf<<EOF
PidFile logs/httpd.pid
LockFile logs/accept.lock
ServerRoot "/usr/local/apache"
Listen 0.0.0.0:81
User nobody
Group nobody
ServerAdmin $serveradminemail
ServerName $servername

Timeout 300
KeepAlive Off
MaxKeepAliveRequests 100
KeepAliveTimeout 5
UseCanonicalName Off
AccessFileName .htaccess
TraceEnable Off
ServerTokens ProductOnly
FileETag None
ServerSignature Off
HostnameLookups Off

# LoadModule perl_module modules/mod_perl.so
LoadModule php5_module        modules/libphp5.so
LoadModule rpaf_module        modules/mod_rpaf-2.0.so
#Mod_rpaf settings

RPAFenable On

RPAFproxy_ips $ipaddress

RPAFsethostname On

RPAFheader X-Forwarded-For

DocumentRoot "/usr/local/apache/htdocs"

<Directory "/">
 Options ExecCGI FollowSymLinks Includes IncludesNOEXEC -Indexes -MultiViews SymLinksIfOwnerMatch
 Order allow,deny
 Allow from all
 AllowOverride All
</Directory>

<Directory "/usr/local/apache/htdocs">
 Options Includes -Indexes FollowSymLinks
 AllowOverride None
 Order allow,deny
 Allow from all
</Directory>

DefaultType text/plain
RewriteEngine on
AddType text/html .shtml
AddHandler cgi-script .cgi .pl .plx .ppl .perl
AddHandler server-parsed .shtml
<IfModule mime_module>

    TypesConfig conf/mime.types
    AddType application/perl .pl .plx .ppl .perl
    AddType application/x-img .img
    AddType application/x-httpd-php .php .php3 .php4 .php5 .php6
    AddType application/x-httpd-php-source .phps
    AddType application/cgi .cgi
    AddType text/x-sql .sql
    AddType text/x-log .log
    AddType text/x-config .cnf conf
    AddType text/x-registry .reg
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddType application/x-tar .tgz
    AddType application/rar .rar
    AddType application/x-compressed .rar
    AddType application/x-rar .rar
    AddType application/x-rar-compressed .rar
    AddType text/vnd.wap.wml .wml
    AddType image/vnd.wap.wbmp .wbmp
    AddType text/vnd.wap.wmlscript .wmls
    AddType application/vnd.wap.wmlc .wmlc
    AddType application/vnd.wap.wmlscriptc .wmlsc
</IfModule>

<IfModule dir_module>
 DirectoryIndex index.html index.htm index.shtml index.php index.perl index.pl index.cgi
</IfModule>

<Files ~ "^error_log\$">
 Order allow,deny
 Deny from all

 Satisfy All
</Files>

<FilesMatch "^\.ht">
 Order allow,deny
 Deny from all
 Satisfy All
</FilesMatch>

ErrorLog "logs/error_log"
LogLevel warn

<IfModule log_config_module>
 LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
 LogFormat "%h %l %u %t \"%r\" %>s %b" common

 <IfModule logio_module>

 LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
 </IfModule>
 CustomLog "logs/access_log" common
</IfModule>

<IfModule alias_module>
 ScriptAlias /cgi-bin/ "/usr/local/apache/cgi-bin/"
</IfModule>

<Directory "/usr/local/apache/cgi-bin">
 AllowOverride None
 Options None
 Order allow,deny
 Allow from all
</Directory>

<IfModule mpm_prefork_module>
 StartServers          3
 MinSpareServers       3
 MaxSpareServers       5
 MaxClients          150
 MaxRequestsPerChild   1024
</IfModule>

<IfModule mod_headers.c>
<FilesMatch "\.(html|htm|shtml)\$">

Header set Cache-Control "max-age=3600, must-revalidate"
</FilesMatch>
</IfModule>

ReadmeName README.html
HeaderName HEADER.html

IndexIgnore .??* *~ *# HEADER* README* RCS CVS *,v *,t

Include conf/extra/httpd-languages.conf

<Location /server-status>
 SetHandler server-status
 Order deny,allow
 Deny from all
 Allow from $ipaddress
</Location>

ExtendedStatus On

<Location /server-info>
 SetHandler server-info
 Order deny,allow
 Deny from all
 Allow from $ipaddress

</Location>

<IfModule ssl_module>
Listen 0.0.0.0:443
AddType application/x-x509-ca-cert .crt
AddType application/x-pkcs7-crl .crl
SSLCipherSuite ALL:!ADH:+HIGH:+MEDIUM:-LOW:-SSLv2:-EXP
SSLPassPhraseDialog  builtin
SSLSessionCache         dbm:/usr/local/apache/logs/ssl_scache
SSLSessionCacheTimeout  300
SSLMutex  file:/usr/local/apache/logs/ssl_mutex
SSLRandomSeed startup builtin
SSLRandomSeed connect builtin
</IfModule>

#Vhosts
NameVirtualHost $ipaddress:81
NameVirtualHost *

<VirtualHost $ipaddress:81 *>
 ServerName $servername
 DocumentRoot /var/www/html
 ServerAdmin $serveradminemail
</VirtualHost>

Include conf/vhosts/*
EOF
}

create_httpd_start_file()
{
mv /etc/init.d/httpd /etc/init.d/httpd.bak
cat >>/etc/init.d/httpd<<EOF
#!/bin/sh
# Startup script for the Apache Web Server
#
# chkconfig: - 85 15
# description: Apache is a World Wide Web server. It is used to serve \
# HTML files and CGI.
# processname: httpd
# pidfile: /usr/local/apache/logs/httpd.pid
# config: /usr/local/apache/conf/httpd.conf
ulimit -n 1024
ulimit -n 4096
ulimit -n 8192
ulimit -n 16384
ulimit -n 32768
ulimit -n 65535
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# Apache control script designed to allow an easy command line interface
# to controlling Apache.  Written by Marc Slemko, 1997/08/23
# 
# The exit codes returned are:
#   XXX this doc is no longer correct now that the interesting
#   XXX functions are handled by httpd
#	0 - operation completed successfully
#	1 - 
#	2 - usage error
#	3 - httpd could not be started
#	4 - httpd could not be stopped
#	5 - httpd could not be started during a restart
#	6 - httpd could not be restarted during a restart
#	7 - httpd could not be restarted during a graceful restart
#	8 - configuration syntax error
#
# When multiple arguments are given, only the error from the _last_
# one is reported.  Run "apachectl help" for usage info
#
ARGV="\$@"
#
# |||||||||||||||||||| START CONFIGURATION SECTION  ||||||||||||||||||||
# --------------------                              --------------------
# 
# the path to your httpd binary, including options if necessary
HTTPD='/usr/local/apache/bin/httpd'
#
# pick up any necessary environment variables
if test -f /usr/local/apache/bin/envvars; then
  . /usr/local/apache/bin/envvars
fi
#
# a command that outputs a formatted text version of the HTML at the
# url given on the command line.  Designed for lynx, however other
# programs may work.  
LYNX="lynx -dump"
#
# the URL to your server's mod_status status page.  If you do not
# have one, then status and fullstatus will not work.
STATUSURL="http://localhost:80/server-status"
#
# Set this variable to a command that increases the maximum
# number of file descriptors allowed per child process. This is
# critical for configurations that use many file descriptors,
# such as mass vhosting, or a multithreaded server.
ULIMIT_MAX_FILES="ulimit -S -n `ulimit -H -n`"
# --------------------                              --------------------
# ||||||||||||||||||||   END CONFIGURATION SECTION  ||||||||||||||||||||

# Set the maximum number of file descriptors allowed per child process.
if [ "x\$ULIMIT_MAX_FILES" != "x" ] ; then
    \$ULIMIT_MAX_FILES
fi

ERROR=0
if [ "x\$ARGV" = "x" ] ; then 
    ARGV="-h"
fi

case \$ARGV in
start|stop|restart|graceful|graceful-stop)
    \$HTTPD -k \$ARGV
    ERROR=\$?
    ;;
startssl|sslstart|start-SSL)
    echo The startssl option is no longer supported.
    echo Please edit httpd.conf to include the SSL configuration settings
    echo and then use "apachectl start".
    ERROR=2
    ;;
configtest)
    \$HTTPD -t
    ERROR=\$?
    ;;
status)
    \$LYNX \$STATUSURL | awk ' /process\$/ { print; exit } { print } '
    ;;
fullstatus)
    \$LYNX \$STATUSURL
    ;;
*)
    \$HTTPD \$ARGV
    ERROR=\$?
esac

exit \$ERROR
EOF

chmod +x /etc/init.d/httpd
}

modify_nginx_config_file()
{
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
mkdir /usr/local/nginx/conf/vhosts
cat >>/usr/local/nginx/conf/nginx.conf<<EOF
worker_processes  1;
worker_rlimit_nofile  65535;
events {
 worker_connections  65535;
 use epoll;
}
error_log  /usr/local/nginx/logs/error.log info;
http {
 include    mime.types;
 default_type  application/octet-stream;
 sendfile on;
 tcp_nopush on;
 tcp_nodelay on;
 keepalive_timeout  10;
 gzip on;
 gzip_http_version 1.0;
 gzip_min_length  1100;
 gzip_comp_level  3;
 gzip_buffers  4 32k;
 gzip_types    text/plain text/xml text/css application/x-javascript application/xml application/xml+rss text/javascript application/atom+xml;
 ignore_invalid_headers on;
 client_header_timeout  3m;
 client_body_timeout 3m;
 send_timeout     3m;
 connection_pool_size  256;
 server_names_hash_max_size 2048;
 server_names_hash_bucket_size 256;
 client_header_buffer_size 256k;
 large_client_header_buffers 4 256k;
 request_pool_size  32k;
 output_buffers   4 64k;
 postpone_output  1460;
 open_file_cache max=1000 inactive=300s;
 open_file_cache_valid    600s;
 open_file_cache_min_uses 2;
 open_file_cache_errors   off;
 include "/usr/local/nginx/conf/vhosts/*.conf";
 server {
 listen 80;
 server_name _;
 root /var/www/html;
 access_log off;
 location ~ .*\.(jpg|jpeg|png|gif|bmp|ico|js|css|mp3|wav|swf|mov|doc|pdf|xls|ppt|docx|pptx|xlsx)\$ {
 expires 7d;
 }
 location ~* \.(ftpquota|htaccess|asp|aspx|jsp|asa|mdb)\$ {
 deny  all;
 }
 location / {
 client_max_body_size    100m;
 client_body_buffer_size 128k;
 proxy_send_timeout   300;
 proxy_read_timeout   300;
 proxy_buffer_size    4k;
 proxy_buffers     16 32k;
 proxy_busy_buffers_size 64k;
 proxy_temp_file_write_size 64k;
 proxy_connect_timeout 30s;
 proxy_pass http://$ipaddress:81/;
 proxy_set_header   Host   \$host;
 proxy_set_header   X-Real-IP  \$remote_addr;
 proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
 }
 }
}
EOF
}

create_nginx_start_file()
{
cat >>/etc/init.d/nginx<<EOF
#! /bin/sh
ulimit -n 65535
# Description: Startup script for nginx
# chkconfig: 2345 55 25

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="nginx daemon"
NAME=nginx
DAEMON=/usr/local/nginx/sbin/\$NAME
CONFIGFILE=/usr/local/nginx/conf/nginx.conf
PIDFILE=/usr/local/nginx/logs/\$NAME.pid
SCRIPTNAME=/etc/init.d/\$NAME

set -e
[ -x "\$DAEMON" ] || exit 0

do_start() {
 \$DAEMON -c \$CONFIGFILE || echo -n "nginx already running"
}

do_stop() {
 kill -QUIT \`cat \$PIDFILE\` || echo -n "nginx not running"
}

do_reload() {
 kill -HUP \`cat \$PIDFILE\` || echo -n "nginx can't reload"
}

case "\$1" in
 start)
 echo -n "Starting \$DESC: \$NAME"
 do_start
 echo "."
 /etc/init.d/httpd start
 ;;
 stop)
 echo -n "Stopping \$DESC: \$NAME"
 do_stop
 echo "."
 /etc/init.d/httpd stop
 ;;
 reload)
 echo -n "Reloading \$DESC configuration..."
 do_reload
 echo "."
 /etc/init.d/httpd restart
 ;;
 restart)
 echo -n "Restarting \$DESC: \$NAME"
 do_stop
 sleep 1
 do_start
 echo "."
 /etc/init.d/httpd restart
 ;;
 *)
 echo "Usage: \$SCRIPTNAME {start|stop|reload|restart}" >&2
 exit 3
 ;;
esac

exit 0
EOF

chmod u+x /etc/init.d/nginx

chkconfig --level 345 nginx on
}

modify_permission()
{
chmod -R 755 /var/www/html
chmod 711 /home
chmod 711 /usr/local/apache/conf/vhosts
chmod 711 /usr/local/nginx/conf/vhosts
chmod 711 /usr/local/apache/domlogs
chmod 711 /usr/local/apache/logs
}
create_default_page()
{
cat >>/var/www/html/index.html<<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml"> 
<head> 
<title>LNAMP Script by hopol.googlecode.com</title> 
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<meta name="author" content="hopol.googlecode.com"> 
<meta name="keywords" content="LNAMP,LNAMP Shell Script"> 
<meta name="description" content="Installing LNAMP Successfully!"> 
</head> 
<body>
This is the default page for <a href="hopol.googlecode.com">LNAMP</a>.</br>
You can replace it.<br>
For any queries please contact me.</br>
</body>
</html>
EOF
}
echo "Press any key to start..."
char=`get_char`

init

remove_installed

yum -y install yum-fastestmirror
yum -y update

rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
yum install -y ntp
ntpdate -d cn.pool.ntp.org
date

yum -y install patch make gcc gcc-c++ gcc-g77 flex bison file
yum -y install libtool libtool-libs autoconf kernel-devel
yum -y install libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel
yum -y install freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel
yum -y install glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel
yum -y install ncurses ncurses-devel curl curl-devel e2fsprogs
yum -y install e2fsprogs-devel krb5 krb5-devel libidn libidn-devel
yum -y install openssl openssl-devel vim-minimal nano sendmail
yum -y install fonts-chinese gettext gettext-devel
yum -y install ncurses-devel
yum -y install gmp-devel pspell-devel
yum -y install unzip
yum -y install expat-devel

install_mysql

install_httpd

install_php

install_php_ext

install_pcre

install_nginx

install_rpaf_module

modify_mysql_pwd

modify_php_config_file

modify_httpd_config_file

modify_nginx_config_file

create_httpd_start_file

create_nginx_start_file

install_phpmyadmin

install_php_iprober

modify_permission

service mysql start

service nginx start

create_default_page
clear
echo ""
echo " ******************************************************************************"
echo " *                      For any queries please contact me                     *"
echo " ******************************************************************************"
echo ""
echo ""
echo " ******************************************************************************"
echo " *        Apache configuration file:/usr/local/apache2/conf/httpd.conf        *"
echo " *          Nginx configuration file:/usr/local/nginx/conf/nginx.conf         *"
echo " * Apache virtual host configuration file:/usr/local/apache2/conf/httpd.conf  *"
echo " *  Nginx virtual host configuration file:/usr/local/apache2/conf/httpd.conf  *"
echo " *                   phpMyAdmin:http://$ipaddress/phpmyadmin                  *"
echo " *                    PHP Prober:http://$ipaddress/p.php                      *"
echo " ******************************************************************************"
echo ""