bean :dao do
  after_init :setup

  inject :config

  class << self
    def setup
      @data = {}
    end

    def insert(entity)
      config.app_name
      @data[entity.id] = entity
    end

    def get(id)
      @data[id]
    end
  end
end
