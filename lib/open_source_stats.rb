require "open_source_stats/version"
require "open_source_stats/user"
require "open_source_stats/event"
require 'octokit'
require 'dotenv'

Dotenv.load

class OpenSourceStats

  def self.client
    @client ||= Octokit::Client.new :access_token => ENV["GITHUB_TOKEN"]
  end

  def self.start_time
    @start_time ||= Time.new(Time.now.utc.year, Time.now.utc.month, Time.now.utc.day,0,0,0,0)
  end

  def client
    OpenSourceStats.client
  end

  def users
    @users ||= begin
      users = client.team_members ENV["GITHUB_TEAM_ID"], :per_page => 100
      while client.last_response.rels[:next] && client.rate_limit.remaining > 0
        users.concat client.get client.last_response.rels[:next].href
      end
      users.map { |u| User.new u[:login] }
    end
  end

  def events
    @events ||= users.map { |u| u.events }.flatten
  end

  def team_stats
    {
      :repositories_created => event_count(:type =>"CreateEvent"),
      :issue_comments => event_count(:type =>"IssueCommentEvent"),
      :issues_opened => event_count(:type =>"IssuesEvent", :action => "opened"),
      :issues_closed => event_count(:type =>"IssuesEvent", :action => "closed"),
      :repos_open_sourced => event_count(:type =>"PublicEvent"),
      :pull_requests_opened => event_count(:type =>"PullRequestEvent", :action => "opened"),
      :pull_requests_merged => event_count(:type =>"PullRequestEvent", :action => "closed", :merged => true),
      :versions_released => event_count(:type =>"ReleaseEvent", :action => "published"),
      :pushes => event_count(:type =>"PushEvent"),
      :commits => events.select { |e| e.type == "PushEvent" }.map { |e| e.payload[:commits].count }.flatten.inject{|sum,x| sum + x }
    }
  end

  private

  def event_count(options={})
    raise "Type required" unless options[:type]
    selected = events.select { |e| e.type == options[:type] }
    selected = selected.select { |e| e.payload[:action] == options[:action] } if options[:action]
    selected = selected.select { |e| e.payload[:pull_request][:merged] == options[:merged] } if options[:merged]
    selected.count
  end

end
