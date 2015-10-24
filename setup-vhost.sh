#!/bin/sh
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
get_info()
{
user=""
echo "Please input FTP/Daemon user:"
read -p "(FTP/Daemon user):" user
if [ "$user" = "" ]; then
    echo "please enter your username!"
		exit 2
fi
if [ ! -e /home/$user ]; then
	  echo "***************************"
	  echo "FTP/Daemon user=$user"
	  echo "***************************" 
else
	  echo "***************************"
	  echo "$user is exist!"
	  echo "***************************"
	  exit 3	
fi
ip=""
read -p "(Main IP):" ip
if [ "$ip" = "" ]; then
    echo "please enter the IP address!"
		exit 4
fi
domain="www.lnamp.org"
read -p "(Domain with TLD):" domain
if [ "$domain" = "" ]; then
    echo "please enter your domain!"
		exit 5
fi
if [ ! -f "/usr/local/apache/conf/vhost/$domain.conf" ]; then
	  echo "***************************"
	  echo "Domain=$domain"
	  echo "***************************" 
else
	  echo "***************************"
	  echo "$domain is exist!"
	  echo "***************************"
	  exit 6	
fi
echo "Do you want to add more domain name? (y/n)"
read add_more_domainame

if [ "$add_more_domainame" == 'y' ]; then

	echo "Type domainname,example(bbs.18883.com forums.18883.com):"
	read moredomain
        echo "==========================="
        echo domain list="$moredomain"
        echo "==========================="
	moredomainame="$moredomain"
fi
echo "Hostname        : $domain"
echo "Main IP Address : $ip"
echo "Username        : $user"
}
setup_vhost_with_ftp_account()
{
useradd $user -m -s /sbin/nologin
mkdir -p /home/$user/public_html/cgi-bin
chmod 751 /home/$user
chown $user:$user /home/$user
chown $user:nobody /home/$user/public_html
pure-pw useradd $user -u $user -g $user -d /home/$user -m
if [ ! -d /usr/local/apache/conf/vhosts ]; then
  mkdir /usr/local/apache/conf/vhosts
fi
if [ ! -d /usr/local/nginx/conf/vhosts ]; then
  mkdir /usr/local/nginx/conf/vhosts
fi
cat >>/usr/local/apache/conf/vhosts/$domain.conf<<eof
<VirtualHost $ip:81>
 ServerName $domain
 ServerAlias www.$domain $moredomain
 DocumentRoot /home/$user/public_html
 ServerAdmin admin@$domain
 UseCanonicalName Off
 php_admin_value open_basedir "/home/$user:/usr/lib/php:/usr/local/lib/php:/tmp"
 <IfModule !mod_disable_suexec.c>
 SuexecUserGroup $user $user
 </IfModule>
 ScriptAlias /cgi-bin/ /home/$user/public_html/cgi-bin/
</VirtualHost>
eof
cat >>/usr/local/nginx/conf/vhosts/$domain.conf<<eof
server {
 error_log /usr/local/nginx/logs/$domain-error_log warn;
 listen $ip:80;
 server_name $domain www.$domain $moredomain;
 access_log off;
 location ~ .*\.(jpg|jpeg|png|gif|bmp|ico|js|css|mp3|wav|swf|mov|doc|pdf|xls|ppt|docx|pptx|xlsx)\$ {
 access_log /usr/local/apache/domlogs/$domain combined;
 root /home/$user/public_html;
 expires 7d;
 try_files \$uri @backend;
 }
 error_page 400 401 402 403 404 405 406 407 408 409 500 501 502 503 504 @backend;
 location @backend {
 internal;
 client_max_body_size    100m;
 client_body_buffer_size 128k;
 proxy_send_timeout   300;
 proxy_read_timeout   300;
 proxy_buffer_size    4k;
 proxy_buffers     16 32k;
 proxy_busy_buffers_size 64k;
 proxy_temp_file_write_size 64k;
 proxy_connect_timeout 30s;
 proxy_redirect http://$domain:81 http://$domain;
 proxy_redirect http://www.$domain:81 http://www.$domain;
 proxy_pass http://$ip:81;
 proxy_set_header   Host   \$host;
 proxy_set_header   X-Real-IP  \$remote_addr;
 proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
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
 proxy_redirect http://$domain:81 http://$domain;
 proxy_redirect http://www.$domain:81 http://www.$domain;
 proxy_pass http://$ip:81/;
 proxy_set_header   Host   \$host;
 proxy_set_header   X-Real-IP  \$remote_addr;
 proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
 }
}
eof
}
setup_vhost_without_ftp_account()
{
useradd $user -m -s /sbin/nologin
mkdir -p /home/$user/public_html/cgi-bin
chmod 751 /home/$user
chown $user:$user /home/$user
chown $user:nobody /home/$user/public_html
if [ ! -d /usr/local/apache/conf/vhosts ]; then
  mkdir /usr/local/apache/conf/vhosts
fi
cat >>/usr/local/apache/conf/vhosts/$domain.conf<<eof
<VirtualHost $ip:81>
 ServerName $domain
 ServerAlias www.$domain $moredomain
 DocumentRoot /home/$user/public_html
 ServerAdmin admin@$domain
 UseCanonicalName Off
 php_admin_value open_basedir "/home/$user:/usr/lib/php:/usr/local/lib/php:/tmp"
 <IfModule !mod_disable_suexec.c>
 SuexecUserGroup $user $user
 </IfModule>
 ScriptAlias /cgi-bin/ /home/$user/public_html/cgi-bin/
</VirtualHost>
eof
cat >>/usr/local/nginx/conf/vhosts/$domain.conf<<eof
server {
 error_log /usr/local/nginx/logs/$domain-error_log warn;
 listen $ip:80;
 server_name $domain www.$domain $moredomain;
 access_log off;
 location ~ .*\.(jpg|jpeg|png|gif|bmp|ico|js|css|mp3|wav|swf|mov|doc|pdf|xls|ppt|docx|pptx|xlsx)\$ {
 access_log /usr/local/apache/domlogs/$domain combined;
 root /home/$user/public_html;
 expires 7d;
 try_files \$uri @backend;
 }
 error_page 400 401 402 403 404 405 406 407 408 409 500 501 502 503 504 @backend;
 location @backend {
 internal;
 client_max_body_size    100m;
 client_body_buffer_size 128k;
 proxy_send_timeout   300;
 proxy_read_timeout   300;
 proxy_buffer_size    4k;
 proxy_buffers     16 32k;
 proxy_busy_buffers_size 64k;
 proxy_temp_file_write_size 64k;
 proxy_connect_timeout 30s;
 proxy_redirect http://$domain:81 http://$domain;
 proxy_redirect http://www.$domain:81 http://www.$domain;
 proxy_pass http://$ip:81;
 proxy_set_header   Host   \$host;
 proxy_set_header   X-Real-IP  \$remote_addr;
 proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
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
 proxy_redirect http://$domain:81 http://$domain;
 proxy_redirect http://www.$domain:81 http://www.$domain;
 proxy_pass http://$ip:81/;
 proxy_set_header   Host   \$host;
 proxy_set_header   X-Real-IP  \$remote_addr;
 proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
 }
}
eof
}

