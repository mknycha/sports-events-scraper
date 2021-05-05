# Simple betting tool

The app does the following things:
- It scraps the live football events stats
- Analyzes the stats
- It sends an email if there is a particular situation in the stats (goal difference, particular possession etc.)

It uses pure Ruby, selenium for webscraping, PostgreSQL as a database.
There is also some logic that is supposed to be processed in the background - you can find it in the `workers` folder.
Background processing is handled by `resque` gem, it requires Redis (used as a queue).
The repo also includes a configuration to deploy it to Amazon EC2 using Amazon CodeDeploy.

Note that binaries under bin folder are for linux (I ran it under Amazon Linux AMI 2018.03.0)

## Dependencies
- Ruby version 2.6.3
- PostgreSQL 13.2
- Redis 6.2.2

## How to run it?

1. Create a postgres database that you want to use
2. Create an .env file. Example:
```
EMAIL_ADDRESS=emails.sender@example.com
EMAIL_PASSWORD=secretpassword
RECIPIENT_EMAIL=emails.receiver@example.com
DRIVER_PATH=bin/chromedriver
BINARY_PATH=bin/headless-chromium
POSTGRESQL_USER=web_scraper_development
RUBY_ENV=development
```
3. Run `scripts/start_server` and `scripts/start_workers` (these scripts will run processes in the background). Logs will be saved in the `logs` folder.
4. To later stop execution of the main server and the workers, use `scripts/stop_server` and `scripts/stop_workers` accordingly.

## Deployment

1. Zip the app:
```
zip -r app.zip settings.rb scrap_live_events.rb Rakefile mailer_initializer.rb load_files.rb Gemfile Gemfile.lock appspec.yml .standalone_migrations spec/ scripts logs/ initializers db/ config classes bin config
```
2. Upload to S3
3. Create a new deployment in codedeploy