# a new take on ruby cross-class configuration

module Configurer
  class Hashwrapper < Struct.new(:hash)
    def method_missing(meth, *args, &blk); hash[meth] = blk; end
  end

  ::WORLDWIDE = Hashwrapper.new({})

  def config *syms, &blk
    return Hashwrapper.new(@class_overides) if syms.empty?
    @class_defaults ||= {}
    configs = @class_overides ||= Hash.new{|h,k| ::WORLDWIDE.hash[k] || @class_defaults[k]}
    syms.each do |sym|
      @class_defaults[sym] = blk if blk
      define_method(sym){ self.class.instance_exec &configs[sym] }
      (class << self;self;end).send(:define_method, sym){ instance_exec &configs[sym] }
    end
  end
end
