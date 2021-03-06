# frozen_string_literal: true
# rubocop:disable all

module SetRoomForDirectMessage
  extend ActiveSupport::Concern

  def set_room_for_direct_message
    @current_user_entry.find_each do |current|
      @another_user_entry.find_each do |another|
        # ルームが存在する場合
        if current.room_id == another.room_id
          @is_room = true
          @room_id = current.room_id
        end
      end
    end
    # ルームが存在しない場合は新規作成
    return if @is_room
    @room = Room.new
    @entry = Entry.new
  end
end
