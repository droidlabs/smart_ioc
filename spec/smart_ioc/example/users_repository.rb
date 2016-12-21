class UsersRepository
  include SmartIoC::Iocify

  bean :users_repository

  inject :users_creator # just for testing purposes (circular load check)
  inject :users_dao

  def put(user)
    users_dao.insert(user)
  end

  def get(id)
    users_dao.get(id)
  end
end
