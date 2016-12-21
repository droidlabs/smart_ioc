require_relative '../user'

class UsersCreator
  include SmartIoC::Iocify

  bean :users_creator

  inject :repository, from: :admins
  inject :logger

  def create(id, email)
    user = User.new(id, email)
    repository.put(user)
  end
end
