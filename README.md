## Automated ELK Stack Deployment

The files in this repository were used to configure the network depicted below.

#### Microsoft Azure ELK Stack Deployment Network Diagram

![](https://github.com/codymoffett/Cybersecurity-Bootcamp/blob/main/Diagrams/Azure%20Cloud%20Project%20Network%20Diagram%20-%20ELK%20Stack.PNG)

These files have been tested and used to generate a live ELK deployment on Azure. They can be used to either recreate the entire deployment pictured above. Alternatively, select portions of the _____ file may be used to install only certain pieces of it, such as Filebeat.

#### Playbook 1: docker-playbook.yml
''''

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
	
	
#### Playbook 2: install-elk.yml
''''

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

		  
#### Playbook 3: filebeat-playbook.yml
''''

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
		
		
#### Playbook 4: metricbeat-playbook.yml
''''

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


The following Configuration Files were used with these Playbooks:





This document contains the following details:
- Description of the Topologu
- Access Policies
- ELK Configuration
  - Beats in Use
  - Machines Being Monitored
- How to Use the Ansible Build


### Description of the Topology

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, the D*mn Vulnerable Web Application.

Load balancing ensures that the application will be highly _____, in addition to restricting _____ to the network.
- _TODO: What aspect of security do load balancers protect? What is the advantage of a jump box?_

Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the _____ and system _____.
- _TODO: What does Filebeat watch for?_
- _TODO: What does Metricbeat record?_

The configuration details of each machine may be found below.
_Note: Use the [Markdown Table Generator](http://www.tablesgenerator.com/markdown_tables) to add/remove values from the table_.

| Name     | Function | IP Address | Operating System |
|----------|----------|------------|------------------|
| Jump Box | Gateway  | 10.0.0.1   | Linux            |
| TODO     |          |            |                  |
| TODO     |          |            |                  |
| TODO     |          |            |                  |

### Access Policies

The machines on the internal network are not exposed to the public Internet. 

Only the _____ machine can accept connections from the Internet. Access to this machine is only allowed from the following IP addresses:
- _TODO: Add whitelisted IP addresses_

Machines within the network can only be accessed by _____.
- _TODO: Which machine did you allow to access your ELK VM? What was its IP address?_

A summary of the access policies in place can be found in the table below.

| Name     | Publicly Accessible | Allowed IP Addresses |
|----------|---------------------|----------------------|
| Jump Box | Yes/No              | 10.0.0.1 10.0.0.2    |
|          |                     |                      |
|          |                     |                      |

### Elk Configuration

Ansible was used to automate configuration of the ELK machine. No configuration was performed manually, which is advantageous because...
- _TODO: What is the main advantage of automating configuration with Ansible?_

The playbook implements the following tasks:
- _TODO: In 3-5 bullets, explain the steps of the ELK installation play. E.g., install Docker; download image; etc._
- ...
- ...

The following screenshot displays the result of running `docker ps` after successfully configuring the ELK instance.

**Note**: The following image link needs to be updated. Replace `docker_ps_output.png` with the name of your screenshot image file.  


![TODO: Update the path with the name of your screenshot of docker ps output](Images/docker_ps_output.png)

### Target Machines & Beats
This ELK server is configured to monitor the following machines:
- _TODO: List the IP addresses of the machines you are monitoring_

We have installed the following Beats on these machines:
- _TODO: Specify which Beats you successfully installed_

These Beats allow us to collect the following information from each machine:
- _TODO: In 1-2 sentences, explain what kind of data each beat collects, and provide 1 example of what you expect to see. E.g., `Winlogbeat` collects Windows logs, which we use to track user logon events, etc._

### Using the Playbook
In order to use the playbook, you will need to have an Ansible control node already configured. Assuming you have such a control node provisioned: 

SSH into the control node and follow the steps below:
- Copy the _____ file to _____.
- Update the _____ file to include...
- Run the playbook, and navigate to ____ to check that the installation worked as expected.

_TODO: Answer the following questions to fill in the blanks:_
- _Which file is the playbook? Where do you copy it?_
- _Which file do you update to make Ansible run the playbook on a specific machine? How do I specify which machine to install the ELK server on versus which to install Filebeat on?_
- _Which URL do you navigate to in order to check that the ELK server is running?

_As a **Bonus**, provide the specific commands the user will need to run to download the playbook, update the files, etc._