coffee-telegram-bot
===================

A Telegram Bot framework, written in CoffeeScript.
--------------------------------------------------

**Deprecated, use [aztgbot](https://github.com/AlynxZhou/aztgbot/) instead.**

# Feature

- Only one dev dependency (CoffeeScript), all native Node.js method.

- Promise based async framework.

- Class based bot that can work in one object per user mode.

# Usage

1. Install it with `npm`:

	```
	$ npm i -s coffee-telegram-bot
	```

2. Create your own bot by `require("coffee-telegram-bot")` with CoffeeScript:

	- A simple example that print all messages:

		This bot use one class and only create one object, which will never be deleted.

		```CoffeeScript
		# Import modules with Destructuring Assignment.
		# botUtils is an object while others are class.
		{BotMaster, BotServant, BotApi, botUtils} = require("coffee-telegram-bot")

		# Get token from cli. Command like `$ coffee YOURBOT.coffee TOKEN`.
		# process.argv likes ["coffee", "YOURBOT.coffee", "TOKEN"].
		token = process.argv[2]

		# Your bot should extend BotServant, and implements processUpdate method.
		class MyBot extends BotServant
		  # BotMaster will give each objects a botApi, which is used to send API request (yes different bots share one botApi), an identifier for each object, and bot's Name for logging, also your bot's ID.
		  constructor: (botApi, identifier, botName, botID) ->
		    # You extend, so you need to call `super`.
		    # This super call will make arguments into props of `this`.
		    super(botApi, identifier, botName, botID)
		    # A message counter.
		    @counter = 0

		  # BotMaster will call `processUpdate`.
		  # For the update object read `https://core.telegram.org/bots/api#Update`.
		  processUpdate: (update) =>
		    if update["message"]
	              ++@counter
	              if update["message"]["text"]?
		        botUtils.log("#{@botName}##{@identifier}: Got No.#{counter} text \"#{update["message"]["text"]}\".")
			# Every API is a promise.
			@botApi.sendChatAction(update["message"]["chat"]["id"], "typing").then(() =>
		          return @botApi.sendMessage(update["message"]["chat"]["id"], "Received.",  {"reply_to_message_id": update["message"]["message_id"]})
			).catch(botUtils.error)

		# Create a `BotMaster` to start the program, it takes following arguments:
		# A `BotApi` object shares to each bot.
		# A `BotServant` (we call it `MyBot` in this example).
		# An `identify` function to give each bot an identifier from update object (we only create one bot object so use a function returns "0").
		# `null` means no bot destroy timeout. We keep this bot's lifecycle.
		# Use `BotMaster::loop` to run it, `loop` takes two functions as arguments, the former will be run before loop starts, the later will be run after loop stops.
		new BotMaster(new BotApi(token), MyBot, () -> return "0", null).loop(null, null)
		```

	- A bot that use different object to serve different users:

		```CoffeeScript
		# Import modules with Destructuring Assignment.
		# botUtils is an object while others are class.
		{BotMaster, BotServant, BotApi, botUtils} = require("coffee-telegram-bot")

		# Get token from cli. Command like `$ coffee YOURBOT.coffee TOKEN`.
		# process.argv likes ["coffee", "YOURBOT.coffee", "TOKEN"].
		token = process.argv[2]

		# Your bot should extend BotServant, and implements processUpdate method.
		class MyBot extends BotServant
		  # BotMaster will give each objects a botApi, which is used to send API request (yes different bots share one botApi), an identifier for each object, and bot's Name for logging, also your bot's ID.
		  constructor: (botApi, identifier, botName, botID) ->
		    # You extend, so you need to call `super`.
		    # This super call will make arguments into props of `this`.
		    super(botApi, identifier, botName, botID)
		    # A message counter.
		    @counter = 0

		  # BotMaster will call `processUpdate`.
		  # For the update object read `https://core.telegram.org/bots/api#Update`.
		  processUpdate: (update) =>
		    if update["message"]
	              ++@counter
	              if update["message"]["text"]?
		        botUtils.log("#{@botName}##{@identifier}: Got No.#{counter} text \"#{update["message"]["text"]}\".")
			# Every API is a promise.
			@botApi.sendChatAction(update["message"]["chat"]["id"], "typing").then(() =>
		          return @botApi.sendMessage(update["message"]["chat"]["id"], "Received.",  {"reply_to_message_id": update["message"]["message_id"]})
			).catch(botUtils.error)

		# Create a `BotMaster` to start the program, it takes following arguments:
		# A `BotApi` object shares to each bot.
		# A `BotServant` (we call it `MyBot` in this example).
		# An `identify` function to give each bot an identifier from update object (`botUtils.perFromID` returns the `userID` in update object, we use this).
		# Leave destroy timeout default.
		# Use `BotMaster::loop` to run it, `loop` takes two functions as arguments, the former will be run before loop starts, the later will be run after loop stops.
		new BotMaster(new BotApi(token), MyBot, botUtils.perFromID).loop(null, null)
		```

# License

Apache-2.0
