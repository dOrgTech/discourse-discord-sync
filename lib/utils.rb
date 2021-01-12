class Util
  def self.sync_from_discord(discord_id)
    builder = DB.build("select u.* from user_associated_accounts uaa, users u /*where*/ limit 1")
    builder.where("provider_name = :provider_name", provider_name: "discord")
    builder.where("uaa.user_id = u.id")
    builder.where("uaa.provider_uid = :discord_id", discord_id: discord_id)

    result = builder.query

    if result.size == 0 then
      
      # No profile on Discourse? Then just remove all roles from Discord
      Instance::bot.servers.each do |key, server|
        member = server.member(discord_id)
        member.roles.each do |role|
          Instance::bot.send_message(SiteSetting.discord_bot_admin_channel_id, "@#{user.username} removed role #{role.name}")
          member.remove_role(role)
        end
      end

    else

      # Process and sync the user
      result.each do |t|
        self.sync_user(t)
      end

    end
  end

  def self.sync_user(user)
    discord_id = 0

    # Fetch the Discord ID from database
    builder = DB.build("select uaa.provider_uid from user_associated_accounts uaa /*where*/ limit 1")
    builder.where("provider_name = :provider_name", provider_name: "discord")
    builder.where("uaa.user_id = :user_id", user_id: user.id)
    builder.query.each do |t|
      discord_id = t.provider_uid
    end

    if discord_id > 0 then
      groups = []

      # Get user groups from database
      builder = DB.build("select g.name from groups g, group_users gu /*where*/")
      builder.where("g.visibility_level = :visibility", visibility: 0)
      builder.where("g.id = gu.group_id")
      builder.where("gu.user_id = :user_id", user_id: user.id)
      builder.query.each do |t|
        groups << t.name
      end
      
      # For each server, just keep things synced
      Instance::bot.servers.each do |key, server|
        member = server.member(discord_id)
        if member then

          # Make nickname the same as Discourse username
          if member.nick != user.username && SiteSetting.discourse_sync_username then
            Instance::bot.send_message(SiteSetting.discord_sync_admin_channel_id, "Update @#{user.username}")
            member.set_nick(user.username)
          end

          unless SiteSetting.discord_sync_verified_role == "" then
            unless member.role?(SiteSetting.discord_sync_verified_role) then
              Instance::bot.send_message(SiteSetting.discord_sync_admin_channel_id, "@#{user.username} granted role #{SiteSetting.discord_sync_verified_role}")
              member.add_role(SiteSetting.discord_sync_verified_role)
            end
          end

          member.roles.each do |role|
            unless (groups.include? role.name) || (SiteSetting.discord_sync_safe_roles.include? role.name) then
              Instance::bot.send_message(SiteSetting.discord_sync_admin_channel_id, "@#{user.username} removed role #{role.name}")
              member.remove_role(role)
            end
          end

          groups.each do |group|
            unless member.role?(group) then
              Instance::bot.send_message(SiteSetting.discord_sync_admin_channel_id, "@#{user.username} granted role #{group}")
              member.add_role(group)
            end
          end

        end
      end
    end
  end
end