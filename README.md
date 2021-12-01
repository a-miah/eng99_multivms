# eng99_MultiVM

## Multimachine Vagrantfile created

```
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.define "app" do |app|
      app.vm.box = "ubuntu/xenial64"
      app.vm.network "private_network", ip: "192.168.10.100"
  end
  config.vm.define "db" do |db|
      db.vm.box = "ubuntu/xenial64"
      db.vm.network "private_network", ip: "192.168.10.150"
  end
end

```
- Vagrant file to lauch 2 VMs
- One is called app and the other db
Both allocated IPs
- app - 192.168.10.100
- db - 192.168.10.150

## Env Variable

`sudo nano .bashrc`
`export DB_HOST=192.168.10.150:27017`
`source ~/.bashrc`

`printenv DB_HOST` returned the value