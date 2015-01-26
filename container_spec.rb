require 'serverspec'
require 'docker'

set :backend, :docker_exec
set :container_name, 'unbound_spec__'

module Specinfra::Backend
  class DockerExec < Exec
    def run_command(cmd, opts={})
      cmd = "docker exec -it #{Specinfra.configuration.container_name} " + cmd
      super(cmd, opts)
    end
  end
end

describe 'Unbound' do
  before(:all) do
    @container = Docker::Container.create(
      'name' => "unbound_spec__",
      'Image' => "nekoya/unbound",
      'Volumes' => {"/etc/unbound/conf.d" => {}}
    )
    conf_path = File.expand_path("./conf.d", File.dirname(__FILE__))
    @container.start(
      'Binds' => ["#{conf_path}:/etc/unbound/conf.d"]
    )
  end

  after(:all) do
    @container.stop
    @container.remove
  end

  describe port(53) do
      it { should be_listening }
  end

  describe command("dig @localhost example.com") do
    its(:stdout) { should match /93\.184\.216\.34/ }
  end

  describe command("dig @localhost myhost.dev.local") do
    its(:stdout) { should match /10\.1\.1\.10/ }
  end
end
