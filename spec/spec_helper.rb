$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'byebug'
require 'terrestrial'

def mock_web(method)
  client = object_double(Terrestrial::Web.new("fake_api_key"))
  response = double(
    Terrestrial::Web::Response.new(nil),
    success?: true,
    response: { "data" => {} }
  )
  yield response if block_given?

  allow(Terrestrial::Web).to receive(:new)
    .with(any_args)
    .and_return(client)

  allow(client).to receive(method).and_return(response)
end

def mock_project_config
  config = Hash.new
  yield config if block_given?
  allow(Terrestrial::Config).to receive(:_project_config).and_return(config)
  allow(Terrestrial::Config).to receive(:update_project_config)
end

def mock_global_config
  config = Hash.new
  yield config if block_given?
  allow(Terrestrial::Config).to receive(:_global_config).and_return(config)
  allow(Terrestrial::Config).to receive(:update_global_config)
end

def capture_stdout(proc_object = nil, &block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    proc_object.call unless proc_object.nil?
    yield if block_given?
  ensure
    $stdout = original_stdout
  end
  fake.string
end

def capture_stderr(proc_object = nil, &block)
  original_stderr = $stderr
  $stderr = fake = StringIO.new
  begin
    proc_object.call unless proc_object.nil?
    yield if block_given?
  ensure
    $stderr = original_stderr
  end
  fake.string
end
