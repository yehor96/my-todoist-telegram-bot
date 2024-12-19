require_relative '../../lib/todoist/todoist_client'

class TodoistService

  def initialize(todoist_client)
    @todoist = todoist_client
  end

  def get_tasks_by_label(label)
    @todoist.get_tasks(inbox_id).filter do |task|
      task['labels'].include?(label)
    end
  end

  def inbox_id
    @inbox_id ||= fetch_inbox_id
  end

  def add_comment(task_id, comment)
    comment_options = {
      task_id: task_id,
      content: comment
    }
    @todoist.add_comment(comment_options)
  end

  private

  def fetch_inbox_id
    @todoist.get_projects.each do |project|
      return project['id'] if project['name'] == 'Inbox'
    end
    raise RuntimeError, "Illegal condition - Inbox project not found"
  end
end