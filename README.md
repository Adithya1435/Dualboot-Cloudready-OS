# Dualboot Cloudready

The purpose of this project is to dual-boot latest version of cloudready. Neverware has stopped the dual boot functionality from Cloudready v64. So here is the 
script to do that on a **Single hard disk (Not with Second hard disk)** without USB.
 
 *The dual boot script file for cloudready v90 will be uploaded when v90 image get released*

## Prerequisites
1. UEFI based PC (GPT Disk)
2. Minimum of 16GB free space
3. Latest version of cloudready image
4. 8GB USB (*Not needed if you are dual booting with linux*)
5. Intel/AMD GPU (AMD Limited)

##### NOTE: PLEASE FOLLOW THIS GUIDE PROPERLY AND THINK TWICE BEFORE YOU DO ANYTHING AND I AM NOT RESONSIBLE FOR ANY BAD THINGS HAPPEN SUCH AS DATA LOSS.

## Dual Boot Cloudready with Windows

1. Download latest version of [Cloudready bin](https://www.neverware.com/freedownload#intro-text)
2. Download the [Dual Boot Script](https://codeload.github.com/Adithya1435/Dualboot-Cloudready/zip/refs/heads/master)
3. Create a live USB (*Ubuntu or Linux mint*)
4. Extract & copy all the files into a new folder (*Makes the process easier*)
5. Open disk manager and shrink any volume of minimum 16GB (*Leave it unallocated*)
6. Now reboot and boot your PC with the live USB
7. Open Gparted
8. In case if you don't have Gparted, open terminal and run `sudo apt-get install gparted`
9. Now select the free space which you have created earlier
10. Make 4 partitions:

    **EFI-SYSTEM** : `fat16`  `64MB` (sdaB)  
    **ROOT-A**  : `ext2`  `4096MB` (sdaC)  
    **STATE**  : `ext4`  `Min 8GB` (sdaD)  *(Allocate maximum amount of space because all your files are stored in this drive)*  
    **OEM**  : `ext4` `1024MB` (sdaE)
    
    *(NOTE: sdaB, sdaC, sdaD and sdaE are assumptions, in your case it might be sda3 or sda4 or sda5 or something)*
 
11. After creating partitions, right click on the ROOT-A partition go to information and copy the UUID, or write it somewhere
12. Now open the folder where the cloudready image and other files are present such as dual boot script and partition-layout.sh
13. Now rename the `cloudready-free-<version>.bin` to `cloudready.img`
14. Right click on an empty area and select Open in terminal
15. Now run the following command  (**MAKE SURE THAT YOU ENTER THE PARTITION CORRECTLY**)

  `sudo bash cloudready-dualboot.sh cloudready.img sdaB sdaC sdaD sdaE` *(NOTE: sdaB-EFI-SYSTEM sdaC-ROOT-A sdaD-STATE sdaE-OEM)*
  
16. Now it will ask you to type the disk number. For:  
  
    `sda` -> 0  
    `sdb` -> 1  
    `sdc` -> 2   
  If you have *sda* then type *0*   
  
17. After that it will ask you to enter the UUID of ROOT-A prtition, just paste the UUID which you have copied it earlier
18. After that you will have to wait for few miniutes unitl it copies all the files.
19. Now copy the grub entry, create a new text document and paste it in C drive or any other drive *(DON'T PASTE IT IN ROOT-A OR STATE OR EFI OR OEM THEN YOUR CLOUDREADY WONT BOOT)*
20. Reboot your PC and log in to Windows
21. Install [Grub2Win](https://sourceforge.net/projects/grub2win/)
22. Open Grub2Win and click on **Manage Boot Menu** then **Add new Entry** then select **Custom Code** and name it **Cloudready**
23. Now paste the grub entry from the text document and remove the **menuentry line including the curly braces** The grub entry should start from **insmod part.......** and end at **cros_debug**
24. Save the text file and close Grub2Win
25. Now reboot your PC and choose Cloudready.
26. That's it now your PC should boot into Cloudready!

## Dual Boot Cloudready with Linux
  
1. Download latest version of [Cloudready bin](https://www.neverware.com/freedownload#intro-text)
2. Download the [Dual Boot Script](https://codeload.github.com/Adithya1435/Dualboot-Cloudready/zip/refs/heads/master)
3. Open terminal and install gparted `sudo apt-get install gparted`
4. Now open Gparted and create a free space of minimum 16GB
5. Make 4 partitions:

    **EFI-SYSTEM** : `fat16`  `64MB` (sdaB)  
    **ROOT-A**  : `ext2`  `4096MB` (sdaC)  
    **STATE**  : `ext4`  `Min 8GB` (sdaD)  *(Allocate maximum amount of space because all your files are stored in this drive)*  
    **OEM**  : `ext4` `1024MB` (sdaE)
    
    *(NOTE: sdaB, sdaC, sdaD and sdaE are assumptions, in your case it might be sda3 or sda4 or sda5 or something)*
 
6. After creating partitions, right click on the ROOT-A partition go to information and copy the UUID, or write it somewhere
7. Now open the folder where the cloudready image and other files are present such as dual boot script and partition-layout.sh
8. Now rename the `cloudready-free-<version>.bin` to `cloudready.img`
9. Right click on an empty area and select Open in terminal
10. Now run the following command  (**MAKE SURE THAT YOU ENTER THE PARTITION CORRECTLY**)

  `sudo bash cloudready-dualboot.sh cloudready.img sdaB sdaC sdaD sdaE` *(NOTE: sdaB-EFI-SYSTEM sdaC-ROOT-A sdaD-STATE sdaE-OEM)* 
  
11. Now it will ask you to type the disk number. For:  
  
    `sda` -> 0  
    `sdb` -> 1  
    `sdc` -> 2   
  If you have *sda* then type *0*   
  
12. After that it will ask you to enter the UUID of ROOT-A prtition, just paste the UUID which you have copied it earlier
18. After that you will have to wait for few miniutes unitl it copies all the files
19. Now copy the grub entry and save it somewhere
20. Reboot your PC
21. Open terminal and run `sudo nano /etc/grub.d/40_custom`
22. Now paste the grub entry that you have copied it earlier
23. *Ctrl+x* then *y* then *Enter*
24. Now run `sudo update-grub`
25. That's it now reboot your PC and select Cloudready (*NOTE: PLEASE DON'T SELECT **UNKNOWN LINUX DISTRIBUTION** INSTEAD SELECT CLOUDREADY FROM GRUB*)
   
