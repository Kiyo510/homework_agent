# frozen_string_literal: true

class RoomsController < ApplicationController
  before_action :authenticate_user, only: %i[index show]

  def create
    @room = Room.create
    # Entryモデルにログインユーザーのレコードを作成
    current_user_entry = Entry.create(user_id: current_user.id, room_id: @room.id)
    # Entryモデルにメッセージ相手のレコードを作成
    another_user_entry = Entry.create(user_id: params[:entry][:user_id], room_id: @room.id)
    redirect_to room_path(@room)
  end

  def index
    # ログインユーザーが属しているルームのIDを全て抽出して配列化
    current_entries = current_user.entries.eager_load(:room)
    my_room_ids = []
    current_entries.find_each do |entry|
      my_room_ids << entry.room.id
    end
    # さらにuser_idがログインユーザーでは無いレコードを抽出
    @another_entries = Entry.eager_load(:room, :user, user: { avatar_attachment: :blob })
                            .where(room_id: my_room_ids)
                            .where.not(user_id: current_user.id)
  end

  def show
    @room = Room.find(params[:id])
    if Entry.where(user_id: current_user.id, room_id: @room.id).present?
      @message = Message.new
      # メッセージ相手を抽出
      @messages = @room.messages.eager_load(:user, user: { avatar_attachment: :blob })
      @another_user_entry = @room.entries.find_by('user_id != ?', current_user.id)
    else
      redirect_back(fallback_location: root_path)
    end
  end
end
