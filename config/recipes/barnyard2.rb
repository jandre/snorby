namespace :barnyard2 do
  desc "Install the latest stable release of Barnyard2."
  task :install, roles: :db, only: {primary: true} do
    run "wget http://www.securixlive.com/download/barnyard2/barnyard2-1.9.tar.gz"
    run "tar zxvf barnyard2-1.9.tar.gz"
    run "cd barnyard2-1.9 && ./configure --with-mysql --with-mysql-libraries=/usr/lib/i386-linux-gnu && make && #{sudo} make install"
    run "#{sudo} mkdir /var/log/barnyard2"
  end
  after "deploy:install", "barnyard2:install"


  desc "Set barnyard configuration file."
  task :setup, roles: :app do
    template "barnyard2.conf.erb", "/tmp/barnyard2.conf"
    run "#{sudo} mv /tmp/barnyard2.conf /etc/suricata/barnyard2.conf "
    run "#{sudo} suricata -c /etc/suricata/suricata.yaml -i eth0 -D"
    run "#{sudo} barnyard2 -c /etc/suricata/barnyard2.conf -d /var/log/suricata -f unified2.alert -w /var/log/suricata/suricata.waldo -D"

  end
  after "deploy:setup", "barnyard2:setup"
end