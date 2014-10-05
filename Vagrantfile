# -*- mode: ruby -*-

PROJECT_NAME = "elkStack"

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "puphpet/ubuntu1404-x64"
  config.vm.box_url = "https://vagrantcloud.com/puphpet/ubuntu1404-x64"
  config.vm.hostname = PROJECT_NAME

  config.vm.provider :virtualbox do |vb|
		vb.name = PROJECT_NAME
		vb.memory = 2048
		vb.cpus = 2
		#vb.gui = true
	end

  config.vm.network :forwarded_port, host:5000, guest: 5000
  config.vm.network :forwarded_port, host:8080, guest: 80
  config.vm.network :forwarded_port, host:9200, guest: 9200

  config.vm.network "private_network", ip: "192.168.33.10"

	config.ssh.forward_agent = true

  config.vm.provision :shell, :path => "bootstrap.sh"
end
