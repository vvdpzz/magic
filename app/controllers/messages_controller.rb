class MessagesController < ApplicationController
  include ActionView::Helpers::DateHelper
  
  def index
    
  end
  def conversations
    
  end
  
  def load_conversations
      conversation_list = $redis.zrange("messages:#{current_user.id}", 0, -1)
      data = []
      conversation_list.each do |conver_id|
        hash = load_conversation(conver_id)
        hash[:messages] = load_messages(conver_id)
        data << hash
      end
      $redis.del("messages:#{current_user.id}:unread_messages")
      $redis.del("messages:#{current_user.id}:unreadcount")
      render :json => data
    end
  
  def load_conversation(conver_id)
        key = "messages:#{current_user.id}:#{conver_id}"
        last_message = MultiJson.decode($redis.lrange(key, -1, -1)[0])
        hash = {}
        hash[:unread_message_count] = $redis.get(key + ":unreadcount")
        if conver_id == last_message["sender_id"]
          hash[:friend_name]    = last_message["sender_name"]
          hash[:friend_picture] = last_message["sender_avatar"]
        else
          hash[:friend_name]    = last_message["receiver_name"]
          hash[:friend_picture] = last_message["receiver_avatar"]
        end
        hash[:friend_token]   = conver_id
        hash[:last_update]    = last_message["created_at"]
        
        return hash
    end
  
  def remove_conversation
    friend_id = params[:friend_token]
    $redis.del("messages:#{current_user.id}:#{friend_id}:unreadcount")
    $redis.del("messages:#{current_user.id}:#{friend_id}")
    $redis.zrem("messages:#{current_user.id}", friend_id)
    render :json => { :rc => 0 }
  end
  
  def messages
    @friend = User.select("name").find_by_id params[:friend_token]
  end
  
  def load_messages(friend_id)
      message_list = []
      message_list_redis = $redis.lrange("messages:#{current_user.id}:#{friend_id}", 0, -1)
      message_list_redis.each do |message_redis|
        message_redis_hash = MultiJson.decode(message_redis)
        message = {}
        message[:owner_picture]     = message_redis_hash["sender_avatar"]
        message[:owner_profile_url] = "/users/" + message_redis_hash["sender_id"].to_s
        message[:text]              = message_redis_hash["text"]
        message[:time_created]      = message_redis_hash["created_at"]
        message[:owner_name]        = message_redis_hash["sender_name"]
        message_list << message
      end
      return message_list
  end
  
  def set_unreadcount
    friend_id = params[:friend_token]
    $redis.set("messages:#{current_user.id}:#{friend_id}:unreadcount", 0)
    render :json => { :rc => 0 }
  end
  
  def send_message
    sender    = User.basic(current_user.id)
    receiver  = User.basic(params[:recipient_token])
    
    hash = {}
    hash[:created_at]     = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    hash[:text]           = params[:text]
    hash[:sender_id]      = sender.id.to_s
    hash[:sender_name]    = sender.name
    
    # add to user's unread message list
    $redis.rpush("messages:#{receiver.id}:unread_messages", MultiJson.encode(hash))
    Pusher["presence-messages_#{receiver.id}"].trigger('message_created', MultiJson.encode(hash))
    
    hash[:sender_avatar]    = sender.gavatar
    hash[:receiver_avatar]  = receiver.gavatar
    hash[:receiver_id]      = receiver.id.to_s
    hash[:receiver_name]    = receiver.name
    
    sender_conver_timecount    = $redis.incr("messages:#{sender.id}:count")
    receiver_conver_timecount  = $redis.incr("messages:#{receiver.id}:count")
    # add to user's conversation set
    $redis.zadd("messages:#{sender.id}", sender_conver_timecount, "#{receiver.id}")
    $redis.zadd("messages:#{receiver.id}", receiver_conver_timecount, "#{sender.id}")
    # add to user's message list
    $redis.rpush("messages:#{sender.id}:#{receiver.id}", MultiJson.encode(hash))
    $redis.rpush("messages:#{receiver.id}:#{sender.id}", MultiJson.encode(hash))
    
    # incr user's current conversation's unread message count
    $redis.incr("messages:#{receiver.id}:#{sender.id}:unreadcount")
    # incr user'a all unread message count
    $redis.incr("messages:#{receiver.id}:unreadcount")
    
    render :json => { :outgoing => "", :rc => 0 }   
  end
  
  def remove_message
    
  end
  
  def update_last_viewed
    $redis.del("messages:#{current_user.id}:unread_messages")
    $redis.del("messages:#{current_user.id}:unreadcount")
    render :json => { :rc => 0 }
  end
  
  def load_messages_on_navbar
    unread_message_list = $redis.lrange("messages:#{current_user.id}:unread_messages", 0, -1)
    unread_message_list.collect! do |message|
      MultiJson.decode(message)
    end
    unread_count = $redis.get("messages:#{current_user.id}:unreadcount")
    render :json => { :count => unread_count, :messages => unread_message_list, :rc => 0 }
  end
  
  def load_contact_list
    contact_list = []
    user_list = $redis.smembers("users:#{current_user.id}.following_users")
    user_list.each do |user_id|
      contact_list << MultiJson.decode($redis.hget("users_info", user_id))
    end
    render :json => { :contact_list => contact_list }
  end
end
