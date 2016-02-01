$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'terrestrial'

def mock_project_config
  config = Hash.new
  yield config if block_given?
  allow(Terrestrial::Config).to receive(:_project_config).and_return(config)
end

def mock_global_config
  config = Hash.new
  yield config if block_given?
  allow(Terrestrial::Config).to receive(:_global_config).and_return(config)
end

def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end

def capture_stderr(&block)
  original_stderr = $stderr
  $stderr = fake = StringIO.new
  begin
    yield
  ensure
    $stderr = original_stderr
  end
  fake.string
end
