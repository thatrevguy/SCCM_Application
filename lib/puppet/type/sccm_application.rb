Puppet::Type.newtype(:sccm_application) do
  @doc = <<-'EOT'
    Installs and uninstalls software packages made available through SCCM deployments.
  EOT

  ensurable

  def initialize(*args)
    super
    # if target is unset, use the title
    if self[:target].nil? then
      self[:target] = self[:name]
    end
  end

  newparam(:name) do
    desc "The name of the sccm_application resource. Used for uniqueness. Will set
      the target to this value if target is unset."
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty name must be specified."
      end
    end

    munge do |value|
      value = value.downcase
    end

  isnamevar
  end

  newparam(:target) do
    desc "The application package name that is advertised through a deployment.
      The default is the name."
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty target must be specified."
      end
    end

    munge do |value|
      value = value.downcase
    end
  end
end