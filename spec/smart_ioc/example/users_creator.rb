require_relative 'user'

class UsersCreator
  include SmartIoC::Iocify

  bean :users_creator

  inject :users_repository

  def create(email)
    user = User.new(email)
    users_repository.put(user)
  end
end
