## Automated ELK Stack Deployment

The files in this repository were used to configure the network depicted below.

#### Microsoft Azure ELK Stack Deployment Network Diagram

![](https://github.com/codymoffett/Cybersecurity-Bootcamp/blob/main/Diagrams/Azure%20Cloud%20Project%20Network%20Diagram%20-%20ELK%20Stack.PNG)

These files have been tested and used to generate a live ELK deployment on Azure. They can be used to recreate the entire deployment pictured above.

#### Playbook 1: docker-playbook.yml
```

---
  - name: Docker.io and DVWA Playbook
    hosts: webservers
    become: true
    tasks:

    - name: Install docker.io
      apt:
        force_apt_get: yes
        update_cache: yes
        name: docker.io
        state: present

    - name: Install python3-pip
      apt:
        force_apt_get: yes
        name: python3-pip
        state: present

    - name: Install Docker python module
      pip:
        name: docker
        state: present

    - name: Install and Launch Docker Web Container DVWA on Port 80
      docker_container:
        name: dvwa
        image: cyberxsecurity/dvwa
        state: started
        restart_policy: always
        published_ports: 80:80

    - name: Enable Docker Service
      systemd:
        name: docker
        enabled: yes
```
	
#### Playbook 2: install-elk.yml
```

---
  - name: ELK Stack Configurtion Playbook
    hosts: elk
    remote_user: azadmin
    become: true
    tasks:

    # Use apt module to install docker.io
    - name: Install docker.io
      apt:
        update_cache: yes
        force_apt_get: yes
        name: docker.io
        state: present

    # Use apt module to install python3-pip
    - name: Install python3-pip
      apt:
        force_apt_get: yes
        name: python3-pip
        state: present

    # Use pip module to install docker
    - name: Install Docker Module
      pip:
        name: docker
        state: present

    # Use sysctl module to increase memory
    - name: Use more memory
      sysctl:
        name: vm.max_map_count
        value: 262144
        state: present
        reload: yes

    # Use docker_container module to download and launch sebp/elk:761 on ports 5601 / 9200 / 5044
    - name: Download and Launch a Docker ELK container
      docker_container:
        name: elk
        image: sebp/elk:761
        state: started
        restart_policy: always
        published_ports:
          - 5601:5601
          - 9200:9200
          - 5044:5044
```

		  
#### Playbook 3: filebeat-playbook.yml
```

---
  - name: Install and Launch Filebeat
    hosts: webservers
    become: true
    tasks:

    # Download latest filebeat deb found in Kibana
    - name: Download Filebeat DEB
      command: curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.6.1-amd64.deb

    # Install latest filebeat deb found in Kibana
    - name: Install Filebeat DEB
      command: sudo dpkg -i filebeat-7.6.1-amd64.deb

    # Drop Filebeat config file into new /etc/filebeat/filebeat.yml
    - name: Drop Config File in filebeat.yml
      copy:
        src: /etc/ansible/files/filebeat-config.yml
        dest: /etc/filebeat/filebeat.yml

    # Enable filebeat modules
    - name: Enable filebeat modules
      command: filebeat modules enable system

    # Setup filebeat
    - name: Setup filebeat
      command: filebeat setup

    # Start filebeat service
    - name: Start filebeat service
      command: service filebeat start

    # Enable filebeat service on boot
    - name: Enable filebeat on boot
      systemd:
        name: filebeat
        enabled: yes
```
	
		
#### Playbook 4: metricbeat-playbook.yml
```

---
  - name: Install and Launch Metricbeat
    hosts: webservers
    become: true
    tasks:

    # Download latest metricbeat deb found in Kibana
    - name: Download Metricbeat DEB
      command: curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.6.1-amd64.deb

    # Install latest metricbeat deb found in Kibana
    - name: Install Metricbeat DEB
      command: dpkg -i metricbeat-7.6.1-amd64.deb

    # Drop Metricbeat config file into new /etc/metricbeat/metricbeat.yml
    - name: Drop Config File in metricbeat.yml
      copy:
        src: /etc/ansible/files/metricbeat-config.yml
        dest: /etc/metricbeat/metricbeat.yml

    # Enable metricbeat modules
    - name: Enable metricbeat modules
      command: metricbeat modules enable docker

    # Setup metricbeat
    - name: Setup metricbeat
      command: metricbeat setup

    # Start metricbeat service
    - name: Start metricbeat service
      command: service metricbeat start

    # Enable metricbeat service on boot
    - name: Enable metricbeat on boot
      systemd:
        name: metricbeat
        enabled: yes
```


#### The following Configuration Files were used with these Playbooks:

##### ansible.cfg: 
https://github.com/codymoffett/Cybersecurity-Bootcamp/blob/main/Ansible/Ansible%20Config%20Files/ansible.cfg

##### hosts:       
https://github.com/codymoffett/Cybersecurity-Bootcamp/blob/main/Ansible/Ansible%20Config%20Files/hosts.txt

##### filebeat-config.yml:
https://github.com/codymoffett/Cybersecurity-Bootcamp/blob/main/Ansible/Ansible%20Config%20Files/filebeat-config.yml

##### metricbeat-config.yml:
https://github.com/codymoffett/Cybersecurity-Bootcamp/blob/main/Ansible/Ansible%20Config%20Files/metricbeat-config.yml




This document contains the following details:
- Description of the Topologu
- Access Policies
- ELK Configuration
- Beats in Use
- Machines Being Monitored
- How to Use the Ansible Build


### Description of the Topology

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, the D*mn Vulnerable Web Application.

Load balancing ensures that the application will be highly available, in addition to restricting access to the network.
- Load balancers are an effective soultion against Denial of Service attacks. They offer health probes to check machines behind the load balancer for issues.
- A Jump Box allows us to minimize the surface area of attack by only having one virtual machine public facing allowing network traffic through. Remote connections are easily filtered and monitored through the Jump Box.

Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the configuration and system files.
- **Filebeat** monitors the log files, collects log events, and forwards them to Elasticsearch or Logstash.
- **Metricbeat** periodically collects metrics from the operating system and from services running on the server, then forwards this data to Elasticsearch or Logstash.


The configuration details of each machine may be found below.


| Name                 | Function | IP Address | Operating System |
|----------------------|----------|------------|------------------|
| Jump-Box-Provisioner | Gateway  | 10.0.0.7   | Linux            |
| Web-1                |  DVWA    | 10.0.0.8   | Linux            |
| Web-2                |  DVWA    | 10.0.0.9   | Linux            |
| ELK-Stack-Server     |  ELK     | 10.1.0.4   | Linux            |


### Access Policies

The machines on the internal network are not exposed to the public Internet. 

Only the Jump-Box-Provisioner can accept connections from the Internet (Port 80). Access to this machine is only allowed from the following IP addresses:

- 70.176.160.246

Machines within the network can only be accessed by the Jump-Box-Provisioner machine.

- 10.0.0.7 can access Web-1, Web-2, ELK-Stack-Server using SSH over Port 22.


A summary of the access policies in place can be found in the table below.

| Name                 | Publicly Accessible | Allowed IP Addresses |
|----------------------|---------------------|----------------------|
| Jump-Box-Provisioner | Yes (SSH Port 22)   | 70.176.160.246       |
|  Web-1               | Yes (HTTP Port 80)  | 70.176.160.246       |
|  Web-2               | Yes (HTTP Port 80)  | 70.176.160.246       |
|  Elk-Stack-Server    | Yes (HTTP Port 5601)| 70.176.160.246       |


### Elk Configuration

Ansible was used to automate configuration of the ELK machine. No configuration was performed manually, which is advantageous because...

- Allows quick configuration of new machines in a consistent manor.
- Everyone can see exactly how the network is configured by reading the configuration files.
- Allows automatic updates to occur to machines on the network whenever the configuration files change.

### Playbooks Explained

#### Playbook 1: docker-playbook.yml

This playbook is used to set up DVWA servers running inside a Docker container. This file was used to configure Web-1 and Web-2. The playbook executes the following tasks:

- Installs Docker
- Installs Python3
- Installs Docker Python Module
- Downloads and Launches DVWA Docker Container over Port 80
- Enables the Docker service

#### Playbook 2: install-elk.yml

This playbook is used to set up an ELK server running inside a Docker container. This file was used to configure Elk-Stack-Server. The playbook executes the following tasks:

- Installs Docker
- Installs Python3
- Installs Docker Python Module
- Increase Virtual Memory to 262144 to support the ELK Stack
- Download and Launch Docker Elk Container (image: sebp/elk:761)

#### Playbook 3: filebeat-playbook.yml

This playbook is used to deploy Filebeat on the Web-1 and Web-2 servers. This allows the elk service on Elk-Stack_Server to monitor log file activity on the webservers. The playbook executes the following tasks:

- Downloads latest Filebeat deb from Kibana
- Installs latest Filebeat deb found in Kibana
- Drops in new Filebeat config file into /etc/filebeat/filebeat.yml
- Enable Filebeat Modules
- Setup Filebeat
- Start Filebeat service
-Enable Filebeat service on boot

#### Playbook 4: metricbeat-playbook.yml

This playbook is used to deploy Metricbeat on the Web-1 and Web-2 servers. This allows the elk service on Elk-Stack_Server to monitor metrics from operating systems and services on the webservers. The playbook executes the following tasks:

- Downloads latest Metricbeat deb from Kibana
- Installs latest Metricbeat deb found in Kibana
- Drops in new Metricbeat config file into /etc/metricbeat/metricbeat.yml
- Enable Metricbeat Modules
- Setup Metricbeat
- Start Metricbeat service
-Enable Metricbeat service on boot



The following screenshot displays the result of running `docker ps` after successfully configuring the ELK instance.

![](https://github.com/codymoffett/Cybersecurity-Bootcamp/blob/main/Diagrams/sudo_docker_ps_command.PNG)

### Target Machines & Beats

This ELK server is configured to monitor the following machines:

- **Web-1**: 10.0.0.7
- **Web-2**: 10.0.0.8

We have installed the following Beats on these machines:

- **Filebeat**
- **Metricbeat**

These Beats allow us to collect the following information from each machine:

- **Filebeat** monitors the log files, collects log events, and forwards them to Elasticsearch or Logstash.
- **Metricbeat** periodically collects metrics from the operating system and from services running on the server, then forwards this data to Elasticsearch or Logstash.

### Using the Playbook

In order to use the playbook, you will need to have an Ansible control node already configured. Assuming you have such a control node provisioned: 

SSH into the control node and follow the steps below:

- Copy the playbook files to Ansible Docker Contianer.
- Update the hosts file `/etc/ansible/hosts/` to include:

```
[webservers]
10.0.0.8 ansible_python_interpreter=/usr/bin/python3
10.0.0.9 ansible_python_interpreter=/usr/bin/python3

[elk]
10.1.0.4 ansible_python_interpreter=/usr/bin/python3
```

- Update the hosts file `/etc/ansible/ansible.cfg/` to include:

```
# default user to use for playbooks if user is not specified
# (/usr/bin/ansible will use current user as default)
remote_user = azadmin
```

### Steps to Run the Playbooks

1. From local machine, ssh into the Jump-Box-Provisioner `~$ ssh azadmin@52.168.139.135`

2. Start the Ansible Docker container `~$ sudo docker start laughing_mclaren`. `laughing_mclaren` is the name of the docker container in Jump-Box-Provisioner.

3. Run `~$ sudo docker attach laughing_mclaren` to jump into the Ansible Docker Container.

4. Run the four playbooks with the following commands:

- `~$ ansible-playbook /etc/ansible/docker-playbook.yml`
- `~$ ansible-playbook /etc/ansible/install-elk.yml`
- `~$ ansible-playbook /etc/ansible/roles/filebeat-playbook.yml`
- `~$ ansible-playbook /etc/ansible/roles/metricbeat-playbook.yml`

5. From the Jump-Box-Provisioner, ssh into ELK-Stack-Server `~$ ssh azadmin@<DYNAMIC-ELK-PUBLIC-IP>`

6. In the Elk-Stack-Server run `~$ sudo docker start elk`

7. If there are no errors then you can go to [http://\<DYNAMIC-ELK-PUBLIC-IP\>:5601/app/kibana]() and start monitoring data from **Metricbeat** and **Filebeat** from the Web-1 and Web-2 webservers.
