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
    desc "Name of SCCM package made available in Software Center through deployment."
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty name must be specified."
      end
    end

  isnamevar
  end
end