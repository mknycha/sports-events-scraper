# Simple betting tool

The app does the following things:
- It scraps the live football events stats
- Analyzes the stats
- It sends an email if there is a particular situation in the stats (goal difference, particular possession etc.)

It uses pure Ruby, selenium for webscraping, PostgreSQL as a database.
The repo also includes a configuration to deploy it to Amazon EC2 using Amazon CodeDeploy.

## How to run it?

1. Create a postgres database that you want to use
2. Create an .env file. Example:
```
EMAIL_ADDRESS=emails.sender@example.com
EMAIL_PASSWORD=secretpassword
RECIPIENT_EMAIL=emails.receiver@example.com
DRIVER_PATH=bin_local/chromedriver
POSTGRESQL_USER=web_scraper_development
RUBY_ENV=development
```
3. Run `bundle exec ruby scrap_live_events.rb`