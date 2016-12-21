class AdminsRepository
  include SmartIoC::Iocify

  bean :repository

  inject :dao

  def put(user)
    dao.insert(user)
  end

  def get(id)
    dao.get(id)
  end
end
