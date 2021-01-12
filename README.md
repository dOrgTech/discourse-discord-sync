# Discord Sync

A Discourse plugin that runs a Discord bot to keep things synced between a Discourse forum and a Discord server.

This plugin depends on Discord OAuth2 to identify and link Discourse-Discord accounts. If you don't want to allow
users to login with Discord, but you wish to keep linking account, check
[the solution to this topic](https://meta.discourse.org/t/partially-enable-login-option/175330/4?u=barreeeiroo).

This bot will sync all public Discourse groups with Discord roles. It will automatically trigger an update when an user
links their Discord account, user groups are changed or profile gets updated.

## Installation Instructions

1. Follow the standard guide at [How to install a plugin?](https://meta.discourse.org/t/install-a-plugin/19157?u=barreeeiroo)
with this repository URL.
2. Follow [this guide](https://meta.discourse.org/t/configuring-discord-login-for-discourse/127129) to set up Login with Discord
in your Discourse instance.
3. In the Discord Developer portal, go to Bot, and add it to your server. Make sure you grant him the highest possible role.
4. In Discourse, in Plugin Settings, set `discord sync token` with the Bot token that appears in the previous step.

## Configuration

- **`discord sync enabled`**: Whether or not to enable the integration
- **`discord sync token`**: Bot token from Discord
- **`discord sync prefix`**: Prefix for commands (just `!ping` by now)
- **`discord sync admin channel id`**: Channel to post logging messages (nick changes, role changes)
- **`discord sync username`**: If true, it will sync all Discord server nicknames to their Discourse username
- **`discord sync verified role`**: Role to add to all users who have a Discourse account
- **`discord sync safe roles`**: List of roles that bot will ignore and will mark as manually granted in Discord
