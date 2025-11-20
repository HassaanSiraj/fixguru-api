class Api::V1::MessagesController < ApplicationController
  before_action :set_conversation_user, only: [:index, :create]

  def index
    messages = Message.conversation_between(current_user, @other_user)
    render json: messages.as_json(
      include: {
        sender: { only: [:id, :email] },
        receiver: { only: [:id, :email] }
      }
    ), status: :ok
  end

  def create
    conversation_id = Message.conversation_id_for(current_user, @other_user)
    
    message = Message.new(
      conversation_id: conversation_id,
      sender: current_user,
      receiver: @other_user,
      content: params[:content]
    )

    if message.save
      # Broadcast via ActionCable
      ActionCable.server.broadcast(
        "messages_#{conversation_id}",
        message: message.as_json(
          include: {
            sender: { only: [:id, :email] },
            receiver: { only: [:id, :email] }
          }
        )
      )

      render json: message, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def conversations
    # Get all unique conversations for current user
    conversation_ids = Message.where(
      'sender_id = ? OR receiver_id = ?',
      current_user.id,
      current_user.id
    ).distinct.pluck(:conversation_id)

    conversations = conversation_ids.map do |conversation_id|
      last_message = Message.where(conversation_id: conversation_id).order(created_at: :desc).first
      other_user = last_message.sender_id == current_user.id ? last_message.receiver : last_message.sender
      
      {
        conversation_id: conversation_id,
        other_user: other_user.as_json(only: [:id, :email]),
        last_message: last_message.as_json(only: [:content, :created_at, :read]),
        unread_count: Message.where(conversation_id: conversation_id, receiver_id: current_user.id, read: false).count
      }
    end

    render json: conversations, status: :ok
  end

  def mark_as_read
    conversation_id = params[:conversation_id]
    Message.where(
      conversation_id: conversation_id,
      receiver_id: current_user.id,
      read: false
    ).update_all(read: true)

    render json: { message: 'Messages marked as read' }, status: :ok
  end

  private

  def set_conversation_user
    @other_user = User.find(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end
end

