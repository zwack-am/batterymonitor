#! /bin/sh

if  [ $EUID -ne 0 ]
then
  echo This must be run as root
  exit 1
fi

cat > /usr/local/bin/batterymonitor.sh << EOF
#! /bin/sh

FUEL=\$((\`/usr/sbin/i2cget -y -f 0 0x34 0xb9\`))

if [ \$FUEL -eq 127 ]
then
  echo "default-on" > /sys/class/leds/chip\:white\:status/trigger
elif [ \$FUEL -le 25 ]
then
  echo "heartbeat" > /sys/class/leds/chip\:white\:status/trigger
else
  echo "none" > /sys/class/leds/chip\:white\:status/trigger
fi 
EOF

chmod 0755 /usr/local/bin/batterymonitor.sh

crontab -l > /tmp/rootcrontab

echo "*/5 * * * * /usr/local/bin/batterymonitor.sh" >> /tmp/rootcrontab

crontab /tmp/rootcrontab

rm /tmp/rootcrontab
