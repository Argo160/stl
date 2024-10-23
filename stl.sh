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

cat <<EOL > client.yaml
pid = /etc/stunnel/stunnel.pid
client = yes
output = /etc/stunnel/stunnel.log

EOL
for ((i=1; i<=inbounds; i++))
do
    read -p "Enter The Inboud port number :" port
    read -p "Enter The SSL Tunnel port number :" sslport
cat <<EOL > client.yaml    
[VMess$i]
accept = $port
connect = $domainip:$sslport
done
  [VMess]
  accept = 2090
  connect = kharej.ddns.net:587


  
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
