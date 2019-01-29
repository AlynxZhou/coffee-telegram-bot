// Generated by CoffeeScript 2.2.4
(function() {
  var BotApi, BotPoller, EventBot, EventEmitter,
    boundMethodCheck = function(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new Error('Bound instance method accessed before binding'); } };

  EventEmitter = require("events");

  BotPoller = require("./bot-poller");

  BotApi = require("./bot-api");

  // An event based bot that auto classify updates.
  EventBot = class EventBot extends EventEmitter {
    constructor() {
      super();
      this.loop = this.loop.bind(this);
      this.onUpdates = this.onUpdates.bind(this);
      this.processUpdate = this.processUpdate.bind(this);
      this.botApi = new BotApi(token);
      this.poller = new BotPoller(this.botApi, this.onUpdates, pollingInterval);
    }

    async loop() {
      boundMethodCheck(this, EventBot);
      if (this.onStart instanceof Function) {
        await this.onStart();
      }
      this.poller.startPollUpdates();
      if (process.platform === "win32") {
        require("readline").createInterface({
          "input": process.stdin,
          "output": process.stdout
        }).on("SIGINT", function() {
          return process.emit("SIGINT");
        });
      }
      return process.on("SIGINT", async() => {
        this.poller.stopPollUpdates();
        if (this.onStop instanceof Function) {
          await this.onStop();
        }
        return process.exit();
      });
    }

    onUpdates(updates) {
      var i, len, results, update;
      boundMethodCheck(this, EventBot);
      results = [];
      for (i = 0, len = updates.length; i < len; i++) {
        update = updates[i];
        results.push(((update) => {
          return this.processUpdate(update);
        })(update));
      }
      return results;
    }

    processUpdate(update) {
      boundMethodCheck(this, EventBot);
      if (update["message"]) {
        if (update["message"]["text"] != null) {
          return this.emit("text", update);
        } else if (update["message"]["audio"] != null) {
          return this.emit("audio", update);
        } else if (update["message"]["document"] != null) {
          return this.emit("document", update);
        } else if (update["message"]["photo"] != null) {
          return this.emit("photo", update);
        } else if (update["message"]["video"] != null) {
          return this.emit("video", update);
        } else if (update["message"]["sticker"] != null) {
          return this.emit("sticker", update);
        } else if (update["message"]["contact"] != null) {
          return this.emit("contact", update);
        } else if (update["message"]["location"] != null) {
          return this.emit("location", update);
        } else {
          return this.emit("other", update);
        }
      }
    }

    onStart() {}

    onStop() {}

  };

  module.exports = EventBot;

}).call(this);
