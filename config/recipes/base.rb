def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

def install_package(packages)
  run "#{sudo} DEBIAN_FRONTEND=noninteractive apt-get -y " +
      "-o DPkg::Options::=--force-confdef " +
      "-o DPkg::Options::=--force-confold install #{packages.to_s}"
end

namespace :deploy do
  desc "Install everything onto the server"
  task :install do
    run "#{sudo} apt-get -y update"
    install_package "build-essential zlib1g-dev libssl-dev " +
     "libreadline-dev libyaml-dev libcurl4-openssl-dev curl git-core " +
     "python-software-properties default-jre-headless"
  end
end