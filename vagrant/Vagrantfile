# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# make /etc/hosts
$hosts = <<-LINES
cat <<EOF | tee /etc/hosts
127.0.0.1       localhost

fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts

LINES

Dir.glob("*.yaml").each do |filename|
  $sp = YAML.load_file(filename)["spec"]
  next if $sp.has_key?("node_list") == false

  $sp["node_list"].each do |node|
    $hosts.concat("#{node['private_network']}\t#{node['hostname']}\n")
  end
end
$hosts.concat("EOF\n")

# open config yaml
filename = "kubernetes.yaml"
filename = ENV["CONFIG"] if ENV.has_key?("CONFIG")

puts "Config Filename: #{filename}"
spec = YAML.load_file(filename)["spec"]

# setup path
$setup = spec["setup"]
$setup_path = File.expand_path($setup["host_path"])

# create disk
spec["node_list"].each do |node|
  # check enable flag
  next if node["enable"] == false or node.has_key?("disk") == false

  node['disk'].each do |disk|
    filename = File.expand_path(disk['filename'])
    next if File.exist?(filename)

    puts "Create Disk: #{filename}"
    puts `VBoxManage createmedium disk --format VDI --variant Standard --size #{disk['size'] * 1024} --filename #{filename}`
  end
end

# vagrant configure
Vagrant.configure("2") do |config|
  spec["node_list"].each do |node|
    # check enable flag
    next if node["enable"] == false

    config.vm.define node["name"] do |cfg|
      cfg.vm.box = node["box"]["name"]
      cfg.vm.box_url = node["box"]["url"] if node["box"].has_key?("url")
      cfg.vm.box_version = node["box"]["version"] if node["box"].has_key?("version")

      # disk
      if node.has_key?("disk") == true
        # detach disk
        cfg.trigger.before [:destroy, :package] do |trigger|
          trigger.ruby do |env, machine|
            node["disk"].each do |hdd|
              next if machine.id == nil

              filename = File.expand_path(hdd['filename'])

              puts "Poweroff: [#{machine.id}] #{filename}"
              puts `VBoxManage controlvm #{machine.id} poweroff`

              puts "Detach Disk: [#{machine.id}] #{filename}"
              puts `VBoxManage storageattach #{machine.id} --storagectl #{hdd['storagectl']} --device 0 --port #{hdd['port']} --medium none`
            end
          end
        end
      end

      # provider
      cfg.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--groups", node["group_name"]]
        vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]

        # additional vm information
        if node.has_key?("vminfo")
          vb.customize ["modifyvm", :id, "--vram", node['vminfo']['vram']]
          vb.customize ["modifyvm", :id, "--monitorcount", node['vminfo']['monitorcount']]
        end

        # attach disk
        if node.has_key?("disk") == true
          node["disk"].each do |hdd|
            filename = File.expand_path(hdd['filename'])
            next unless File.exist?(filename)

            vb.customize ['storageattach', :id, '--storagectl', hdd["storagectl"], '--device', 0,
              '--port', hdd["port"], '--type', 'hdd', '--medium', filename]
          end
        end

        vb.name = node["name"]
        vb.gui = false
        vb.cpus = node["resources"]["cpus"]
        vb.memory = node["resources"]["memory"]
        vb.linked_clone = true
      end

      cfg.vm.hostname = node["hostname"]

      # ssh
      if spec.has_key?("ssh")
        cfg.ssh.username = spec["ssh"]["username"]
        cfg.ssh.password = spec["ssh"]["password"]
        cfg.ssh.keys_only = false
        cfg.ssh.insert_key = false
      end

      # vbguest update
      if node.has_key?("vbguest_update")
        cfg.vbguest.auto_update = node["vbguest_update"]
      end

      # synced folder
      if spec.has_key?("vbox") and spec["vbox"].has_key?("synced_folder")
        spec["vbox"]['synced_folder'].each do |folder|
          cfg.vm.synced_folder File.expand_path(folder["host_path"]), folder["guest_path"], disabled: folder["disabled"]
        end
      end

      # network
      if node.has_key?("private_network")
        cfg.vm.network "private_network", auto_correct: true, ip: node["private_network"], id: "private"
      end

      if node.has_key?("forwarded_port")
        node['forwarded_port'].each do |port|
          cfg.vm.network "forwarded_port", auto_correct: true, host: port["host"], guest: port["guest"], id: "fp-#{port['guest']}"
        end
      end

      # update setup & skel
      cfg.vm.provision "file", source: $setup_path, destination: "/tmp/setup"

      cfg.vm.provision "shell", privileged: true, inline: <<-SHELL
        rsync -av /tmp/setup/ #{$setup['guest_path']}/
        chmod -R +x #{$setup['guest_path']}
        cp #{spec['setup']['guest_path']}/bin/* /usr/local/bin/
        rm -rf /tmp/setup
      SHELL

      # update /etc/hosts``
      cfg.vm.provision "shell", privileged: true, inline: $hosts

      # format disk
      if node.has_key?("disk") == true
        node["disk"].each do |hdd|
          next unless hdd.has_key?("device")

          cfg.vm.provision "shell", privileged: true, path: "#{$setup_path}/core/disk-format.sh", args: [hdd["device"]]
          cfg.vm.provision "shell", privileged: true, path: "#{$setup_path}/core/disk-mount.sh",
            args: [hdd["device"], hdd["mount"], spec["ssh"]["username"]]
        end
      end

      # provision
      if node.has_key?("provision")
        node['provision'].each do |item|
          cfg.vm.provision "shell", privileged: item["privileged"], inline: item["inline"]
        end
      end

    end

  end
end
