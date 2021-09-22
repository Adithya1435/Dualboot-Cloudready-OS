# Dualboot Cloudready OS [EXPERIMENTAL]

The purpose of this project is to dual-boot latest version of cloudready. Neverware has stopped the dual boot functionality from Cloudready v64. So here is the 
script to do that on a **Single hard disk (Not with Second hard disk)**.
  
## Video Guide

**The official video guide can be found here : https://youtu.be/q8Ze897Yazk**


## Prerequisites
- UEFI based PC (GPT Disk)
- x86_64 based CPU
- Minimum of 16GB free space
- Cloudready image above v70
- 8GB USB (Not needed if you are dual booting with linux)

 > Note: I am not responsible for any data loss. Please follow this guide carefully

## Dual Boot Cloudready with Windows

1. Download latest version of [Cloudready bin](https://www.neverware.com/freedownload#intro-text)
2. You can download the old versions of Cloudready from here: https://bit.ly/3h6h3Pe
3. Download the [Dual Boot Script](https://codeload.github.com/Adithya1435/Dualboot-Cloudready/zip/refs/heads/master)
4. Create a live USB of linux mint or ubuntu
5. Extract & copy all the files into a new folder (*Makes the process easier*)
6. Open disk manager and shrink any volume of minimum 16GB (*Leave it unallocated*)
7. Now reboot and boot your PC with the live USB
8. Open terminal and run:  
  ```
  sudo apt update && sudo apt install gedit
  ```
9. Open Gparted
10. Now select the free space which you have created earlier
11. Make 3 partitions:
  
    **ROOT-A** : `ext2`  `4096MB` (sdaB)  
    **STATE**  : `ext4`  `Min 8GB` (sdaC)  *(Allocate maximum amount of space because all your files are stored in this drive)*  
    **OEM**    : `ext4` `1024MB` (sdaD)
    
   > Note: sdaB, sdaC, sdaD are assumptions, in your case it might be sda3 or sda4 or sda5 or something
 
12. Now open the folder where the cloudready image and other files are present such as dual boot script and partition-layout.sh
13. Now rename the **cloudready-free-<version>.bin** to **cloudready.img**

### Option 1 : Works on Ubuntu and Linux mint

1. Right click on an empty area and select Open in terminal
2. Now run the following command  (**MAKE SURE THAT YOU ENTER THE PARTITION CORRECTLY**)

 ````
 sudo bash cloudready-dualboot.sh cloudready.img sdaB sdaC sdaD
 ````
 > Note: sdaB-ROOT-A sdaC-STATE sdaD-OEM
  
3. Now it will ask you to type the disk number. For:  
  
    `sda` -> 0  
    `sdb` -> 1  
    `sdc` -> 2   
 
 > If you have sda then type 0   
  
5. After that you will have to wait for few miniutes unitl it copies all the files.
6. Now after that a text editor will open, copy all the contents and close it. 
    It will be like this:  
    `PARTITION_NUM_STATE=12  
     PARTITION_NUM_KERN_A=12....`
7. After closing an another text editor will open, delete the lines starting from  
    `NEVERWARE_PARTITION_OFFSET=$(calculate_partition_offset)`  
    `PARTITION_NUM_EFI_SYSTEM=$((12 + NEVERWARE_PARTITION_OFFSET))`  
     
 > **The Example File Can Be Seen Here**: [CLICK HERE!](https://user-images.githubusercontent.com/72510218/133206670-c068409d-0666-4b98-9e43-08fbbd3ceea8.jpeg)
 
8. Now save the file and close it.
9. Now copy the grub entry, create a new text document and paste it in C drive or any other. (Don't copy the menuentry line from the grub)
10. Reboot your PC and log in to Windows
 
### Option 2 : Works on Linux Mint & Ubuntu
 
1. Open terminal and run:
 ```
 sudo apt update && sudo apt-get install gnome-disk-utility
 ```
2. Now right click on **cloudready.img** and click **Open with Disk Image Mounter**
3. Now the partions of cloudready will be mounted
4. Right click on an empty area and select Open in terminal
5. Now run the following command  (**MAKE SURE THAT YOU ENTER THE PARTITION CORRECTLY**)  
   
 ```
 sudo bash cloudready-dualboot-1.sh sdaB sdaC sdaD
 ```
6. Now it will ask you to type the disk number. For:  
  
    `sda` -> 0  
    `sdb` -> 1  
    `sdc` -> 2   
 > If you have sda then type 0
  
7. After that you will have to wait for few miniutes unitl it copies all the files.
8. Now after that a text editor will open, copy all the contents and close it. 
    It will be like this:  
    `PARTITION_NUM_STATE=12  
     PARTITION_NUM_KERN_A=12....`
9. After closing an another text editor will open, delete the lines starting from  
    `NEVERWARE_PARTITION_OFFSET=$(calculate_partition_offset)`  
    `PARTITION_NUM_EFI_SYSTEM=$((12 + NEVERWARE_PARTITION_OFFSET))`  
     
> **The Example File Can Be Seen Here** : [CLICK HERE!](https://user-images.githubusercontent.com/72510218/133206670-c068409d-0666-4b98-9e43-08fbbd3ceea8.jpeg)
10. Now save the file and close it.
11. Now copy the grub entry, create a new text document and paste it in C drive or any other. (Don't copy the menuentry line from the grub)
12. Reboot your PC and log in to Windows
 
 ### Configuring Grub :
 
1. Install [Grub2Win](https://sourceforge.net/projects/grub2win/)
2. Open Grub2Win and click on **Manage Boot Menu** then **Add new Entry** then select **Custom Code** and name it **Cloudready**
3. Now paste the grub entry from the text document and remove the **menuentry line including the curly braces** The grub entry should start from **insmod part.......** and end at **cros_debug**
4. Save the text file and close Grub2Win
5. Now reboot your PC and choose Cloudready.
6. That's it now your PC should boot into Cloudready! Enjoy!

## Dual Boot Cloudready with Linux
  
You can follow the same steps mentioned above to dualboot cloudready with linux.  

### Configuring Grub :
 
21. Open terminal and run `sudo nano /etc/grub.d/40_custom`  
22. Now paste the grub entry that you have copied it earlier  
23. *Ctrl+x* then *y* then *Enter*  
24. Now run `sudo update-grub`  
25. That's it now reboot your PC and select Cloudready   
 > Note : Don't select Unknown linux distribution from grub instead select Cloudready
 
## Updating Cloudready

 You cannot natively update cloudready with this process so the cloudready-updater script helps to update cloudready to the latest version
 
### Option 1 : Using updater script
 
1. Download the recent version of cloudready bin from neverware
2. Download the updater script from this repository
3. Boot into linux with live USB 
4. Install gedit and gnome-disk-utility
5. Open the directory where you stored the bin file and updater script
6. Rename **cloudready-free...bin** to **cloudready.img**
7. Right click on cloudready.img and open with Disk Image Mounter
8. Now open in terminal and run :
```
 sudo bash cloudready-updater.sh sdaB sdaC sdaD
```
> Note: sdaB-ROOT-A sdaC-STATE sdaD-OEM
9. After it completes reboot and enjoy the new version of cloudready!
 
### Option 2: Using Dual-boot script
 
1. Download the recent version of cloudready bin from neverware
2. Download the dualboot script script from this repository
3. Boot into linux with live USB 
4. Install gedit
5. Open the directory where you stored the bin file and updater script
6. Rename **cloudready-free...bin** to **cloudready.img**
7. Open in terminal and run :
```
 sudo bash cloudready-dualboot.sh cloudready.img sdaB sdaC sdaD [--skip-state]
```
> Note: sdaB-ROOT-A sdaC-STATE sdaD-OEM
8. After it completes reboot and enjoy the new version of cloudready!
 
## Uninstalling Cloudready
 
1. The only way is to delete the ROOT-A, OEM and STATE partitions from disk management in windows and create a new simple volume. (Gparted, if you are using linux)
2. Uninstall Grub2Win (Optional)
 
## FAQ (Frequently Asked Questions)
 
1. **Is dualbooting by this method safe?**  
Yes, it is absolutely safe unless you mess with your partitions
 
2. **Why only 3 partitions are required to dualboot cloudready whereas the image has 12 partitions?**  
These partitions are enough to boot the OS, you can create ROOT-B partition to update cloudready natively

3. **Linux (Beta) dosen't work in my system after doing this, so what should i do now?**  
Make sure to disable crostini-use-dlc from chrome://flags and retry. If that dosen't work then try downgrading to older version of cloudready. If you have dgpu then switch it to  igpu
 
4. **I get "wrongfs type,bad superblock" error in option 1?**  
This problem occurs due to bad superblock in the image, try option 2 instead
 
5. **Will I get all the functionality of cloudready?**  
Yes, you will get everything

6. **Why Filesystem-verity is disabled and cloudready recommends reinstalling, so should i reinstall?**  
As we are manually installing cloudready, filesystem verity will be disabled. Just click "I understand" and tick the check box to never display it again.
 
7. **I cannot see my internal drives mounted so how can I mount it?**  
Internal drives do not show up in cloudready. Further study needed
 
8. **I get "special device p27 does not exist, Installation aborted" in option 1**  
This error occurs if you use cloudready version 89 or below. Use option 2 instead
