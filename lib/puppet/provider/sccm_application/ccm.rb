require 'win32ole' if Puppet.features.microsoft_windows?

class WIN32OLE
  def select(attr_name, value)
    selected = Array.new()
    self.each do |x|
      x_value = x.invoke(attr_name)
      if x_value =~ /^#{value}$/i or x_value == value
        selected.push(x)
      end
    end

    return selected
  end
end

class CCM
  def initialize
    @wmi_session = WIN32OLE.connect("winmgmts://localhost/root/ccm/clientSDK")
    @application_list = @wmi_session.ExecQuery("select * from CCM_Application")
  end
  
  def evaluate_success(action)
    return_values = {
      0 => "success",
      2 => "access denied",
      8 => "unknown failure",
      9 => "invalid name",
      10 => "invalid level",
      21 => "invalid parameter",
      22 => "duplicate share",
      23 => "redirected path",
      24 => "unknown directory",
      25 => "net name not found",
    }
  
    raise(return_values[action]) unless action == 0
  end
  
  def install(name)
    wmi = WIN32OLE.connect("winmgmts:Win32_Share")
    print "#{@path}\n#{@name}\n"
    creation = wmi.create(@path, @name, 0, nil, nil)
    evaluate_success(creation)
  end
  
  def uninstall(name)
    deletion = @wmi_session.get("Win32_Share='#{@name}'").delete
    evaluate_success(deletion)
  end

  def list
    @application_list
  end

  def get(name)
    self.list.select('name', name)[0]
  end
end

Puppet::Type.type(:sccm_application).provide :windows do
  confine :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  mk_resource_methods

  def self.instances
	ccm_instance.list.each.collect do |application|
	  if application.IsMachineTarget and application.InstallState == "Installed"
        new( :name => application.name,
             :ensure => :present
        )
      end
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

  def ccm_instance
    return @ccm_instance if defined?(@ccm_instance)
	@ccm_instance = CCM.new
    @ccm_instance
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