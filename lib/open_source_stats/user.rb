class OpenSourceStats
  class User

    attr_accessor :login

    def initialize(login)
      @login = login
    end

    # Returns an array of in-scope Events from the user's public activity feed
    def events
      @events ||= begin
        if self.class == OpenSourceStats::User
          events = client.user_public_events login, :per_page => 100
        else
          events = client.organization_public_events name, :per_page => 100
        end

        events.concat client.get client.last_response.rels[:next].href while next_page?
        events = events.map { |e| Event.new(e) }
        events.select { |e| e.in_scope? }
      end
    end

    private

    # Helper method to access the shared Octokit instance
    def client
      OpenSourceStats.client
    end

    # Helper method to improve readability.
    # Asks is there another page to the results?
    # Looks at both pagination and if we've gone past our allowed timeframe
    def next_page?
      client.last_response.rels[:next] &&
      client.rate_limit.remaining > 0 &&
      client.last_response.data.last[:created_at] >= OpenSourceStats.start_time
    end
  end
end
