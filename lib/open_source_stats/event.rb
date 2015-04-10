class OpenSourceStats
  class Event

    # Hash of event types to count as an event
    #
    # The top-level key should be the event type
    # The top-level value should be a hash used to filter acceptable key/value pairs
    #
    # For the sub-hash, keys are keys to look for in the event,
    # and the value is an array of acceptable values
    #
    # Events that don't match an event type and key/value pair with fail the in_scope? check
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

    attr_reader :type, :repo, :actor, :time, :payload, :id

    # Takes the raw event object from Octokit
    def initialize(event)
      @type = event[:type]
      @repo = event[:repo][:name]
      @actor = User.new(event[:actor][:login])
      @time = event[:created_at]
      @payload = event[:payload]
      @id = event[:id]
    end

    # Is this event type within our timeframe AND an acceptable event type?
    def in_scope?
      return false unless time >= OpenSourceStats.start_time
      return false unless TYPES.keys.include?(type)
      TYPES[type].each do |key, values|
        return false unless values.include? payload[key]
      end
      true
    end

    # Use event IDs to compare uniquness via Array#uniq
    def ==(other_event)
      id == other_event.id
    end
    alias_method :eql?, :==

    # How many commmits does this event involve?
    #
    # For push events, this is the number of commits pushed
    # For pull request events, this is the number of commits contained in the PR
    def commits
      case type
      when "PushEvent"
        payload[:commits].count
      when "PullRequestEvent"
        payload[:pull_request][:commits]
      else
        0
      end
    end
  end
end
