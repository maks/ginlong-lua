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

* git clone https://github.com/maks/ginglong-lua.git
* install above OS packages
* create /etc/bluetooth/rfcomm config (use hcitool scan to get your invertors BT address, use channel 1)
* setup crontab (eg. below)

Sample Crontab
--------------
```
*/1  7-21  *  *  * cd /home/maks/ginlong-lua;./poll-invertor.lua >> /tmp/invertor.log 2>&1
0    7     *  *  * cd /home/maks/ginlong-lua; ./connect
0    22    *  *  * rfcomm release 0 >> /tmp/rfcomm.log 2>&1
```
