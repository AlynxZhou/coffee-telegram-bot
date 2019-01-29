BotPoller = require("./bot-poller")
BotApi = require("./bot-api")

# A very simple bot, you can just instantiate it
# and set onStart, onStop and onUpdates for it.
class SimpleBot
  constructor: (token) ->
    @botApi = new BotApi(token)
    @poller = new BotPoller(@botApi, @onUpdates, pollingInterval)

  loop: () =>
    if @onStart instanceof Function
      await @onStart()
    @poller.startPollUpdates()
    if process.platform is "win32"
      require("readline").createInterface({
        "input": process.stdin,
        "output": process.stdout
      }).on("SIGINT", () ->
        process.emit("SIGINT")
      )
    process.on("SIGINT", () =>
      @poller.stopPollUpdates()
      if @onStop instanceof Function
        await @onStop()
      process.exit()
    )

  onStart: () ->

  onStop: () ->

  onUpdates: (updates) ->

module.exports = SimpleBot
