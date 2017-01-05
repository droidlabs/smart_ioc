# SmartIoC
[![Build Status](https://travis-ci.org/ddd-ruby/smart_ioc.png)](https://travis-ci.org/ddd-ruby/smart_ioc)
[![Code Climate](https://codeclimate.com/github/ddd-ruby/smart_ioc/badges/gpa.svg)](https://codeclimate.com/github/ddd-ruby/smart_ioc)
[![codecov](https://codecov.io/gh/ddd-ruby/smart_ioc/branch/master/graph/badge.svg)](https://codecov.io/gh/ddd-ruby/smart_ioc)
[![Dependency Status](https://gemnasium.com/ddd-ruby/smart_ioc.png)](https://gemnasium.com/ddd-ruby/smart_ioc)


SmartIoC is a smart and really simple IoC container for Ruby applications.

## Installation
`gem install smart_ioc`

## Setup
   Set package name and source package folder with beans. SmartIoC will parse source files and detect bean definitions automatically for you.

```ruby
SmartIoC.find_package_beans(:PACKAGE_NAME, File.dirname(__FILE__))
```

    If you have saveral packages in your application (like if you are using [rdm package manager](https://github.com/droidlabs/rdm)) you can run SmartIoC.find_package_beans several time pointing it to source folder and setting different package name.

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
3. You can extend `:default` context with any other in the following way:

   ```ruby
   SmartIoC::Container.get_instance.set_extra_context_for_package(:YOUR_PACKAGE_NAME, :test)
   ```
This allows to create test implementations that for any package dependencies.
4. In order to get bean use `SmartIoC::Container.get_bean(:BEAN_NAME, package: :PACKAGE_NAME, context: :default)`. `package` and `context` are optional arguments.
5. If you have name with same bean in different packages you will need to set package directly. You can simply do that in the following way:

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

6. Change dependency name inside your bean:

```ruby
class UsersCreator
  include SmartIoC::Iocify
  bean :users_creator

  inject :repo, ref: :users_repository, from: :repositories

  def create
    user = User.new
    repo.put(user)
  end
end
```

7.  Use factory method to instantiate the bean

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
