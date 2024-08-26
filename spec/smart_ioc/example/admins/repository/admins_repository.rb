bean :repository do
  inject :dao
  inject :users_creator

  def put(user)
    dao.insert(user)
  end

  def get(id)
    dao.get(id)
  end
end
