class TestAdminsRepository
  include SmartIoC::Iocify

  bean :repository, context: :test, instance: false

  @data = {}

  class << self
    def put(user)
      @data[user.id] = user
    end

    def get(id)
      @data[id]
    end
  end
end
