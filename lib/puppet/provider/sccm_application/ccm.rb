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
  class << self
    attr_accessor :list
  end
end

Puppet::Type.type(:sccm_application).provide :windows do
  confine :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  mk_resource_methods

  def self.instances
    wmi_session = WIN32OLE.connect("winmgmts://localhost/root/ccm/clientSDK")
	CCM.list = wmi_session.ExecQuery("select * from CCM_Application")
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

  end
end