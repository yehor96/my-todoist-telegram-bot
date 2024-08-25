require 'yaml'

class Configurator
  @config = nil

  def self.load
    @config ||= YAML.load_file('config/secrets.yml')
  end
 end