botUtils = require("./bot-utils")

# A poller for polling updates, and send updates to a handle function.
class BotPoller
  constructor: (botApi, onUpdates, opts = {}) ->
    @botApi = botApi
    @onUpdates = onUpdates
    @pollingInterval = opts["pollingInterval"] or 700
    @skippingUpdates = opts["skippingUpdates"]
    @isPolling = false
    @pollingID = null
    @pollingParam = {
      "offset": 0,
      "timeout": 1
    }

  getUpdates: () =>
    try
      updates = await @botApi.getUpdates(@pollingParam)
    catch error
      botUtils.error(error)
      updates = []
    return updates

  skipUpdates: () =>
    @pollingParam["offset"] = -1
    updates = await @getUpdates()
    # Should be only one or zero update here.
    if updates.length > 0
      @pollingParam["offset"] = updates[0]["update_id"] + 1

  startPollUpdates: () =>
    if not @isPolling
      if @skippingUpdates isnt false
        await @skipUpdates()
      @isPolling = true
      @pollUpdates()
    return @isPolling

  pollUpdates: () =>
    updates = await @getUpdates()
    @onUpdates(updates)
    updateID = 0
    for update in updates
      if updateID < update["update_id"]
        updateID = update["update_id"]
    if updateID isnt 0
      @pollingParam["offset"] = updateID + 1
    @pollingID = setTimeout(@pollUpdates, @pollingInterval)

  stopPollUpdates: () =>
    if @isPolling
      @isPolling = false
      clearTimeout(@pollingID)
      @pollingID = null
    return @isPolling

module.exports = BotPoller
