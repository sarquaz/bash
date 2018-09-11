# script using vmware command line to launch ubuntu vm

class VM
  def initialize
    @vm = '/Users/sergey/Documents/Virtual Machines.localized/Ubuntu.vmwarevm/Ubuntu.vmx'
    @user = 'sergey'
    @password = 'sergey'
    @running = false
    id = File.basename(@vm).each_byte.map {|b| b.to_s(16)}.join
    @file = "/tmp/vm_#{id}_network_config"
  end

  def running?
    output = `vmrun list`
    lines = output.lines
    lines.each do |line|
      return true if line.include?(@vm)
    end
  false
  end

  def start
    `rm -rf #{@file}`  
    `vmrun start "#{@vm}" nogui`
  end

  def stop
      `vmrun stop "#{@vm}"`
  end

  def ssh
      start if !running?
      exec("ssh #{@user}@#{ip}")
  end

  def ip
    if not File.file? @file  then
        `vmrun -gu #{@user} -gp #{@password} runScriptInGuest "#{@vm}" /bin/bash "ifconfig > /home/#{@user}/network"`
        `vmrun -gu #{@user} -gp #{@password} copyFileFromGuestToHost "#{@vm}" /home/#{@user}/network #{@file}`
    end
    
    network_config = `cat #{@file}`
    
    match = false
    ip = ""
    
    puts network_config
    
    network_config.lines.each do |line|
        if line.include? "192.168.0" then
            ip =   line.split(" ")[1].split[0]
        end    
    end
    
    `rm -rf #{@file}`
    
    ip
  end

end

VM.new.ssh
 