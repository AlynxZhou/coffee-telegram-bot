botUtils = require("./bot-utils")
BotPoller = require("./bot-poller")

class BotMaster
  constructor: (botApi, BotServant, identify, opts = {}) ->
    @botApi = botApi
    @BotServant = BotServant
    @identify = identify
    @destroyTimeout = opts["destroyTimeout"] or 5 * 60 * 1000
    @poller = new BotPoller(@botApi, @onUpdates, {
      "pollingInterval": opts["pollingInterval"],
      "skippingUpdates": opts["skippingUpdates"]
    })
    @bots = {}
    @botName = ""

  loop: (startCallback, stopCallback) =>
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
    if startCallback instanceof Function
      await startCallback()
    res = await @botApi.getMe()
    @botName = res["username"]
    @botID = res["id"]
    botUtils.log("#{@botName}##{@botID}: I am listening…")
    @poller.startPollUpdates()

  onUpdates: (updates) =>
    for update in updates then do (update) =>
      identifier = @identify(update)
      if not @bots[identifier]?
        @bots[identifier] = {
          "lastActiveTime": 0,
          "instance": new @BotServant(@botApi, identifier, @botName, @botID)
        }
        if @bots[identifier]["instance"].onCreate instanceof Function
          await @bots[identifier]["instance"].onCreate()
      @bots[identifier]["instance"].processUpdate(update)
      @bots[identifier]["lastActiveTime"] = Date.now()
    if @destroyTimeout?
      for identifier of @bots then do (identifier) =>
        if Date.now() - @bots[identifier]["lastActiveTime"] > @destroyTimeout
          if @bots[identifier]["instance"].onRemove instanceof Function
            await @bots[identifier]["instance"].onRemove()
          delete @bots[identifier]

module.exports = BotMaster
