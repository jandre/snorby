set_default(:mysql_password) { Capistrano::CLI.password_prompt "MySQL Password: " }

namespace :mysql do
  desc "Install the latest stable release of MySQL."
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} apt-get -y update"
    install_package "mysql-server mysql-client libmysqlclient-dev"
  end
  after "deploy:install", "mysql:install"

  desc "Set password and generate the database.yml configuration file."
  task :setup, roles: :app do
    run "#{sudo} mysqladmin -u root password #{mysql_password}"
    run "mkdir -p #{shared_path}/config"
    template "database.yml.erb", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "mysql:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "mysql:symlink"
end