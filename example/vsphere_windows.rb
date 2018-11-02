require 'centurion'

Centurion.configure do |c|
  # configure a provider to host the vms
  c.use_provider(:vsphere,
    hostname: 'vsphere.host',
    username: ENV['USERNAME'],
    password: ENV['PASSWORD']
  )

  # add a windows 7 template
  # uses a vm template with snapshot and cygwin for ssh
  c.add_template(:windows_7, {
    adapter: :ssh,
    path: 'templates/windows_7',
    username: ENV['VM_USERNAME'],
    password: ENV['VM_PASSWORD']
  })
end

# create a new windows 7 virtual machine
windows = Centurion.vm(
  template: :windows_7,
  path: 'vms/windows/centurion_test'
)

# run commands via ssh
puts windows.run('ls C:/')
windows.run('start microsoft-edge:http://www.cnn.com')
windows.run('notepad.exe')

# upload and download files via scp
IO.write('a_file', 'cool')
windows.upload('a_file', 'C:/Users/Administrator/Desktop/a_file')
windows.download('C:/Users/Administrator/Desktop/a_file', 'a_new_file')

# delete the vm when no longer needed
windows.destroy

# create a pool of windows vms (enumerates vm names by "_i")
windows_pool = Centurion.vms(
  pool_size: 3,
  template: :windows_7,
  path: 'vms/windows/centurion_pool_test',
)

# run ms word on all of them
windows_pool.run('C:\Program Files\Microsoft Office\Office14\Winword.exe')

windows_pool.destroy
