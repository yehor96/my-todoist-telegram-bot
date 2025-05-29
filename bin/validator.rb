require_relative '../utils/file_reader'

class Validator
  ALLOWED_USERS = FileReader.read_lines("conf/allowed_users.txt").freeze

  def validate_user_allowed(username)
    raise ForbiddenError, "Username is missing" unless contains_user if username.nil? || username.empty?
    contains_user = ALLOWED_USERS.include?(username)
    raise ForbiddenError, "Username '#{username}' is not in the allowed users list" unless contains_user
  end
end