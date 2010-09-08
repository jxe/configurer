require 'helper'

class TestConfigable < Test::Unit::TestCase
  should "set a global config" do

    THING = []

    class Foo
      extend Configurer; config :bar
      def try
        raise unless bar == :good
      end
    end

    WORLDWIDE.bar { THING.push :hi; :good }
    assert WORLDWIDE[:bar]

    Foo.new.try
    assert_equal :hi, THING.first
    assert_equal :good, Foo.bar
    THING.pop; THING.pop

    Foo.config.bar { THING.push :bye; :good }
    Foo.new.try
    raise unless THING.first == :bye
  end

  should "work without a global config" do
    class Foo2
      extend Configurer; config :baz do :bad end
    end

    x = Foo2.new
    assert_equal :bad, Foo2.baz
    assert_equal :bad, x.baz

    Foo2.config.baz { :good }
    assert_equal :good, Foo2.baz
    assert_equal :good, x.baz
  end

  should "run in the subclass context" do
    class ::A; extend Configurer; config :f do name end; end
    class ::B < ::A; end

    assert_equal 'A', A.f
    assert_equal 'A', A.new.f
    assert_equal 'B', B.f
    assert_equal 'B', B.new.f
  end

end
