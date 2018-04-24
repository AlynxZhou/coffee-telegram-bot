botUtils = require("./bot-utils")

module.exports =
class BotManager
  constructor: (botApi, BotTemplate, identify, \
  destroyTimeout = 5 * 60 * 1000, pollingInterval = 500) ->
    @botApi = botApi
    @BotTemplate = BotTemplate
    @identify = identify
    @destroyTimeout = destroyTimeout
    @isPolling = false
    @pollingID = null
    @pollingParam = {
      "offset": 0
    }
    @lastUpdateTime = null
    @pollingInterval = pollingInterval
    @bots = {}
    @botName = ""

  loop: (startCallback = null, stopCallback = null) =>
    if startCallback instanceof Function
      await startCallback()
    @botApi.getMe().then((res) =>
      @botName = res["username"]
      @botID = res["id"]
      botUtils.log("#{@botName}##{@botID}: I am listening ...")
      @startPollUpdates()
    )
    if process.platform is "win32"
      require("readline").createInterface({
        input: process.stdin,
        output: process.stdout
      }).on("SIGINT", () ->
        process.emit("SIGINT")
      )
    process.on("SIGINT", () =>
      @stopPollUpdates()
      if stopCallback instanceof Function
        await stopCallback()
      process.exit()
    )

  startPollUpdates: () =>
    if not @isPolling
      @isPolling = true
      @pollingUpdates()

  pollingUpdates: () =>
    updateID = 0
    return @botApi.getUpdates(@pollingParam).then((updates) =>
      @lastUpdate = Date.now()
      # botUtils.debug(JSON.stringify(updates, null, "  "))
      for update in updates then do (update) =>
        # Only update offset when update is newer, prevent when older update
        # object was processed too slow in this async closure.
        # Update the id first or it will loop when process failed.
        if updateID < update["update_id"]
          updateID = update["update_id"]
        identifier = @identify(update)
        if not @bots[identifier]?
          @bots[identifier] = new @BotTemplate(@botApi, identifier, \
          @botName, @botID)
        @bots[identifier].processUpdate(update)
        @bots[identifier].lastActiveTime = Date.now()
      # botUtils.debug(@bots)
    ).then(() =>
      for identifier of @bots then do (identifier) =>
        if Date.now() - @bots[identifier].lastActiveTime > @destroyTimeout
          delete @bots[identifier]
    ).catch(botUtils.error).then(() =>
      # Always update offset after all update objects processed, or catched
      # an exception.
      @pollingParam["offset"] = updateID + 1
      @pollingID = setTimeout(@pollingUpdates, @pollingInterval)
    )

  stopPollUpdates: () =>
    if @isPolling
      @isPolling = false
      clearTimeout(@pollingID)
      @pollingID = null
      for identifier of @bots then do (identifier) =>
        delete @bots[identifier]
    return @isPolling
