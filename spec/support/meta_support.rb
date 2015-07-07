module MetaSupport
  def self.public_getters(klass)
    klass.public_instance_methods(false).select do |name|
      getter? klass.instance_method(name)
    end
  end

  def self.getter?(method)
    method.arity == 0
  end
end
