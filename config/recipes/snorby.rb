namespace :snorby do
  task :config_copy, roles: :app do
  desc "Copy default configuration"
    put(File.read(File.expand_path("../../snorby_config.yml.example", __FILE__)), "#{shared_path}/snorby_config.yml")
    run "ln -nfs #{shared_path}/snorby_config.yml #{release_path}/config/snorby_config.yml"
    run "cd #{release_path} && bundle exec rake snorby:setup"
  end
  after "deploy:finalize_update", "snorby:config_copy"
end