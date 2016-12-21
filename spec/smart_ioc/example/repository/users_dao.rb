class UsersDAO
  include SmartIoC::Iocify

  bean :users_dao, instance: false

  @data = {}

  class << self
    def insert(entity)
      @data[entity.id] = entity
    end

    def get(id)
      @data[id]
    end
  end
end
