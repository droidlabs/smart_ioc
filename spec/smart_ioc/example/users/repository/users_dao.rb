class UsersDAO
  include SmartIoC::Iocify

  bean :dao, instance: false, after_init: :setup

  class << self
    def setup
      @data = {}
    end

    def insert(entity)
      @data[entity.id] = entity
    end

    def get(id)
      @data[id]
    end
  end
end
