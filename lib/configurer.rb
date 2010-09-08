# a new take on ruby cross-class configuration

module Configurer
  class HashMM < Hash
    def method_missing(meth, *args, &blk); self[meth] = blk; end
  end

  ::WORLDWIDE = HashMM.new

  def config *syms, &blk
    return @configurer if syms.empty?
    configurer = @configurer ||= HashMM.new{|h,k| ::WORLDWIDE[k] || blk }
    syms.each do |sym|
      meth = proc{ configurer[sym].call }
      define_method(sym){ self.class.instance_exec &configurer[sym] }
      (class << self;self;end).send(:define_method, sym){ instance_exec &configurer[sym] }
    end
  end
end
