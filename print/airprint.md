# How to turn your Mac into an AirPrint server

## Setup

* Add Printer to Mac and share it with the network

System Preferences > Printers & Scanners > Share this printer on the network

* Discover TXT records for AirPrint

```
dns-sd -B _ipp._tcp local.

Browsing for _ipp._tcp.local.
DATE: ---Mon 25 Sep 2023---
10:23:57.098  ...STARTING...
Timestamp     A/R    Flags  if Domain               Service Type         Instance Name
10:23:57.101  Add        3  15 local.               _ipp._tcp.           HP LaserJet P2015 Series @ hostname
10:23:57.101  Add        2  15 local.               _ipp._tcp.           EPSON WF-3820 Series

dns-sd  -L "HP LaserJet P2015 Series @ hostname" _ipp._tcp  local.

Lookup HP LaserJet P2015 Series @ hostname._ipp._tcp.local.
DATE: ---Mon 25 Sep 2023---
10:25:04.599  ...STARTING...
10:25:04.738  HP\032LaserJet\032P2015\032Series\032@\032hostname._ipp._tcp.local. can be reached at hostname.local.:631 (interface 1) Flags: 1
 txtvers=1 qtotal=1 rp=printers/HP_LaserJet_P2015_Series ty=HP\ LaserJet\ Series\ PCL\ 4/5 adminurl=https://hostname.local.:631/printers/HP_LaserJet_P2015_Series note=hostname-a01 priority=0 product=\(LaserJet\ Series\ PCL\ 4/5\) pdl=application/octet-stream,application/pdf,application/postscript,image/jpeg,image/png,image/pwg-raster UUID=c261da10-8f18-4571-b916-0e6abe5d929b TLS=1.2 Duplex=T Copies=T printer-state=3 printer-type=0x3056
```

## Create AirPrint service

```
sudo vi /usr/local/bin/airprint.sh
---
#!/bin/zsh

dns-sd -R "AirPrint LaserJet Series PCL 4/5 @ hostname" _ipp._tcp.,_universal . 631 \
txtvers=1 \
qtotal=1 \
rp="printers/HP_LaserJet_P2015_Series" \
ty="HP LaserJet Series PCL 4/5" \
adminurl=https://hostname.local.:631/printers/HP_LaserJet_P2015_Series \
note="hostname-a01" \
priority=0 \
product="(LaserJet Series PCL 4/5)" \
pdl=application/octet-stream,application/pdf,application/postscript,image/jpeg,image/png,image/pwg-raster,image/urf \
UUID=c261da10-8f18-4571-b916-0e6abe5d929b \
TLS=1.2 \
Duplex=T \
Copies=T \
printer-state=3 \
printer-type=0x3056 \
URF="none"
---
chmod +x /usr/local/bin/airprint.sh

sudo vi /Library/LaunchDaemons/com.jeesmon.airprint.plist
---
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
            <key>Label</key>
            <string>com.jeesmon.airprint</string>

            <key>ProgramArguments</key>
            <array>
                    <string>/usr/local/bin/airprint.sh</string>
            </array>

            <key>LowPriorityIO</key>
            <true/>

            <key>Nice</key>
            <integer>1</integer>

            <key>UserName</key>
            <string>root</string>

            <key>RunAtLoad</key>
            <true/>

            <key>KeepAlive</key>
            <true/>
    </dict>
</plist>
---

sudo launchctl load /Library/LaunchDaemons/com.jeesmon.airprint.plist
```

## Links
https://www.geekbitzone.com/posts/macos/airprint/macos-airprint/
