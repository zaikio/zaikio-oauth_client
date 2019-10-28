namespace :db do
  desc 'Kicks all users from the database'
  task :terminate_sessions => :environment do
    ActiveRecord::Base.connection.execute(
      "SELECT pg_terminate_backend(pg_stat_activity.pid)
       FROM pg_stat_activity
       WHERE datname = current_database()
       AND pid <> pg_backend_pid();"
    )
  end
end
