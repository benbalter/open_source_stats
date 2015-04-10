# Open Source Stats

*A quick script to generate metrics about the contribution your organization makes to the open source community in a 24-hour period*.

## What it looks at

* Public activity across all public repositories from members of a given team
* Public activity across all users on repositories owned by a given organization or organizations

## How it works

By doing terrible, terrible things to GitHub's events API.

## Setup

1. Clone down the repo
2. Create a `.env` file and add the following:
  * `GITHUB_TOKEN` - A personal access token with `read:org` scope
  * `GITHUB_TEAM_ID` - The numeric ID of the team to pull users from (e.g., 12345)
  * `GITHUB_ORGS` - A comma separated list of the orgs to look at (e.g, `github,atom`)
3. Run `bundle exec oss`

This will spit markdown formatted results into standard out.
