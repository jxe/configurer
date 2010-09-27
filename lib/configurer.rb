# a new take on ruby cross-class configuration

module Configurer
  def eigenclass; (class<<self;self;end); end

  class Config < Array
    def method_missing(meth, *args, &blk); first[meth] = blk; end
    def mod; @module ||= Module.new; end
    def []=(sym, blk)
      me = self
      last[sym] = blk
      mod.send(:define_method, sym) do
        frame = Module===self ? self : self.class
        frame.instance_exec(&me.inject(nil){ |m, e| m || e[sym] })
      end
    end
  end

  ::WORLDWIDE = Config.new([{}])
  CONFIGS = Hash.new{ |h,k| h[k] = Config.new([{},::WORLDWIDE.first,{}]) }

  def config sym = nil, &blk
    !sym and CONFIGS[self] or CONFIGS[self][sym] = blk
  end

  def config_from klass
    [self, eigenclass].each{ |x| x.send :include, CONFIGS[klass].mod }
  end

  def self.extend_object klass
    super; klass.config_from klass
  end
end
