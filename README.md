# Coin Collector + Shop System

A Roblox mini-game system: players collect spinning coins in the workspace,
coins are saved permanently via DataStore, and players can spend coins on a
temporary speed boost through a shop GUI. Includes a custom live-updating
Top 5 leaderboard.

## What's included

- **Leaderstats + DataStore** -- coin count persists across sessions, saved on
  leave and on server shutdown
- **Coin instance** -- 5 spinning, pulsing coins that respawn 8 seconds after
  being collected
- **Shop UI** -- slide-in panel with a Speed Boost purchase button
- **Purchase logic** -- server-validated, server owns all prices, anti-stack
  timer for repeated purchases
- **Custom Top 5 leaderboard** -- separate from the built-in Tab leaderboard,
  refreshes every 5 seconds

## Repo structure

```
src/
  ServerScriptService/
    GameScript.lua          -> goes in ServerScriptService as a Script
  StarterGui/
    ShopGui/
      LocalScript.lua        -> goes in StarterGui > ShopGui as a LocalScript
    LeaderboardGui/
      LocalScript.lua        -> goes in StarterGui > LeaderboardGui as a LocalScript
  ReplicatedStorage/
    README.txt               -> notes on the 2 Remote objects (see below)
```

This structure mirrors the Roblox Studio Explorer hierarchy. The folder name
tells you which service the script belongs in.

---

## Setup instructions -- Roblox Studio

### 1. Enable DataStore access (required for coin saving to work in Studio)

`Home` -> `Game Settings` -> `Security` -> turn ON
**"Enable Studio Access to API Services"**

Without this, every DataStore call will fail with
`StudioAccessToApisNotAllowed`.

### 2. Create the two Remote objects

These cannot be plain files -- create them by hand in Studio:

- Right-click **ReplicatedStorage** -> Insert Object -> **RemoteEvent**
  -> rename to exactly `BuyItem`
- Right-click **ReplicatedStorage** -> Insert Object -> **RemoteFunction**
  -> rename to exactly `GetLeaderboard`

Names must match exactly (case-sensitive) -- the scripts look them up by name.

### 3. Add the server script

- Right-click **ServerScriptService** -> Insert Object -> **Script**
- Rename it `GameScript`
- Open `src/ServerScriptService/GameScript.lua` from this repo, copy the
  entire contents, paste into the Script

### 4. Add the Shop GUI

- Right-click **StarterGui** -> Insert Object -> **ScreenGui**
  -> rename to `ShopGui`
- Right-click `ShopGui` -> Insert Object -> **LocalScript**
- Copy the contents of `src/StarterGui/ShopGui/LocalScript.lua` into it

The shop button, panel, and buy button are all built in code -- you do not
need to manually create any Frames or TextButtons in Studio for the shop.

### 5. Add the Leaderboard GUI

- Right-click **StarterGui** -> Insert Object -> **ScreenGui**
  -> rename to `LeaderboardGui`
- Right-click `LeaderboardGui` -> Insert Object -> **LocalScript**
- Copy the contents of `src/StarterGui/LeaderboardGui/LocalScript.lua` into it

Same as the shop -- the board UI is built entirely in code.

### 6. Test it

Hit **Play** (Team Test recommended over single-player if you have 2+ test
accounts available):

1. Press **Tab** -- confirm the built-in leaderboard shows "Coins: 0"
2. Walk into one of the 5 spinning yellow coins -- it should shrink, fade,
   and your coin count should go up by 10
3. Click the **Shop** button (top-left) -- panel should slide in
4. Buy **Speed Boost** (50 coins) -- coins deduct, you move faster for 10
   seconds, then revert to normal speed automatically
5. Try buying with fewer than 50 coins -- shop should show
   "Not enough coins" and deduct nothing
6. Check the top-right corner -- the **TOP 5** panel should show your name
   and coin count, refreshing every 5 seconds



## Notes

- All prices and speed values live on the server (`SHOP_ITEMS`,
  `BOOST_SPEED`, `MAX_ALLOWED_SPEED` in `GameScript.lua`). The client never
  sends a price -- only an item name string -- so purchases cannot be
  exploited by sending fake values.
- Coin DataStore key is `player.UserId`, not `player.Name`, so saved coins
  survive username changes.
- The speed boost uses a single expiry-timestamp + ongoing loop pattern
  rather than per-purchase timers, so buying the boost twice in a row
  correctly extends the duration instead of cutting it short.
