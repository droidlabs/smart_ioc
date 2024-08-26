require 'spec_helper'

describe SmartIoC::BeanDefinition do
  describe "::inspect" do
    it {
      bd = SmartIoC::BeanDefinition.new(
        name:           :test_bean,
        package:        :test_package,
        path:           'current_dir',
        klass:          Object,
        scope:          :singleton,
        context:        :default,
        instance:       false,
        factory_method: nil,
        after_init:     nil,
      )

      str =
"name:           :test_bean
package:        :test_package
context:        :default
path:           current_dir
instance:       false
factory_method: "

      expect(bd.inspect).to eq(str)
    }
  end
end
