require 'net/http'
require 'uri'
require 'json'
require 'logger'

require_relative '../../bin/configurator'

class TodoistClient
  BASE_URL = 'https://api.todoist.com/rest/v2'.freeze

  def initialize
    config = Configurator.new
    @todoist_token = config.prop 'todoist_token'
    @logger = Logger.new(STDOUT)

    # Urls
    @tasks_url = URI.parse("#{BASE_URL}/tasks")
    @projects_url = URI.parse("#{BASE_URL}/projects")
    @comments_url = URI.parse("#{BASE_URL}/comments")
  end

  def create_task(options)
    request = post_request(@tasks_url)
    request.body = options.to_json

    begin
      response = http(@tasks_url).request(request)
      id = JSON.parse(response.body)['id']
      @logger.info("Created task '#{options[:content]}' with id: #{id}")
      id
    rescue StandardError => e
      @logger.error("Error creating task: #{e.message}")
      nil
    end
  end

  def get_tasks(project_id)
    tasks_url = @tasks_url.dup
    tasks_url.query = URI.encode_www_form(project_id: project_id)
    request = get_request(tasks_url)

    begin
      response = http(@tasks_url).request(request)
      JSON.parse(response.body)
    rescue StandardError => e
      @logger.error("Error getting tasks: #{e.message}")
      nil
    end
  end

  def get_projects
    request = get_request(@projects_url)
    begin
      response = http(@projects_url).request(request)
      JSON.parse(response.body)
    rescue StandardError => e
      @logger.error("Error getting all projects: #{e.message}")
      nil
    end
  end

  def add_comment(options)
    request = post_request(@comments_url)
    request.body = options.to_json

    begin
      response = http(@comments_url).request(request)
      id = JSON.parse(response.body)['id']
      @logger.info("Added comment '#{options[:content]}' with id: #{id}")
      id
    rescue StandardError => e
      @logger.error("Error adding comment: #{e.message}")
      nil
    end
  end

  private

  def get_request(url)
    Net::HTTP::Get.new(url.request_uri, request_values)
  end

  def post_request(url)
    Net::HTTP::Post.new(url.request_uri, request_values)
  end

  def request_values
    {
        'Content-Type' => 'application/json', 
        'Authorization' => 'Bearer ' + @todoist_token
    }
  end

  def http(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http
  end
end