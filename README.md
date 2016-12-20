SmartIoC is an Inversion of Control container for Ruby.
It takes advantage of the dynamic nature of Ruby to provide a rich and flexible approach to injecting dependencies.
It's inspired by SpringIoc and tries to give you the same features.

## Usage
Lets say you have a Logger which has the Appender dependency

```ruby
class Logger
  attr_accessor :appender

  def info(message)
    # do some work with appender
  end
end

class Appender
end
```
To use Logger you need to inject the instance of Appender class, for example
using setter injection:
```ruby
logger = Logger.new
logger.appender = Appender.new
logger.info('some message')
```

SmartIoC eliminates the manual injection step and injects dependencies by itself.
To use it you need to instantiate SmartIoC::Container and pass dependency definitions(we call them beans) to it:
```ruby
container = SmartIoC::Container.new do |c|
  c.bean(:appender, class: Appender)
  c.bean(:logger, class: Logger) do
    attr :appender, ref: :appender
  end
end
```
Now you can get the Logger instance from container with already set dependencies and use it:
```ruby
logger = container[:logger]
logger.info('some message')
```

To simplify injection SmartIoC allows you specify dependencies inside of your class:
```ruby
class Logger
  inject :appender

  def info(message)
    # do some work with appender
  end
end

class Appender
end
```
With `inject` keyword you won't need to specify class dependencies in bean definition:
```ruby
container = SmartIoC::Container.new do |c|
  c.bean(:appender, class: Appender)
  c.bean(:logger, class: Logger)
end
```

## Installation

Add this line to your application's Gemfile:

    gem 'ioc_rb'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ioc_rb

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# TODO
1. Constructor based injection
2. Scope registration, refactor BeanFactory. SmartIoC:Container.register_scope(SomeScope)
3. Write documentation with more examples
