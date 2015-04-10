class OpenSourceStats
  class User

    attr_accessor :login

    def initialize(login)
      @login = login
    end

    def client
      OpenSourceStats.client
    end

    def next_page?
      client.last_response.rels[:next] &&
      client.rate_limit.remaining > 0 &&
      client.last_response.data.last[:created_at] >= OpenSourceStats.start_time
    end

    def events
      @events ||= begin
        events = client.user_public_events login, :per_page => 100
        events.concat client.get client.last_response.rels[:next].href while next_page?
        events = events.map { |e| Event.new(e) }
        events.select { |e| e.in_scope? }
      end
    end

  end
end
