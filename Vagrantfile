# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|

  config.vm.box = "vagrant-basic-web-dev"
  
  
  config.vm.network :hostonly, "33.33.33.101"
  
  # remove the next line when running on a windows host system (Windows does not have NFS support)
  config.vm.share_folder("v-root", "/vagrant", ".", :nfs => true)
  
  config.vm.provision :puppet do |puppet|
    	puppet.manifests_path = "manifests"
        puppet.module_path = "modules"
    	puppet.manifest_file = "init.pp"
  end
  
  # allow symlinks in vm	
  #config.vm.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
  #config.vm.customize ["modifyvm", :id, "--memory", 2048]
  #config.vm.customize ["modifyvm", :id, "--cpus", 2]	
  
end
