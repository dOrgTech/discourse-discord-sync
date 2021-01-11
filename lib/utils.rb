class Util
  def self.sync_from_discord(discord_id)
    builder = DB.build("select u.* from user_associated_accounts uaa, users u /*where*/")
    builder.where("provider_name = :provider_name", provider_name: "discord")
    builder.where("uaa.user_id = u.id")
    builder.where("uaa.provider_uid = :discord_id", discord_id: discord_id)
    builder.query.each do |t|
      self.sync_user(t)
    end
  end

  def self.sync_user(user)
    console.log(user)

    discord_id = 0

    builder = DB.build("select uaa.provider_uid from user_associated_accounts uaa /*where*/ limite 1")
    builder.where("provider_name = :provider_name", provider_name: "discord")
    builder.where("uaa.user_id = u.id")
    builder.where("uaa.user_id = :user_id", user_id: user.id)
    builder.query.each do |t|
      discord_id = t.provider_uid
    end

    if discord_id != 0 then
      groups = []

      builder = DB.build("select g.name from groups g, group_users gu /*where*/")
      builder.where("g.visibility_level = :visibility", visibility: 0)
      builder.where("g.id = gu.group_id")
      builder.where("gu.user_id = :user_id", user_id: user.id)
      builder.query.each do |t|
        groups << t.name
      end
      
      $bot.servers do |server|
        member = server.member(discord_id)

        member.roles do |role| then
          if !groups.include? role then
            member.remove_role(role)
          end
        end

        groups do |group|
          if !member.role(group) then
            member.add_role(group)
          end
        end
      end

    end
  end
end