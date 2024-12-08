require 'yaml'

class Configurator

  def initialize
    @config ||= YAML.load_file(File.expand_path('../config/secrets.yml', __dir__))
  end

  def prop(key)
    @config[key.to_s] || ENV[key.to_s]
  end
 end