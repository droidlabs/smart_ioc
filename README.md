# SmartIoC
[![Build Status](https://travis-ci.org/ddd-ruby/smart_ioc.png)](https://travis-ci.org/ddd-ruby/smart_ioc)
[![Code Climate](https://codeclimate.com/github/ddd-ruby/smart_ioc/badges/gpa.svg)](https://codeclimate.com/github/ddd-ruby/smart_ioc)
[![codecov](https://codecov.io/gh/ddd-ruby/smart_ioc/branch/master/graph/badge.svg)](https://codecov.io/gh/ddd-ruby/smart_ioc)
[![Dependency Status](https://gemnasium.com/ddd-ruby/smart_ioc.png)](https://gemnasium.com/ddd-ruby/smart_ioc)


SmartIoC is a smart and really simple IoC container for Ruby applications.

## Installation
`gem install smart_ioc`

## Ruby versions

Please install specific smart_ioc version, depending on Ruby version.

| Ruby Version | SmartIoC Version |
| ------------ | ------------ |
| < 3.0  | 0.3.2 |
| >= 3.0 | 0.4.0 |

## Setup
   Set package name and source package folder with beans. SmartIoC will parse source files and detect bean definitions automatically for you.

```ruby
SmartIoC.find_package_beans(:PACKAGE_NAME, File.dirname(__FILE__))
```

If you have several packages in your application (like if you are using [rdm package manager](https://github.com/droidlabs/rdm)) you can run SmartIoC.find_package_beans several time pointing it to the source folder and setting a different package name.

## Basic information
1. Different packages can use beans with same name.
2. For a specific package you can declare beans with same name if they have different context.
```ruby
class UsersRepository
  include SmartIoC::Iocify
  bean :users_repository
end

class Test::UsersRepository
  include SmartIoC::Iocify
  bean :users_repository, context: :test
end
```
3. You can extend the `:default` context with any other in the following way:
```ruby
SmartIoC::Container.get_instance.set_extra_context_for_package(:YOUR_PACKAGE_NAME, :test)
```

This allows to create test implementations for any package dependency.

4. In order to get a bean use `SmartIoC::Container.get_bean(:BEAN_NAME, package: :PACKAGE_NAME, context: :default)`. `package` and `context` are optional arguments.

5. If you use the same bean name for different dependencies in different packages you will need to specify the  package directly. You can do that by using `from` parameter:

```ruby
class UsersCreator
  include SmartIoC::Iocify
  bean :users_creator

  inject :users_repository, from: :repositories

  def create
    user = User.new
    users_repository.put(user)
  end

end
```

6. To have a diffent local name for a specific bean use the `ref` parameter.
In the following example we are injecting the `:users_repository` dependency but refer to it as `repo` locally.

```ruby
class UsersCreator
  include SmartIoC::Iocify
  bean :users_creator

  inject :users_repository, ref: :repo, from: :repositories

  def create
    user = User.new
    repo.put(user)
  end
end
```

7. Use factory method to instantiate the bean via a special creational method

```ruby
class RepositoryFactory
  include SmartIoC::Iocify
  bean :users_creator, factory_method: :get_bean

  inject :config
  inject :users_repository
  inject :admins_repository

  def get_bean
    if config.admin_access?
      admins_repository
    else
      users_repository
    end
  end

  def create
    user = User.new
    repo.put(user)
  end
end
```

8. Class level beans (object will not be instantiated and class will be used for that bean instead). Set `instance: false`:

```ruby
class UsersCreator
  include SmartIoC::Iocify
  bean :users_creator, instance: false

  inject :users_repository
end
```
