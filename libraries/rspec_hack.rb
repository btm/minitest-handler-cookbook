# In Chef 17, inspec requires rspec which adds describe methods that replace the minitest ones.
# We need to put them back

module MinitestHandler
  module RSpecHack
    class << self
      attr_accessor :main
    end

    def fix_describe
      return if Gem::Version.new(Chef::VERSION) < Gem::Version.new('17')

      # chef will also do this, but we want to make sure it's required now
      require 'inspec'
      RSpec.configure(&:disable_monkey_patching!)

      [(class << MinitestHandler::RSpecHack.main; self; end), Module].each do |klass|
        klass.class_exec do
          # describe method based on the one in minitest/spec
          # https://github.com/seattlerb/minitest/blob/v4.7.3/lib/minitest/spec.rb#L59-L74
          def describe(desc, additional_desc = nil, &block)
            stack = MiniTest::Spec.describe_stack
            name  = [stack.last, desc, additional_desc].compact.join('::')
            sclas = stack.last || is_a?(Class) && is_a?(MiniTest::Spec::DSL) ? self : MiniTest::Spec.spec_type(desc)

            cls = sclas.create name, desc

            stack.push cls
            cls.class_eval(&block)
            stack.pop
            cls
          end
        end
      end
    end

    extend self
  end
end

MinitestHandler::RSpecHack.main = self
