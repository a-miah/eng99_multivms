# Development Environment and MultiMachines


**Linux Commands**

- `sudo apt-get update -y`


# Common Linux Commands

- Who am I `uname - a` 
- Where am I `pwd`
- list dir or all `ls` or `ls -a`
- Copy file `cp filename destination`
- Cut or rename `mv filename destination`
- Create a file `touch filename`
- create a folder `mkdir foldername`
- how to navigate - `cd foldername` return step back `cd ..
- Deleting file folders `rm -rf foldername`



**File Permissions**
- Read `r`, Write `w` and `x`
- how to check permission `ll`
- change permission `chmod permission filename`

- find out all processes running `top`
- how to `kill` a process 

# Vagrant Commands
- `vagrant init` - creates a new vagrantfile in the directory
- `vagrant up` - will create and run the Virtual Machine
- `vagrant destroy` - will stop and destroy the VM (will need to reset to reuse)
- `vagrant reload` - will update the VM with anything new added (if it doesn't work do destroy then up)
- `vagrant ssh` - to get into the VM when it's running
- `vagrant status` - shows the status of VM (if it's running or not)
- `exit` - exits the VM
- `enter` - enters the VM
- `sudo su` - become admin and goes to root
- `systemctl status *package name*` - to see if installed properly
- `sudo systemctl restart *package name*` - if package doesn't run properly

# Setting up Virtual Machine

## Development Environment 

![Alt text](https://github.com/a-miah/eng99_multivms/blob/main/Images/VM-setup.JPG "Development Environment")

### 1. Create a Vagrantfile
With the below included in the file:
```
# Creating a virtual machine with Linux Ubuntu 16.04
# ubuntu/xenial64


This can be created in nano in bash or an IDE. Below is the content of the Vagrantfile

Vagrant.configure("2") do |config|


 # Choose the os/box/distro
 config.vm.box = "ubuntu/xenial64"
 config.vm.network "private_network", ip: "192.168.10.100"
 # vagrant destroy
 # vagrant up
 # vagrant reload

end

```

2. `vagrant up` (VirtualBox should now be running)
3. `vagrant status` - if everything worked above it should be running
4.  `vagrant ssh` - to go into the VM (name needs to be provided if using multiple machines)
5. `sudo apt-get update` - asks VM to connect to the internet and run updates
6. `sudo apt-get upgrade` - upgrades any missing packages
7. `sudo apt-get install nginx` - installs a web server
8. `systemctl status nginx` - checks if nginx is running 
9. Ensure you have selected an ip address to host your VM by including on Vagrantfile
10. `vagrant reload` if vagrantfile updated and then `vagrant ssh`



# Automate everything we have done manually

> vagrant up again

- 1. `touch` *filename.sh*
- 2. `nano` *filename.sh* - edit file as below:
```
#!/bin/bash
# update, upgrade, install nginx 

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install nginx -y

```
- 3. ./*filename.sh* - runs file
- 4. `sudo chmod permission +x *filename.sh*` - if permission denied

# Pipes and Filters
A pipe can pass the standard output of one operation to the standard input of another, but a filter can modify the stream. A filter takes the standard input, does something useful with it, and then returns it as a standard output.

- Display first two lines in a file `cat file | head -2`
- Display last 2 lines in a file `cat file | tail -2`



# Multimachine Vagrantfile created

## Multimachine with Node and MongoDB

![Alt text](https://github.com/a-miah/eng99_multivms/blob/main/Images/multi-machine.JPG "Monolith Architecture")

```

Vagrant.configure("2") do |config|

  config.vm.define "app" do |app|
      app.vm.box = "ubuntu/xenial64"
      app.vm.network "private_network", ip: "192.168.10.100"
      app.vm.synced_folder ".", "/home/vagrant/app"
      app.vm.provision "shell", path: "./provision_app.sh"  #path for app automation
  end
  config.vm.define "db" do |db|
      db.vm.box = "ubuntu/xenial64"
      db.vm.network "private_network", ip: "192.168.10.150"
      db.vm.synced_folder ".", "/home/vagrant/app"
      db.vm.provision "shell", path: "./provision_db.sh"
  end
end


```
- Vagrant file to lauch 2 VMs
- One is called app and the other db
Both allocated IPs
- app - 192.168.10.100
- db - 192.168.10.150


## Environment Testing
Environment testing – make sure when we launch the app we have all the dependencies installed
- Navigate to the test folder and run tests – fix if failing 
- Gem install bundler
- Bundler
- Rake spec
- Make sure above commands are run where Rakefile is installed


## Env Variable
How to make an environment variable persistent 

One way of doing it:

```
`sudo nano .bashrc`
`export DB_HOST=192.168.10.150:27017`
`source ~/.bashrc`

`printenv DB_HOST` returned the value

```

Returns an environment variable of DB_HOST 


# DB Machines set up and MongoDB Configuration
1. 2 Machines running app and db (look at MultiMachine Vagrantfile above)
2. db machine to have MongoDB configured/provisioned with required dependencies/packages/versions

```
# be careful of these keys, they will go out of date
sudo apt-get update -y

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv D68FA50FEA312927

echo "deb https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

sudo apt-get update -y
sudo apt-get upgrade -y


# sudo apt-get install mongodb-org=3.2.20 -y

sudo apt-get install -y mongodb-org=3.2.20 mongodb-org-server=3.2.20 mongodb-org-shell=3.2.20 mongodb-org-mongos=3.2.20 mongodb-org-tools=3.2.20


# if mongo is is set up correctly these will be successful
sudo systemctl restart mongod
sudo systemctl enable mongod
```
3. db VM to have a private IP so we can connect to the app using the db IP
4. mongodb default port is 27017
5. Change bindIP to 0.0.0.0 in mongod.conf and then following commands to run properly
```
sudo nano /etc/mongod.conf
sudo systemctl restart mongod
sudo systemctl enable mongod
sudo systemctl status mongod
```

6. Create a persistent environment variable DB_HOST in `~/.bashrc`
`export DB_HOST="mongodb://192.168.10.150:27017/posts"`
7. Run app using `npm start` if posts do not appear do below steps first before running
8. Run `node seed.js` and then `npm start`



## Reverse Proxy
Change nginx default page to the app welcome page (no need to add port :3000 each time)

- In VM open: `cd /etc/nginx/sites-available`
- `sudo nano default`
- Delete and replace with the required config:
```
server {
    listen 80;

    server_name _;
    location / {
        proxy_pass http://192.168.10.100:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```
- To check config `sudo nginx -t`, will return success message if correct syntax
- Restart nginx `sudo systemctl restart nginx`
- `npm start` will run app on http://192.168.10.100/