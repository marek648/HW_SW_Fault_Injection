#Success rate for each frequency of successfull key extraction from fault  
#Author: Marek Lörinc
#Date: 08.05.2022
import os, glob
import sys

#Array of hex numbers to integer
#Author: Kit Murdock
#URL: https://github.com/KitMurdock/plundervolt/blob/master/sgx_crt_rsa/Evaluation/eval.py
def list_to_int(l):
    r = 0
    
    for i in range(0, len(l)):
        r <<= 8
        r |= l[len(l) - i - 1]
        
    return r

#Compute greatest common divider of numbers x and y
#Author: Kit Murdock
#URL: https://github.com/KitMurdock/plundervolt/blob/master/sgx_crt_rsa/Evaluation/eval.py
def compute_GCD(x, y): 
  
   while(y): 
       x, y = y, x % y 
  
   return x

# 1 argument must be entered - directory of checked files
if len(sys.argv) != 2:
	sys.exit("Enter 1 argument (directory of files)")

#Directory of files with RSA faults
path =  str(sys.argv[1])

#Correct parameters of RSA encryption/decryption
pt_exp = 0x00EB7A19ACE9E3006350E329504B45E2CA82310B26DCD87D5C68F1EEA8F55267C31B2E8BB4251F84D7E0B2C04626F5AFF93EDCFB25C9C2B3FF8AE10E839A2DDB4CDCFE4FF47728B4A1B7C1362BAAD29AB48D2869D5024121435811591BE392F982FB3E87D095AEB40448DB972F3AC14F7BC275195281CE32D2F1B76D4D353E2D
ct = 0x1253E04DC0A5397BB44A7AB87E9BF2A039A33D1E996FC82A94CCD30074C95DF763722017069E5268DA5D1C0B4F872CF653C11DF82314A67968DFEAE28DEF04BB6D84B1C31D654A1970E5783BD6EB96A024C2CA2F4A90FE9F2EF5C9C140E5BB48DA9536AD8700C84FC9130ADEA74E558D51A74DDF85D8B50DE96838D6063E0955
p = 0xEECFAE81B1B9B3C908810B10A1B5600199EB9F44AEF4FDA493B81A9E3D84F632124EF0236E5D1E3B7E28FAE7AA040A2D5B252176459D1F397541BA2A58FB6599
n = 0xBBF82F090682CE9C2338AC2B9DA871F7368D07EED41043A440D6B6F07454F51FB8DFBAAF035C02AB61EA48CEEB6FCD4876ED520D60E1EC4619719D8A5B8B807FAFB8E0A3DFC737723EE6B4B7D93A2584EE6A649D060953748834B2454598394EE0AAB12D7B61A51F527A9A41F6C1687FE2537298CA2A8F5946F8E5FD091DBDCB


for filename in glob.glob(os.path.join(path,'*')):  #Check all files in entered directory
    with open(os.path.join(os.getcwd(), filename), 'r') as f:   # open in readonly mode
        succes = 0
        total = 0
        for count, line in enumerate(f, start=1):   #Each file read line by line 
            if count % 3 == 0:  #Every third line is faulted RSA decryption
                total+=1
                str_pt_fault = line.split(",")  #HEX numbers of faulted decryption to array
                pt_fault = [int(x, 16) for x in str_pt_fault[:-1]]  #Array of strings to array of integers
                pt_fault = list_to_int(pt_fault)    #Array of integers to 1 final integer
                calc_p = compute_GCD((pt_exp - pt_fault) % n, n)
                if calc_p == p: #Check if calculated GCD is equal to expected prime number of decryption p
                    succes+=1
        #For each file print filename, number of success key extraction, total of faults and percentage of success
        print (filename)
        print (succes)
        print (total)
        if total == 0:
            print (0)
        else:
            print (str(float(succes)/total*100) + "%")
