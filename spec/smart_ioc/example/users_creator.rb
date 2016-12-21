require_relative 'user'

class UsersCreator
  include SmartIoC::Iocify

  bean :users_creator

  inject :users_repository
  inject :logger

  def create(email)
    user = User.new(1, email)
    users_repository.put(user)
  end
end
