namespace :suricata do
  desc "Install the latest stable release of Suricata."
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} apt-get -y update"
    install_package "libpcre3 libpcre3-dbg libpcre3-dev " +
     "build-essential autoconf automake libtool libpcap-dev libnet1-dev " +
     "libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libcap-ng-dev libcap-ng0 " +
     "make libmagic-dev"
    run "wget http://www.openinfosecfoundation.org/download/suricata-1.3.1.tar.gz"
    run "tar -xvzf suricata-1.3.1.tar.gz"
    run "cd suricata-1.3.1 && ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make && #{sudo} make install-full && #{sudo} ldconfig"
  end
  after "deploy:install", "suricata:install"
end