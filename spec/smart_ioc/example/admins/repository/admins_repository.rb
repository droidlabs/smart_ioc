class AdminsRepository
  include SmartIoC::Iocify

  bean :repository

  inject :dao, from: :admins
  inject :users_creator

  public :users_creator

  def put(user)
    dao.insert(user)
  end

  def get(id)
    dao.get(id)
  end
end
