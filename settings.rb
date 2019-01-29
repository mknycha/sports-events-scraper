require 'ostruct'

Settings = OpenStruct.new(
  reporting_conditions: {
    # If live event time is after this number of minutes,
    # it will be qualified for reporting
    after_minutes: 49,
    # If live event time is after this number of minutes,
    # it will not be qualified for reporting
    before_minutes: 56,
    # If the goal difference is equal to this number (absolute value),
    # it will be qualified for reporting
    goal_difference: 1
  },
  # Specifies how often scraper is to be run, in seconds.
  # If set to 60, Web Scraper will be checking website every 60 seconds
  time_interval: 120,
  # Info about events will be sent to this email
  recipient_email: '***REMOVED***'
)
