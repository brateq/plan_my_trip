# config valid only for current version of Capistrano
lock "3.7.2"

set :application, "PlanMyTrip"
set :repo_url, "https://github.com/brateq/plan_my_trip"

# Default branch is :master
ask :branch, (proc { `git rev-parse --abbrev-ref HEAD`.chomp })

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/brateq/plan_my_trip'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/database.yml", "config/secrets.yml", "config/application.yml"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor/bundle", "public/uploads"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :logs do
  desc 'tail rails logs'
  task :tail do
    on roles(:app) do
      execute "tail -f #{current_path}/log/production.log -n 200"
    end
  end
end
