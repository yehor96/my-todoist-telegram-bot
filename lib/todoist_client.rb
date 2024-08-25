require 'net/http'
require 'uri'
require 'json'
require 'logger'

class TodoistClient

  def initialize
    config = Configurator.load
    @todoist_token = config['todoist_token']
    @tasks_url = URI.parse('https://api.todoist.com/rest/v2/tasks')
    @logger = Logger.new(STDOUT)
  end

  def create_task(options)
    request = post_request(@tasks_url)
    request.body = {
        content: options[:content],
        description: options[:description],
        project_id: options[:project_id],
        labels: options[:labels]
    }.to_json

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

  private

  def post_request(url)
    Net::HTTP::Post.new(url.request_uri, { 
        'Content-Type' => 'application/json', 
        'Authorization' => 'Bearer ' + @todoist_token
    })
  end

  def http(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http
  end
end