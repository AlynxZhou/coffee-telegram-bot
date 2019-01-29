EventEmitter = require("event")
BotPoller = require("./bot-poller")
BotApi = require("./bot-api")

# An event based bot that auto classify updates.
class EventBot extends EventEmitter
  constructor: () ->
    super()
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

  onUpdates: (updates) =>
    for update in updates then do (update) =>
      @processUpdate(update)

  processUpdate: (update) =>
    if update["message"]
      if update["message"]["text"]?
        this.emit("text", update)
      else if update["message"]["audio"]?
        this.emit("audio", update)
      else if update["message"]["document"]?
        this.emit("document", update)
      else if update["message"]["photo"]?
        this.emit("photo", update)
      else if update["message"]["video"]?
        this.emit("video", update)
      else if update["message"]["sticker"]?
        this.emit("sticker", update)
      else if update["message"]["contact"]?
        this.emit("contact", update)
      else if update["message"]["location"]?
        this.emit("location", update)
      else
        this.emit("other", update)

  onStart: () ->

  onStop: () ->

module.exports = EventBot
