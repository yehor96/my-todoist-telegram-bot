class TelegramExtractor

  def extract_message(message)
    message.text || message.caption
  end
  
  def extract_sender(message)
    if message.forward_from
      extract_forward_from(message)
    elsif message.forward_from_chat
      message.forward_from_chat.title || message.forward_from_chat.username
    else
      nil
    end
  end
    
   def extract_forward_from(message)
    first_name = message.forward_from.first_name
    last_name = message.forward_from.last_name
    username = message.forward_from.username
    
    if first_name.nil? && last_name.nil?
      username
    elsif first_name.nil?
      last_name
    elsif last_name.nil?
      first_name
    else
      "#{first_name} #{last_name}"
    end
  end
end