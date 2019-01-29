botUtils = require("./bot-utils")

# A poller for polling updates, and send updates to a handle function.
class BotPoller
  constructor: (botApi, onUpdates, pollingInterval = 500) ->
    @botApi = botApi
    @isPolling = false
    @pollingID = null
    @pollingParam = {"offset": 0}
    @lastUpdateTime = null
    @pollingInterval = pollingInterval
    @onUpdates = onUpdates

  startPollUpdates: () =>
    if not @isPolling
      @isPolling = true
      @pollingUpdates()
    return @isPolling

  pollingUpdates: () =>
    updateID = 0
    return @botApi.getUpdates(@pollingParam).then((updates) =>
      @lastUpdate = Date.now()
      # botUtils.debug(JSON.stringify(updates, null, "  "))
      for update in updates then do (update) ->
        # Only update offset when update is newer, prevent when older update
        # object was processed too slow in this async closure.
        # Update the id first or it will loop when process failed.
        if updateID < update["update_id"]
          updateID = update["update_id"]
      @onUpdates(updates)
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
    return @isPolling

module.exports = BotPoller
