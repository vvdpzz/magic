#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Magic::Application.load_tasks

namespace :custom do 
  desc "Restart unicorn & rails services"
  task :restarts do
    puts "Refresh the assets..."
    %x[rake assets:clean && rake assets:precompile]
    puts "Restarting unicorn..."
    %x[/etc/init.d/unicorn_init restart]
    puts "Restarting nginx..."
    %x[sudo /etc/init.d/nginx restart]
  end
  
  desc "Stop unicorn & rails services"
  task :stops do
    puts "Stop unicorn..."
    %x[/etc/init.d/unicorn_init stop]
    puts "Stop nginx..."
    %x[sudo /etc/init.d/nginx stop]
  end
end
