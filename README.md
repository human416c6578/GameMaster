# GameMaster Plugin for Deathrun

## Overview

The **GameMaster** plugin is designed for the Deathrun gamemode in Counter-Strike 1.6. It introduces custom abilities that terrorists can use to trap counter-terrorists. Players earn credits by winning rounds and killing opponents, which they can spend to activate various in-game abilities.

## Features

- Custom abilities for terrorists.
- Ability to activate rules with different costs and usage limits.
- VIP players gain double credits.
- Winning the round as a terrorist refunds half of the spent credits.

## Commands

- `/gm` - Opens the GameMaster menu for terrorists.

## Usage

1. Terrorists can use the `/gm` command to open the GameMaster menu.
2. Players earn credits for winning rounds and killing opponents.
3. In the menu, players can see available rules with their respective costs.
4. Players can activate a rule by selecting it from the menu if they have enough credits.
5. Rules may have per-round limits to prevent excessive usage.

## VIP Bonus

VIP players earn double credits for their actions.

## Winning Bonus

- If a terrorist wins the round, they receive half of the credits spent back.

## Rules Registration

To add new rules, you can use the `register_rule_native` function. Example:

```c
register_rule("Rule Name", "EnableFunction", "DisableFunction", "PluginName", Cost, PerRoundLimit, ReturnOnActivation);
```

## Acknowledgments

Special thanks to the [AMX Mod X](https://www.amxmodx.org/) community for their support and resources.

Feel free to contribute to the development of this plugin! Happy gaming!