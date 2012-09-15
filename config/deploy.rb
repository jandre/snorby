require "bundler/capistrano"

# ensures assets are symlinked correctly
load "config/recipes/base"
load "config/recipes/ruby"
load "config/recipes/apache2"
load "config/recipes/mysql"
load "config/recipes/snorby"
load "config/recipes/suricata"
load "config/recipes/barnyard2"

set(:deploy_server, Capistrano::CLI.ui.ask("Hostname of server to deploy to: ")) 
server "#{deploy_server}", :web, :app, :db, primary: true

set :user, 'deploy'
set :application, "snorby"
set :rails_env, 'production'
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :copy
set :use_sudo, false

set :scm, :git
set :repository, "git://github.com/Snorby/snorby.git"
set :branch, "cloud"

default_run_options[:pty] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

#
# Try to set the local version of tar to a GNU version
# This is done inline instead of a task so it affects
# all possible deploy:* tasks.
#
tar_cmds = [ 'tar', 'gtar', 'gnutar' ]
tar_cmds.each do |cmd| 
  if system("which #{cmd}")
    tar_ver = `#{cmd} --version`
    if tar_ver =~ /GNU/ then
      set :copy_local_tar, cmd
    end
  end
end