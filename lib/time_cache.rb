class TimeCache
  def initialize(expiry_in_sec)
    @expiry = expiry_in_sec
    @modified = {}
    @cache = {}
  end

  def []=(key, value)
    @modified[key] = Time.now
    @cache[key] = value
  end

  def [](key)
    expire!(key) if @modified[key] and Time.now - @modified[key] > @expiry
    @cache[key]
  end

  def expire!(key)
    @modified.delete(key)
    @cache.delete(key)
  end

  def expire_all!
    @modified.clear
    @cache.clear
  end
end
