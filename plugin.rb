# name: Discord Sync
# about: Sync a Discord server with a Discourse community
# version: 0.1
# authors: Diego Barreiro
# url: https://github.com/barreeeiroo/discourse-discord-sync

gem 'discordrb', '3.3.0'


enabled_site_setting :discord_bot_enabled

after_initialize do

  require_dependency File.expand_path('../lib/bot.rb', __FILE__)
  require_dependency File.expand_path('../lib/util.rb', __FILE__)

  bot_thread = Thread.new do
    begin
      Bot.run_bot
    rescue Exception => ex
      Rails.logger.error("Discord Bot: There was a problem: #{ex}")
    end
  end

  # Add event hook to username update
  User.class_eval do
    after_save do |user|
      if user.id > 0 Util.sync_user(user) end
    end
  end

  # Sync users on badge grnat
  DiscourseEvent.on(:user_added_to_group) do |user, group, automatic|
    if user.id > 0 Util.sync_user(user) end
  end

  # Sync users on badge grnat
  DiscourseEvent.on(:user_removed_from_group) do |user, group|
    if user.id > 0 Util.sync_user(user) end
  end

  # Sync users on create and update
  DiscourseEvent.on(:username_updated) do |user|
    if user.id > 0 Util.sync_user(user) end
  end

  STDERR.puts '---------------------------------------------------'
  STDERR.puts 'Bot should now be spawned, say "Ping!" on Discord!'
  STDERR.puts '---------------------------------------------------'
  STDERR.puts '(-------      If not check logs          ---------)'
end
