class UsersRepository
  include SmartIoC::Iocify

  bean :repository

  inject :users_creator # just for testing purposes (circular load check)
  inject :dao

  public :users_creator

  def put(user)
    dao.insert(user)
  end

  def get(id)
    dao.get(id)
  end
end
