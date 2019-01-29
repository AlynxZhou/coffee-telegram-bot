BotMaster = require("./bot-master")
BotServant = require("./bot-servant")
SimpleBot = require("./simple-bot")
EventBot = require("./event-bot")
BotApi = require("./bot-api")
botUtils = require("./bot-utils")

module.exports =
botIndex = {
  "BotMaster": BotMaster,
  "BotServant": BotServant,
  "SimpleBot": SimpleBot,
  "EventBot": EventBot,
  "BotManager": BotMaster,
  "BotTemplate": BotServant,
  "BotApi": BotApi,
  "botUtils": botUtils
}
