class UsersRepository
  include SmartIoC::Iocify

  bean :users_repository

  inject :users_creator

  def put(user)
    @data ||= {}
    @data[user.email] = user
  end

  def get(email)
    @data[email]
  end
end
