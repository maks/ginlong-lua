Lua script to poll data from Ginlong solar invertors
====================================================

Based closely on the excellant work done by Chris on the perl version:
https://github.com/Crosenhain/ginlong_poller

OS Packages Requirements
------------------------
on ubuntu/debian:

```apt-get install lua5.2 bluez curl```


PVOutput API config
-------------------

add a file named login.lua in top level dir with:
```
local M = {}

M.API_KEY = "12345678912345678" -- your PVOuput.org API key
M.SYSTEM_ID = "123456" -- your PVOuput.org  system id

return M
```

Setup
-----

* git clone https://github.com/maks/ginlong-lua.git
* install above OS packages
* create /etc/bluetooth/rfcomm config (use hcitool scan to get your invertors BT address, use channel 1)
* setup crontab (eg. below)

Sample /etc/bluetooth/rfcomm
----------------------------
use `hcitool scan` to get your invertors BT address.

```
rfcomm0 {
        bind no;        
        device 00:12:34:56:78:AB;
        channel 1;
        comment "ginlong invertor";
}
```

check you can connect using `rfcomm connect 0` and then `rfcomm show 0` should give you some output like:
```
ginlong-lua# rfcomm show 0
rfcomm0: 00:01:95:1C:0C:1C -> 00:18:96:00:4D:B1 channel 1 connected [reuse-dlc release-on-hup tty-attached]
```

Note: above will need either to be as root user or you need to set the permission on the bluetooth/rfcomm 
device for which ever user you are runnign as.

Sample Crontab
--------------
```
*/1 7-21 * * * cd /home/maks/ginlong-lua; ./poll-invertor.lua >> /tmp/invertor.log 2>&1
*/10   7 * * * cd /home/maks/ginlong-lua; ./connect
0   22   * * * rfcomm release 0 >> /tmp/rfcomm.log 2>&1
```
