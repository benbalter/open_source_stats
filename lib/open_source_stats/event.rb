class OpenSourceStats
  class Event

    TYPES = {
      "CreateEvent" => { :ref_type => ["repository"] },
      "IssueCommentEvent" => {:action => ["created"] },
      "IssuesEvent" => { :action => ["opened", "closed"] },
      "PublicEvent" => {},
      "PullRequestEvent" => { :action => ["opened", "closed"]},
      "PullRequestReviewCommentEvent" => { :action => ["created"] },
      "PushEvent" => {},
      "ReleaseEvent" => { :action => "published" },
    }

    attr_reader :type, :repo, :actor, :time, :payload

    def initialize(event)
      @type = event[:type]
      @repo = event[:repo][:name]
      @actor = User.new(event[:actor][:login])
      @time = event[:created_at]
      @payload = event[:payload]
    end

    def in_scope?
      return false unless time >= OpenSourceStats.start_time
      return false unless TYPES.keys.include?(type)
      TYPES[type].each do |key, values|
        return false unless values.include? payload[key]
      end
      true
    end
  end
end
