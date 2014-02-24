module DynamicSitemaps
  class Storage
    attr_reader :generator

    def initialize(generator)
      @generator = generator
    end

    def move_to_destination
      raise NotImplementedError
    end
  end
end
