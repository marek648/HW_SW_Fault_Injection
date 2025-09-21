# Success rate script and directory data

## Author:Marek Lörinc (xlorin00@fit.vutbr.cz)
## Login: xlorin00

## Success rate RSA attack
### RUN: Print success rate of RSA key extraction from fault for each frequency: RSA_success.py
Run script on PC by command:
```
python3 RSA_success.py Path
```
Path: directory path of fault RSA keys got from fault_attack_test.sh

## Directory data- Collected data from fault attacks

### Folders
MUL - collected faults in multiplication and succes rate of frequencies\
RSA - collected fault in RSA decryption and succes rate of frequencies\
AES - collected fault in AES encryption and succes rate of frequencies\
### File names
Name of files defines frequency (10 - 1.0GHz, 11 - 1.1GHz ...)
