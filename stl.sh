if [[ $EUID -ne 0 ]]; then
    clear
    echo "You should run this script with root!"
    echo "Use sudo -i to change user to root"
    exit 1
fi
Iran() {
  clear
  apt update && apt upgrade -y
  apt install stunnel4 openssl -y
  apt install certbot -y
  read -p "IP or Domain of kharej :" domainip
  read -p "Number of Inbounds you have got :" inbounds

cat <<EOL > /etc/stunnel/stunnel.conf
pid = /etc/stunnel/stunnel.pid
client = yes
output = /etc/stunnel/stunnel.log

EOL
for ((i=1; i<=inbounds; i++))
do
    read -p "Enter The Inboud port number :" port
    read -p "Enter The SSL Tunnel port number :" sslport
cat <<EOL >> /etc/stunnel/stunnel.conf    
[Inbound$i]
accept = $port
connect = $domainip:$sslport

EOL
done

cat <<EOL > /usr/lib/systemd/system/stunnel.service
[Unit]
Description=SSL tunnel for network daemons
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target
Alias=stunnel.target

[Service]
Type=forking
ExecStart=/usr/bin/stunnel /etc/stunnel/stunnel.conf
ExecStop=/usr/bin/pkill stunnel

# Give up if ping don't get an answer
TimeoutSec=600

Restart=always
PrivateTmp=false
EOL
    systemctl start stunnel.service
    service stunnel4 start
    systemctl enable stunnel.service
}

Kharej() {
  clear
  apt update && apt upgrade -y
  apt install stunnel4 openssl -y
  apt install certbot -y
  read -p "Number of Inbounds you have got :" inbounds

cat <<EOL > /etc/stunnel/stunnel.conf
cert = /etc/stunnel/stunnel.pem
pid = /etc/stunnel/stunnel.pid
output = /etc/stunnel/stunnel.log

EOL
for ((i=1; i<=inbounds; i++))
do
    read -p "Enter The Inboud port number :" port
    read -p "Enter The SSL Tunnel port number :" sslport
cat <<EOL >> /etc/stunnel/stunnel.conf    
[Inbound$i]
accept = $sslport
connect = 0.0.0.0:$port

EOL
done
read -p "Your Kharej domain for ssl :" domain
read -p "Your Email for SSL :" email
certbot certonly --standalone -d $domain --staple-ocsp -m $email --agree-tos
cd /etc/letsencrypt/live/$domain/
cat privkey.pem fullchain.pem >> /etc/stunnel/stunnel.pem
chmod 0400 /etc/stunnel/stunnel.pem

cat <<EOL > /usr/lib/systemd/system/stunnel.service
[Unit]
Description=SSL tunnel for network daemons
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target
Alias=stunnel.target

[Service]
Type=forking
ExecStart=/usr/bin/stunnel /etc/stunnel/stunnel.conf
ExecStop=/usr/bin/pkill stunnel

# Give up if ping don't get an answer
TimeoutSec=600

Restart=always
PrivateTmp=false
EOL

    systemctl start stunnel.service
    service stunnel4 start
    systemctl enable stunnel.service        
}

while true; do
clear
    echo "Stunnel Setup"
    echo "Menu:"
    echo "1  - Iran"
    echo "2  - Kharej"
    echo "3  - Exit"
    read -p "Enter your choice: " choice
    case $choice in
        1) Iran;;
        2) Kharej;;
        3) echo "Exiting..."; exit;;
        *) echo "Invalid choice. Please enter a valid option.";;
    esac
done
