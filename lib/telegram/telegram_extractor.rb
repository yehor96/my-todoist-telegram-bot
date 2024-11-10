class TelegramExtractor

  def extract_data(message)
    @message = message
    text = extract_text
    return nil if text.nil?

    data = {
      text: text,
      sender: extract_sender
    }
  end

  private

  def extract_text
    @message.text || @message.caption
  end
  
  def extract_sender
    if @message.forward_from
      extract_sender_from(@message.forward_from)
    elsif @message.forward_from_chat
      @message.forward_from_chat.title || @message.forward_from_chat.username
    elsif @message.from
      extract_sender_from(@message.from)
    else
      nil
    end
  end

   def extract_sender_from(object)
    first_name = object.first_name
    last_name = object.last_name
    username = object.username
    
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