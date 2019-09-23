botUtils = require("./bot-utils")
BotPoller = require("./bot-poller")

class BotMaster
  constructor: (botApi, BotServant, identify, skipUpdates = true, \
  destroyTimeout = 5 * 60 * 1000, pollingInterval = 500) ->
    @botApi = botApi
    @poller = new BotPoller(botApi, @onUpdates, skipUpdates, pollingInterval)
    @BotServant = BotServant
    @identify = identify
    @destroyTimeout = destroyTimeout
    @bots = {}
    @botName = ""

  loop: (startCallback = null, stopCallback = null) =>
    if startCallback instanceof Function
      await startCallback()
    @botApi.getMe().then((res) =>
      @botName = res["username"]
      @botID = res["id"]
      botUtils.log("#{@botName}##{@botID}: I am listening ...")
      @poller.startPollUpdates()
    )
    if process.platform is "win32"
      require("readline").createInterface({
        "input": process.stdin,
        "output": process.stdout
      }).on("SIGINT", () ->
        process.emit("SIGINT")
      )
    process.on("SIGINT", () =>
      @poller.stopPollUpdates()
      for identifier of @bots then do (identifier) =>
        if @bots[identifier].onRemove instanceof Function
          await @bots[identifier].onRemove()
        delete @bots[identifier]
      if stopCallback instanceof Function
        await stopCallback()
      process.exit()
    )

  onUpdates: (updates) =>
    for update in updates then do (update) =>
      identifier = @identify(update)
      if not @bots[identifier]?
        @bots[identifier] = new @BotServant(@botApi, identifier, \
        @botName, @botID)
        if @bots[identifier].onCreate instanceof Function
          await @bots[identifier].onCreate()
      @bots[identifier].processUpdate(update)
      @bots[identifier].lastActiveTime = Date.now()
    if @destroyTimeout?
      for identifier of @bots then do (identifier) =>
        if Date.now() - @bots[identifier].lastActiveTime > @destroyTimeout
          if @bots[identifier].onRemove instanceof Function
            await @bots[identifier].onRemove()
          delete @bots[identifier]

module.exports = BotMaster
