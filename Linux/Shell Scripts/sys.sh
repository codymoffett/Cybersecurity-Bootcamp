#!/bin/bash

#check if script was run as root. Exit if ture.
if [ $UID -eq 0 ]
then
    echo "Please do not run this script as root."
    exit
fi

#Define VARIABLES
file_output=$HOME/research/sys_info.txt
ip=$(ip addr | grep inet | tail -3 | head -1 && ip addr | grep inet | tail -1)
suids=$(sudo find / -type f -perm /4000 2> /dev/null)
execs=$(find /home -type f -perm 777 2> /dev/null)
cpu=$(lscpu | grep CPU)
disk=$(df -H | head -2)

#Define LISTS

commands=(
 'date'
 'uname -a'
 'hostname -s'
)

files=(
 '/etc/shadow'
 '/etc/passwd'
 '/etc/hosts'
)


#Check for research directory. Create it if needed.
if [ ! -d $HOME/research ]
then
	mkdir $HOME/research
fi

#Check for output file. Clear it if needed.
if [ -f $file_output ]
then
	  > $file_output
fi

#############################################
#Start Script

echo "A Quick System Audit Script" >> $file_output
echo "" >> $file_output

for x in {0..2} ;
do
	results=$(${commands[$x]})
	echo "Results of "${commands[$x]}" command:" >> $file_output
	echo $results >> $file_output
	echo "" >> $file_output
done

#Display Machine Type
echo "Machine Type Info:" >> $file_output
echo -e "$MACHTYPE \n" >> $file_output

#Display IP Address Info
echo -e "IP Address Info:" >> $file_output
echo -e "$ip \n" >> $file_output

#Display DNS Info
echo "DNS Servers: " >> $file_output
cat /etc/resolv.conf >> $file_output

#Display Memory Usage
echo -e "\nMemory Info: " >> $file_output
free >> $file_output

#Display CPU Usage
echo -e "\nCPU Info:" >> $file_output
lscpu | grep CPU >> $file_output

#Display Disk Usage
echo -e "\nDisk Usage:" >> $file_output
df -H | head -2 >> $file_output

#Display Who Is Logged In
echo -e "\nWho is logged in: \n $(who) \n" >> $file_output

#Check sudo abilities of each user with a home directory
for user in $(ls /home)
do
	sudo -lU $user 2> /dev/null  >> $file_output
done

#Display SUID Files
echo -e "\nSUID Files:" >> $file_output
for suid in $suids;
do
	echo $suid >> $file_output
done

#List Executable Files
echo -e "\nExecutable Files:" >> $file_output
for exec in $execs;
do
	echo $exec >> $file_output
done

#List the Top 10 Processes
echo -e "\nThe Top 10 Processes are:" >> $file_output
ps aux --sort -%mem | awk {'print $1, $2, $3, $4, $11'} | head -11  >> $file_output

#Check the Permissions on Files
echo -e "\nThe Permissions for sensitive /etc files: \n" >> $file_output
for file in ${files[@]};
do
	ls -l $file >> $file_output
done

#Print Date and Time w/ End Message
echo -e "\nThe Date is: $(date)" >> $file_output
echo -e "\nA Full System Scan was Completed!" >> $file_output
echo -e  "\nEnd of System Info!" >> $file_output
