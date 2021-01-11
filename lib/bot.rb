require 'discordrb'

module NewMember
  extend Discordrb::EventContainer

  member_join do |event|
    Util.sync_from_discord(event.user.id)
  end
end

class Bot
  def self.run_bot
    $bot = Discordrb::Commands::CommandBot.new token: SiteSetting.discord_bot_token, prefix: SiteSetting.discord_bot_prefix
    $bot.bucket :admin_tasks, limit: 3, time_span: 60, delay: 10
    
    $bot.include! NewMember

    $bot.ready do |event|
      puts "Logged in as #{$bot.profile.username} (ID:#{$bot.profile.id}) | #{$bot.servers.size} servers"
      $bot.send_message(SiteSetting.discord_bot_admin_channel_id, "Discourse/Discord Bot started!")
    end

    $bot.command(:ping) do |event|
      event.respond 'Pong!'
    end

    $bot.run
  end
end
