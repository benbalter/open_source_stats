class OpenSourceStats
  class Organization < OpenSourceStats::User
    attr_accessor :name

    def initialize(name)
      @name = name
    end
  end
end
