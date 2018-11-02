module Centurion
  class Template
    attr_accessor :name
    attr_accessor :path
    attr_accessor :adapter

    def initialize(name, path, adapter)
      @name = name
      @path = path
      @adapter = adapter
    end
  end
end
