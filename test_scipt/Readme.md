# Autotest VoltPillager and PlunderVolt attack 

## Author:Marek Lörinc (xlorin00@fit.vutbr.cz)
## Login: xlorin00

## Hardware and software prerequisities
Computer with CPU Intel which supports Intel SGX\
Activated Intel SGX in BIOS setup\
Linux OS\
Selected attack downloaded from:\
  &emsp; PlunderVolt: https://github.com/KitMurdock/plundervolt\
  &emsp; VoltPillager: https://github.com/zt-chen/voltpillager\
Selected attack prerequisities(in readme of attack)

## RUN
set variable password in script to password of your PC and
Run script by command:
```
./test_pludervolt_voltpillager.sh Attack_type Path
```

Attack type:

1 - PlunderVolt Fault multiplication\
2 - PlunderVolt Fault RSA\
3 - PlunderVolt Fault AES\
4 - VoltPillager Fault multiplication\
5 - VoltPillager Fault RSA\
6 - VoltPillager Fault AES\

Path of attack scripts:

PlunderVolt example path: /home/fit/plundervolt\
VoltPillager exapmle path: /home/fit/voltpill/voltpillager/poc
