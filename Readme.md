1. 安装Docker

 [install-docker.sh](install-docker.sh) 

2. 创建用户

 [create-sudo-user.sh](create-sudo-user.sh) 

3. 常用命令

   sudo systemctl status CQTS2Monitor.service
   sudo systemctl stop CQTS2Monitor.service
   sudo systemctl start CQTS2Monitor.service

   sudo journalctl -u CQTS2Monitor -f


   sudo systemctl status CQTS2Web.service
   sudo systemctl stop CQTS2Web.service
   sudo systemctl start CQTS2Web.service

   sudo journalctl -u CQTS2Web -f

   sudo systemctl status mihomo.service
   sudo systemctl stop mihomo.service
   sudo systemctl start mihomo.service

   sudo journalctl -u mihomo -f
   sudo journalctl -u mihomo -b