create_default_page()
{
cat >>/home/$user/public_html/index.html<<EOF
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
This is the default page for <a href="http://hopol.googlecode.com">LNAMP</a>.</br>
You can replace it.<br>
For any queries please contact me.</br>
</body>
</html>
EOF
}

usage()
{
  option="1"
  echo "Now you can setup virtual host as below:"
  echo "1. setup virtual host without using ftp service"
  echo "2. setup virtual host with ftp service"
  echo "Please input your option:"
  read -p "(Default option: $option):" temp
  if [ "$temp" != "" ]; then
    option=$temp
  fi
}
# root privilege is mandatory
if [ $(id -u) -ne 0 ]; then
  echo "Error: You must get root privilege at first."
  exit 1
fi

option=$1

if [ $# -ne 1 ]; then
	usage
fi

while [ $option != "1" -a $option != "2" ]
do
  usage
done

if [ $option = "1" ]; then
  get_info
  setup_vhost_without_ftp_account
  create_default_page
fi

if [ $option = "2" ]; then
  get_info
  echo -e "\033[7m"
  echo "********************************************************"
  echo "In the next step,you must enter the same password twice!"
  echo "********************************************************"
  echo -e "\033[0m"
  setup_vhost_with_ftp_account
  create_default_page
fi

/etc/init.d/nginx restart