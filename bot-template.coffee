module.exports =
class BotTemplate
  constructor: (botApi, identifier, botName, botID) ->
    @botApi = botApi
    @identifier = identifier
    @botName = botName
    @botID = botID

  processUpdate: (update) ->
