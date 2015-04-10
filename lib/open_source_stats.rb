require_relative "./open_source_stats/version.rb"
require_relative "./open_source_stats/user"
require_relative "./open_source_stats/organization"
require_relative "./open_source_stats/event"
require 'active_support'
require 'active_support/core_ext/numeric/time'
require 'octokit'
require 'dotenv'

Dotenv.load

class OpenSourceStats

  # Authenticated Octokit client instance
  def self.client
    @client ||= Octokit::Client.new :access_token => ENV["GITHUB_TOKEN"]
  end

  # Returns a Ruby Time instance coresponding to the earliest possible event timestamp
  def self.start_time
    @start_time ||= Time.now - 24.hours
  end

  # Helper method to overide the timestamp
  def self.start_time=(time)
    @start_time = time
  end

  def team
    @team ||= client.team ENV["GITHUB_TEAM_ID"]
  end

  # Returns an array of Users from the given team
  def users
    @users ||= begin
      users = client.team_members ENV["GITHUB_TEAM_ID"], :per_page => 100
      while client.last_response.rels[:next] && client.rate_limit.remaining > 0
        users.concat client.get client.last_response.rels[:next].href
      end
      users.map { |u| User.new u[:login] }
    end
  end

  # Returns an array of Events across all Users
  def user_events
    @user_events ||= users.map { |u| u.events }.flatten
  end

  # Returns an array of Organizations from the specified list of organizations
  def orgs
    @orgs ||= ENV["GITHUB_ORGS"].split(/, ?/).map { |o| Organization.new(o) }
  end

  # Returns an array of Events across all Organziations
  def org_events
    @org_events ||= orgs.map { |o| o.events }.flatten
  end

  # Returns an array of unique Events accross all Users and Organizations
  def events
    @events ||= user_events.concat(org_events).uniq
  end

  # Returns the calculated stats hash
  def stats(events=events)
    {
      :repositories_created => event_count(events, :type =>"CreateEvent"),
      :issue_comments => event_count(events, :type =>"IssueCommentEvent"),
      :issues_opened => event_count(events, :type =>"IssuesEvent", :action => "opened"),
      :issues_closed => event_count(events, :type =>"IssuesEvent", :action => "closed"),
      :repos_open_sourced => event_count(events, :type =>"PublicEvent"),
      :pull_requests_opened => event_count(events, :type =>"PullRequestEvent", :action => "opened"),
      :pull_requests_merged => event_count(events, :type =>"PullRequestEvent", :action => "closed", :merged => true),
      :versions_released => event_count(events, :type =>"ReleaseEvent", :action => "published"),
      :pushes => event_count(events, :type =>"PushEvent"),
      :commits => events.map { |e| e.commits }.flatten.inject{|sum,x| sum + x },
      :total_events => event_count(events)
    }
  end

  private

  # Helper method to count events by set conditions
  #
  # Options:
  #   :type - the type of event to filter by
  #   :action - the payload action to filter by
  #   :merged - whether the pull request has been merged
  #
  # Returns an integer reflecting the resulting event count
  def event_count(events, options={})
    events = events.select { |e| e.type == options[:type] } if options[:type]
    events = events.select { |e| e.payload[:action] == options[:action] } if options[:action]
    events = events.select { |e| e.payload[:pull_request][:merged] == options[:merged] } if options[:merged]
    events.count
  end

  # Helper method to reference the client stored on the class and DRY things up a bit
  def client
    OpenSourceStats.client
  end
end
