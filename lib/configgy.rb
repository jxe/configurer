# a new take on ruby cross-class configuration

module Configgy
  class HashMM < Hash
    def method_missing(meth, *args, &blk); self[meth] = blk; end
  end

  ::WORLDWIDE = Configgy::HashMM.new

  def config *syms
    return @configgy if syms.empty?
    configgy = @configgy ||= HashMM.new{|h,k| WORLDWIDE[k] }
    syms.each do |sym|
      meth = proc{ configgy[sym].call }
      define_method(sym, &meth)
      (class << self;self;end).send(:define_method, sym, &meth)
    end
  end
end
