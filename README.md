# Nutra Paste V1.0

Free but poor quality food source.

The concept is from the game [Rimworld](https://rimworldgame.com/)

## How it works

Once you get wood you can make a Nutra Paste Machine, this block once placed will produce Nutra Paste. Nutra Paste is a meal which provides
 half a hunger point or half a hit point of food, thus making it not prefered, but can be used to keep you alive.

## What to change something?

Most of the settings you'll want to change are contained within settings.lua so just edit the file and restart your client/server.

### What's in settings.lua

* `amount_per_production`, How many Nutra Paste meals do all machines make per production?

* `time_per_production`, How frequent do Nutra Paste Machines produce meals?

* `log_production`, In case you wanted/need to get some extra debug on what is happening. (This should be false on servers and more stable/long running environments)

* `craft`, Can any player craft a Nutra Paste Machine to make meals with?

## How to make it

```
W = Wood Planks (Uses groups so any wood planks will work)
S = Sapling (Uses groups so any sapling will work)

_  W _
W S W
_  W _
```
