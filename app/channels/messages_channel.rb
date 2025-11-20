class MessagesChannel < ApplicationCable::Channel
  def subscribed
    conversation_id = params[:conversation_id]
    stream_from "messages_#{conversation_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

