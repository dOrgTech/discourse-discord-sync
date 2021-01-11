require 'discordrb'

module NewMember
  extend Discordrb::EventContainer

  member_join do |event|
    Util.sync_from_discord(event.user.id)
  end
end

class Bot
  def self.run_bot
    $discord = Discordrb::Commands::CommandBot.new token: SiteSetting.discord_bot_token, prefix: SiteSetting.discord_bot_prefix
    $discord.bucket :admin_tasks, limit: 3, time_span: 60, delay: 10
    
    $discord.include! NewMember

    $discord.ready do |event|
      puts "Logged in as #{$discord.profile.username} (ID:#{$discord.profile.id}) | #{$discord.servers.size} servers"
      $discord.send_message(SiteSetting.discord_bot_admin_channel_id, "Discourse/Discord Bot Sync started!")
    end

    $discord.command(:ping) do |event|
      event.respond 'Pong!'
    end

    $discord.run
  end
end
