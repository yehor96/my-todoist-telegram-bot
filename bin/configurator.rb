require 'yaml'

class Configurator

  def initialize
    @config ||= YAML.load_file('config/secrets.yml')
  end

  def prop(key)
    @config[key.to_s] || ENV[key.to_s]
  end
 end