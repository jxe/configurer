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
end
