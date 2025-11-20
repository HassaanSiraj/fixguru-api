class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  # Validations
  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
  validates :conversation_id, presence: true

  # Scopes
  scope :unread, -> { where(read: false) }
  scope :for_conversation, ->(id) { where(conversation_id: id).order(created_at: :asc) }

  # Methods
  def mark_as_read!
    update!(read: true)
  end

  def self.conversation_between(user1, user2)
    id1 = [user1.id, user2.id].min
    id2 = [user1.id, user2.id].max
    conversation_id = "conversation_#{id1}_#{id2}"
    for_conversation(conversation_id)
  end

  def self.conversation_id_for(user1, user2)
    id1 = [user1.id, user2.id].min
    id2 = [user1.id, user2.id].max
    "conversation_#{id1}_#{id2}"
  end
end
