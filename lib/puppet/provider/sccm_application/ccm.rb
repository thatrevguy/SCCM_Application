require 'win32ole' if Puppet.features.microsoft_windows?

class WIN32OLE
  def get(attr_name, value)
    self.each do |x|
      x_value = x.invoke(attr_name)
      if x_value =~ /^#{value}$/i or x_value == value
        return x
      end
    end
  end
end

class CCM
  def self.list
    session = WIN32OLE.connect("winmgmts://localhost/root/ccm/clientSDK")
    session.ExecQuery("select * from CCM_Application")
  end

  def self.begin(method, name)
    method == 'install' ? install_state = "Installed" : install_state = "NotInstalled"
    application = self.list.get('name', name)
    ccm_application_class = WIN32OLE.connect("winmgmts://localhost/root/ccm/clientSDK:CCM_Application")
    ccm_application_class.invoke(method, application.id, application.revision, true, 0, 'Normal', false)
    while application.installstate != install_state
      application = self.list.get('name', name)
      sleep 1
    end
  end
end

Puppet::Type.type(:sccm_application).provide :windows do
  confine :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  mk_resource_methods

  def self.instances
	CCM.list.each.collect do |application|
    if application.InstallState == "Installed"
	  state = :present
    else
      state = :absent
    end

      new( :name => application.name.downcase,
           :ensure => state
      )
    end
  end

  def self.prefetch(resources)
    applications = instances
    applications.each do |application|
      if resources.each_key.include?(application.name)
        resources[application.name].provider = application
      end
    end
  end

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    if @property_flush[:ensure] == :present
      CCM.begin('install', @resource[:name])
    else
      CCM.begin('uninstall', @resource[:name])
    end
  end
end