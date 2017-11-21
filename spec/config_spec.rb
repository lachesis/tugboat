require 'spec_helper'

describe Tugboat::Configuration do
  include_context 'spec'

  let(:tmp_path) { project_path + '/tmp/tugboat' }

  after do
    # Clean up the temp file.
    File.delete(project_path + '/tmp/tugboat') if File.exist?(project_path + '/tmp/tugboat')
  end

  it 'is a singleton' do
    expect(described_class).to be_a Class
    expect do
      described_class.new
    end.to raise_error(NoMethodError, %r{private method `new' called})
  end

  it 'has a data attribute' do
    config = described_class.instance
    expect(config.data).to be
  end

  describe 'the file' do
    let(:access_token)       { 'foo' }
    let(:ssh_user)           { 'root' }
    let(:ssh_key_path)       { '~/.ssh/id_rsa2' }
    let(:ssh_port)           { '22' }
    let(:region)             { 'lon1' }
    let(:image)              { 'ubuntu-14-04-x64' }
    let(:size)               { '512mb' }
    let(:ssh_key_id)         { '1234' }
    let(:private_networking) { 'false' }
    let(:backups_enabled)    { 'false' }
    let(:ip6)                { 'false' }
    let(:timeout)            { '30' }

    let(:config) { described_class.instance }

    before do
      # Create a temporary file
      config.create_config_file(access_token, ssh_key_path, ssh_user, ssh_port, region, image, size, ssh_key_id, private_networking, backups_enabled, ip6, timeout)
    end

    it 'can be created' do
      expect(File.exist?(tmp_path)).to be_truthy
    end

    it 'can be loaded' do
      data = config.load_config_file
      expect(data).not_to be_nil
    end

    describe 'the file format'
    let(:data) { YAML.load_file(tmp_path) }

    it 'has authentication at the top level' do
      expect(data).to have_key('authentication')
    end

    it 'has ssh at the top level' do
      expect(data).to have_key('ssh')
    end

    it 'has an access token' do
      auth = data['authentication']
      expect(auth).to have_key('access_token')
    end

    it 'has an ssh key path' do
      ssh = data['ssh']
      expect(ssh).to have_key('ssh_key_path')
    end

    it 'has an ssh user' do
      ssh = data['ssh']
      expect(ssh).to have_key('ssh_user')
    end

    it 'has an ssh port' do
      ssh = data['ssh']
      expect(ssh).to have_key('ssh_port')
    end

    it 'has private_networking set' do
      private_networking = data['defaults']
      expect(private_networking).to have_key('private_networking')
    end

    it 'has backups_enabled set' do
      backups_enabled = data['defaults']
      expect(backups_enabled).to have_key('backups_enabled')
    end

    it 'has timeout set' do
      timeout_set = data['connection']
      expect(timeout_set).to have_key('timeout')
    end
  end
  describe 'backwards compatible' do
    let(:client_key)       { 'foo' }
    let(:api_key)          { 'bar' }
    let(:ssh_user)         { 'baz' }
    let(:ssh_key_path)     { '~/.ssh/id_rsa2' }
    let(:ssh_port)         { '22' }

    let(:config)                    { described_class.instance }
    let(:config_default_region)     { Tugboat::Configuration::DEFAULT_REGION }
    let(:config_default_image)      { Tugboat::Configuration::DEFAULT_IMAGE }
    let(:config_default_size)       { Tugboat::Configuration::DEFAULT_SIZE }
    let(:config_default_ssh_key)    { Tugboat::Configuration::DEFAULT_SSH_KEY }
    let(:config_default_networking) { Tugboat::Configuration::DEFAULT_PRIVATE_NETWORKING }
    let(:config_default_backups)    { Tugboat::Configuration::DEFAULT_BACKUPS_ENABLED }
    let(:config_default_ip6)	{ Tugboat::Configuration::DEFAULT_IP6 }
    let(:backwards_config) do
      {
        'authentication' => { 'client_key' => client_key, 'api_key' => api_key },
        'ssh' => { 'ssh_user' => ssh_user, 'ssh_key_path' => ssh_key_path, 'ssh_port' => ssh_port }
      }
    end

    before do
      config.instance_variable_set(:@data, backwards_config)
    end

    it 'loads a backwards compatible config file' do
      data_file = config.instance_variable_get(:@data)
      expect(data_file).to eql backwards_config
    end

    it 'uses default region if not in configuration' do
      region = config.default_region
      expect(region).to eql config_default_region
    end

    it 'uses default image if not in configuration' do
      image = config.default_image
      expect(image).to eql config_default_image
    end

    it 'uses default size if not in configuration' do
      size = config.default_size
      expect(size).to eql config_default_size
    end

    it 'uses default ssh key if not in configuration' do
      ssh_key = config.default_ssh_key
      expect(ssh_key).to eql config_default_ssh_key
    end

    it 'uses default private networking option if not in configuration' do
      private_networking = config.default_private_networking
      expect(private_networking).to eql config_default_networking
    end

    it 'uses default backups_enabled if not in the configuration' do
      backups_enabled = config.default_backups_enabled
      expect(backups_enabled).to eql config_default_backups
    end

    it 'uses default ip6 if not in the configuration' do
      ip6 = config.default_ip6
      expect(ip6).to eql config_default_ip6
    end
  end
end
