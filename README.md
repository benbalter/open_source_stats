# Open Source Stats

*A quick script to generate metrics about the contribution your organization makes to the open source community in a 24-hour period*.

## What it looks at

* Public activity across all public repositories from members of a given team
* Public activity across all users on repositories owned by a given organization or organizations

## How it works

By doing terrible, terrible things to GitHub's events API.

## Setup

1. `gem install open_source_stats`
2. Create a `.env` file and add the following:
  * `GITHUB_TOKEN` - A personal access token with `read:org` scope
  * `GITHUB_TEAM_ID` - The numeric ID of the team to pull users from (e.g., 12345)
  * `GITHUB_ORGS` - A comma separated list of the orgs to look at (e.g, `github,atom`)
3. Run `bundle exec oss`

This will spit markdown formatted results into standard out.

## Output

Output might look something like this...

| Metric               | Count |
|----------------------|-------|
| Repositories created | 6     |
| Issue comments       | 309   |
| Issues opened        | 40    |
| Issues closed        | 30    |
| Repos open sourced   | 1     |
| Pull requests opened | 32    |
| Pull requests merged | 35    |
| Versions released    | 3     |
| Pushes               | 442   |
| Commits              | 1548  |
| Total events         | 945   |

Metrics will also be broken down by organization, by user, and by repository
