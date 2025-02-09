class TelegramExtractor

  def extract_data(message)
    @message = message
    text = extract_text
    return nil if text.nil?

    data = {
      text: text,
      sender: extract_sender,
      links: extract_links,
      username: extract_username
    }
  end

  private

  def extract_username
    @message.from.username || ''
  end

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

  def extract_links
    links = []

    if @message.entities&.any?
      links.concat(@message.entities.map do |entity|
        entity.url if is_non_telegram_link?(entity)
      end.compact)
    end

    if @message.caption_entities&.any?
      links.concat(@message.caption_entities.map do |entity|
        entity.url if is_non_telegram_link?(entity)
      end.compact)
    end

    links
  end

  def is_non_telegram_link?(entity)
    return false if entity.nil? || entity.url.nil?
    return false unless entity.type == 'text_link' || entity.type == 'url'
    return !entity.url.start_with?('https://t.me')
  end

end