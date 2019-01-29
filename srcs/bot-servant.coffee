class BotServant
  constructor: (botApi, identifier, botName, botID) ->
    @botApi = botApi
    @identifier = identifier
    @botName = botName
    @botID = botID

  processUpdate: (update) ->

module.exports = BotServant
