require 'spec_helper'
require 'ioc_rb'

describe SmartIoC::Container do

  class Logger
    attr_accessor :appender
  end
  class Appender
  end
  class Printer
  end

  describe "bean definitions" do
    let(:container) do
      container = SmartIoC::Container.new
      container.bean(:appender, class: Appender)
      container.bean(:logger, class: Logger) do
        attr :appender, ref: :appender
      end
      container.bean(:printer, class: Printer, instance: false)
      container
    end
    it "should instanciate bean and it's dependencies" do
      container[:logger].should be_a(Logger)
      container[:logger].appender.should be_a(Appender)
      container[:printer].should be(Printer)
    end

    it "container should return the same instance on each call" do
      logger = container[:logger]
      container[:logger].should == logger
    end
  end

  describe "eager_load_bean_classes" do
    let(:container) do
      container = SmartIoC::Container.new
      container.bean(:appender, class: 'Appender')
      container.bean(:logger, class: 'Logger') do
        attr :appender, ref: :appender
      end
      container.bean(:printer, class: 'Printer', instance: false)
      container
    end

    it "should eager load bean classes" do
      container.eager_load_bean_classes
    end
  end


  describe "#replace_bean" do
    it "should replace bean definition" do
      container = SmartIoC::Container.new
      container.bean(:appender, class: Appender)
      container[:appender].should be_a(Appender)

      container.replace_bean(:appender, class: Logger)
      container[:appender].should be_a(Logger)
    end
  end

  describe "passing bean definitions to container constructor" do
    let(:resource) do
      Proc.new do |c|
        c.bean(:appender, class: 'Appender')
        c.bean(:logger, class: Logger) do
          attr :appender, ref: :appender
        end
      end
    end

    it "should instanciate given bean definitions" do
      container = SmartIoC::Container.new_with_beans([resource])
      container[:logger].should be_a(Logger)
      container[:appender].should be_a(Appender)
    end

  end

  describe "inheritance" do
    class Form
      inject :validator
    end

    class Circle < Form
      inject :circle_validator
    end
    class Rectangle < Form
      inject :rectangle_validator
    end

    class Validator
    end
    class CircleValidator
    end
    class RectangleValidator
    end

    let(:container) do
      SmartIoC::Container.new do |c|
        c.bean(:circle,              class: Circle)
        c.bean(:rectangle,           class: Rectangle)
        c.bean(:validator,           class: Validator)
        c.bean(:circle_validator,    class: CircleValidator)
        c.bean(:rectangle_validator, class: RectangleValidator)
      end
    end

    it "dependencies in subclasses shouldn't affect on each other" do
      container[:circle].circle_validator.should       be_a(CircleValidator)
      container[:rectangle].rectangle_validator.should be_a(RectangleValidator)
    end
  end

  describe "bean scopes" do
    class ContactsService
      inject :contacts_repository
      inject :contacts_validator
    end
    class ContactsRepository
    end
    class ContactsValidator
    end

    let(:container) do
      container = SmartIoC::Container.new
      container.bean(:contacts_repository, class: ContactsRepository, scope: :request)
      container.bean(:contacts_service,    class: ContactsService,    scope: :singleton)
      container.bean(:contacts_validator,  class: ContactsValidator,  scope: :prototype)
      container
    end

    it "should instanciate bean with :request scope on each request" do
      first_repo  = container[:contacts_service].contacts_repository
      second_repo = container[:contacts_service].contacts_repository
      first_repo.should == second_repo
      RequestStore.clear! # new request
      third_repo  = container[:contacts_service].contacts_repository
      first_repo.should_not == third_repo
    end

    it "should instanciate bean with :prototype scope on each call" do
      first_validator  = container[:contacts_service].contacts_validator
      second_validator = container[:contacts_service].contacts_validator
      first_validator.should_not == second_validator
    end
  end

  describe "factory method" do
    module Test
      class Config
      end
      class ConfigsFactory
        def load_config
          Config.new
        end
      end
    end

    let(:container) do
      SmartIoC::Container.new do |c|
        c.bean :config, class: Test::ConfigsFactory, factory_method: :load_config
      end
    end

    it "should instantiate bean using factory method" do
      container[:config].should be_instance_of(Test::Config)
    end

  end

end
