namespace :ruby do
  desc "Install Ruby 1.9.3-p194 and bundler gem"
  task :install, roles: :app do
    run "wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz"
    run "tar -xvzf ruby-1.9.3-p194.tar.gz"
    run "cd /home/deploy/ruby-1.9.3-p194 && ./configure && make && #{sudo} make install"
    run "rm -rf /home/deploy/ruby-1.9.3-p194"
    run "rm /home/deploy/ruby-1.9.3-p194.tar.gz"
    run "#{sudo} gem install bundler"
  end
  after "deploy:install", "ruby:install"
end