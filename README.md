@@@@@@@@@@@@ LNAMPһ����װ�� [��ذ�] @@@@@@@@@@@@ ��Ϊ�����Զ��ǧ����á�

Apache configuration file:/usr/local/apache2/conf/httpd.conf

Nginx configuration file:/usr/local/nginx/conf/nginx.conf

Apache virtual host configuration file:/usr/local/apache2/conf/httpd.conf

Nginx virtual host configuration file:/usr/local/apache2/conf/httpd.conf

phpMyAdmin:http://.../phpmyadmin

PHP Prober:http://.../p.php

��װ���裺

1�� ����LNAMPһ����װ�� wget -c http://hopol.googlecode.com/files/LNAMP_1.0_final.tar.gz

2�� ��ѹtar zxvf LNAMP_1.0_final.tar.gz�������õ�CentOS��Debian��Ubuntu�������ļ��У����ݷ�����ѡ���ϵͳ�л�����ӦĿ¼�£�Ŀ¼�н�������ļ���main-install.sh�ǻ�����װ�ű���eaccelerator-install.sh�����ڰ�װeaccelerator����ZendOptimizer-install.sh�����ڰ�װZend Optimizer����pure-ftp-install.sh�����ڰ�װpureftpd���ǿ�ѡ�İ�װ�ű���setup-vhost.sh�����ڴ���virtual host�Ľű���

3�� ����main-install.sh��eaccelerator-install.sh��ZendOptimizer-install.sh��pure-ftp-install.sh��setup-vhost.sh ������ļ���ִ��Ȩ�ޣ�chmod +x .sh

4�� ִ�нű�./main-install.sh����ѡ��İ�װ�ű��������Զ���װ���ֳ���

��ϸ���裺

yum remove httpd

yum install screen

screen -S lnamp

wget -c http://hopol.googlecode.com/files/LNAMP_1.0_final.tar.gz

tar zxvf LNAMP_1.0_final.tar.gz

cd CentOS

chmod +x .sh

./main-install.sh

./eaccelerator-install.sh

./ZendOptimizer-install.sh <---�ǵ�ȥ���ʺ�

/root/CentOS/setup-vhost.sh

[�༭]��ι���

1��Nginx����/etc/init.d/nginx {start|restart|stop} ��ע��ִ��/etc/init.d/nginxʱ���httpd�����ã�

2��Apache����/etc/init.d/httpd {start|restart|stop}

3������pure-ftp��/usr/local/pureftpd/sbin/pure-config.pl /usr/local/pureftpd/etc/pure-ftpd.conf �Cdaemonize

4������virtual host��./setupvm-without-pure-ftp.sh����./setupvm-with-pure-ftp.sh������������ip��FTP�û����������Ϣ���ɡ�

5��PHP̽��URL��http://{your_ip_address}/p.php

6��phpMyAdmin URL��http://{your_ip_address}/phpmyadmin