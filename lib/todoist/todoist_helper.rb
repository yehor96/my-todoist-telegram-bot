require_relative '../../lib/todoist/todoist_client'

class TodoistHelper

  def initialize
    @todoist = TodoistClient.new
  end

  def get_task_by_label(label)
    @todoist.get_tasks(inbox_id).find do |task|
      task['labels'].include?(label)
    end
  end

  def inbox_id
    @todoist.get_projects.each do |project|
      return project['id'] if project['name'] == 'Inbox'
    end
    raise RuntimeError, "Illegal condition - Inbox project not found"
  end
end