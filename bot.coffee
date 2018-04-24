{BotManager, BotTemplate, BotApi, botUtils} = require("./index")
path = require("path")

tulingApiKey = process.argv[3]
adminUser = process.argv[4]

saveData = () ->
  return botUtils.writeFileAsync("data.json", \
  JSON.stringify(TeleBot.makeJSON(), null, "  ")).catch(botUtils.error)

loadData = () ->
  return botUtils.readFileAsync("data.json", "utf8").then((res) ->
    TeleBot.loadJSON(JSON.parse(res))
  ).catch((err) ->
    TeleBot.morningList = {}
    TeleBot.morningDate = new Date()
    TeleBot.eveningList = {}
    TeleBot.eveningDate = new Date()
    TeleBot.echoList = []
    TeleBot.echoText = null
    TeleBot.forwardList = []
  )

class TeleBot extends BotTemplate
  @morningList: {}
  @morningDate: new Date()
  @eveningList: {}
  @eveningDate: new Date()
  @echoList: []
  @echoText: null
  @forwardList: []

  @loadJSON: (json) =>
    for k, v of json["morningList"]
      @morningList[k] = { "name": v["name"], \
      "time": new Date(v["time"]) }
    @morningDate = new Date(json["morningDate"])
    for k, v of json["eveningList"]
      @eveningList[k] = { "name": v["name"], \
      "time": new Date(v["time"]) }
    @eveningDate = new Date(json["eveningDate"])
    @echoList = json["echoList"]
    @echoText = json["echoText"]
    @forwardList = json["forwardList"]

  @makeJSON: () =>
    morningList = {}
    for k, v of @morningList
      morningList[k] = { "name": v["name"], "time": v["time"].getTime() }
    morningDate = @morningDate.getTime()
    eveningList = {}
    for k, v of @eveningList
      eveningList[k] = { "name": v["name"], "time": v["time"].getTime() }
    eveningDate = @eveningDate.getTime()
    return {
      "morningList": morningList,
      "morningDate": morningDate,
      "eveningList": eveningList,
      "eveningDate": eveningDate,
      "echoList": @echoList,
      "echoText": @echoText,
      "forwardList": @forwardList
    }

  constructor: (botApi, identifier, botName, botID) ->
    super(botApi, identifier, botName, botID)
    @counter = 0
    @textRouter = []
    @addAllTextRouter()
    @handled = false

  onStart: (update) =>
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return @botApi.sendMessage(update["message"]["chat"]["id"], \
      "欢迎，使用 /help 获取帮助列表。", \
      { "reply_to_message_id": update["message"]["message_id"] })
    ).catch(botUtils.error)

  onHelp: (update) =>
    helpText = """
    使用 /morning 向 Bot 说早安。
    使用 /evening 向 Bot 说晚安。
    使用 /morninglist 获取起床列表。
    使用 /eveninglist 获取晚安列表。
    使用 /sleeptime 让 Bot 计算您的睡眠时间。
    再次使用 /morning 和 /evening 会使 Bot 更新您的早安和晚安时间记录。
    早安记录列表在午夜 00:00 更新，晚安记录列表在傍晚 18:00 更新。
    遇到 Bug 提交 Issue 或者 Pull Request 请使用 /code 获取 GitHub Repo 地址。
    """
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return @botApi.sendMessage(update["message"]["chat"]["id"], \
      helpText, \
      {"reply_to_message_id": update["message"]["message_id"]})
    ).catch(botUtils.error)

  onHello: (update) =>
    helloList = [
      "What's up?",
      "How do you do?",
      "Nice to meet you!",
      "A beautiful day always begins with a cup of JAVA.",
      "美好的一天，从一杯JAVA开始！",
      "天王盖地虎，地虎一米五；宝塔镇河妖，河妖长不高。"
    ]
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return @botApi.sendMessage(update["message"]["chat"]["id"], \
      "Hello, #{update["message"]["from"]["first_name"]}! \
      #{helloList[Math.floor(Math.random() * helloList.length)]}", \
      {"reply_to_message_id": update["message"]["message_id"]})
    ).catch(botUtils.error)

  onEcho: (update) =>
    if (not update["message"]["from"]["username"]?) or \
    update["message"]["from"]["username"] isnt adminUser
      return
    @constructor.echoText = update["message"]["text"].replace(
      new RegExp("^/?[eE]cho(@#{@botName})?"), ""
    )
    keyboard = []
    for chatInfo in @constructor.echoList
      keyboard.push([ "echo##{chatInfo}" ])
    keyboard.push([ "text": "echo#All" ])
    keyboard.push([ "text": "echo#Cancel" ])
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return @botApi.sendMessage(update["message"]["chat"]["id"], \
      "选择您想传达到哪个聊天", \
      {
        "reply_to_message_id": update["message"]["message_id"],
        "reply_markup": { "keyboard": keyboard }
      })
    )

  onEchoChoice: (update) =>
    if (not update["message"]["from"]["username"]?) or \
    update["message"]["from"]["username"] isnt adminUser
      return
    chatID = update["message"]["text"].split("#")[1]
    text = @constructor.echoText
    @constructor.echoText = null
    switch chatID
      when "All"
        for chatInfo in @constructor.echoList then do (chatID) =>
          chatID = chatInfo.split("#")[0]
          @botApi.sendChatAction(chatID, \
          "typing").then(() =>
            return @botApi.sendMessage(chatID, text)
          )
      else
        if chatID isnt "Cancel" and chatID?
          @botApi.sendChatAction(chatID, \
          "typing").then(() =>
            return @botApi.sendMessage(chatID, text)
          )
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return @botApi.sendMessage(update["message"]["chat"]["id"], \
      "OK.", {
        "reply_to_message_id": update["message"]["message_id"],
        "reply_markup": { "remove_keyboard": true }
      })
    )

  onDalao: (update) =>
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return @botApi.sendMessage(update["message"]["chat"]["id"], \
      "Dalao，膜！", \
      { "reply_to_message_id": update["message"]["message_id"] })
    )

  onMorningList: (update) =>
    d = new Date()
    if d.getTime() - d.getTimezoneOffset() * 60 * 1000 - \
    (@constructor.morningDate.getTime() - \
    @constructor.morningDate.getTimezoneOffset() * 60 * 1000 - \
    (@constructor.morningDate.getTime() - \
    @constructor.morningDate.getTimezoneOffset() * 60 * 1000) % \
    (24 * 60 * 60 * 1000)) > 24 * 60 * 60 * 1000
      @constructor.morningDate = d
      @constructor.morningList = {}
    personArray = Object.values(@constructor.morningList)
    if personArray.length isnt 0
      personArray.sort((o1, o2) ->
        return o1["time"].getTime() - o2["time"].getTime()
      )
    text = ""
    for i in [0...personArray.length]
      text += "#{i + 1}. #{personArray[i]["name"]} #{
        personArray[i]["time"].toTimeString().split(" ")[0]
      }\n"
    if text.length is 0
      text = "大家都在赖床。"
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return @botApi.sendMessage(update["message"]["chat"]["id"], \
      text, \
      {"reply_to_message_id": update["message"]["message_id"]})
    )

  onMorning: (update) =>
    d = new Date()
    if d.getTime() - d.getTimezoneOffset() * 60 * 1000 - \
    (@constructor.morningDate.getTime() - \
    @constructor.morningDate.getTimezoneOffset() * 60 * 1000 - \
    (@constructor.morningDate.getTime() - \
    @constructor.morningDate.getTimezoneOffset() * 60 * 1000) % \
    (24 * 60 * 60 * 1000)) > 24 * 60 * 60 * 1000
      @constructor.morningDate = d
      @constructor.morningList = {}
    @constructor.morningList[update["message"]["from"]["id"]] = {
      "name": update["message"]["from"]["first_name"],
      "time": d
    }
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return @botApi.sendMessage(update["message"]["chat"]["id"], \
      "你是今天第 #{Object.keys(@constructor.morningList).length} 个起床的少年。", \
      {"reply_to_message_id": update["message"]["message_id"]})
    )

  onEveningList: (update) =>
    d = new Date()
    # Refresh eveningList at 18:00 everyday.
    if d.getTime() - d.getTimezoneOffset() * 60 * 1000 - \
    (@constructor.eveningDate.getTime() - \
    @constructor.eveningDate.getTimezoneOffset() * 60 * 1000 - \
    (@constructor.eveningDate.getTime() - \
    @constructor.eveningDate.getTimezoneOffset() * 60 * 1000) % \
    (24 * 60 * 60 * 1000) + 18 * 60 * 60 * 1000) > 24 * 60 * 60 * 1000
      @constructor.eveningDate = d
      @constructor.eveningList = {}
    personArray = Object.values(@constructor.eveningList)
    if personArray.length isnt 0
      personArray.sort((o1, o2) ->
        return o1["time"].getTime() - o2["time"].getTime()
      )
    text = ""
    for i in [0...personArray.length]
      text += "#{i + 1}. #{personArray[i]["name"]} #{
        personArray[i]["time"].toTimeString().split(" ")[0]
      }\n"
    if text.length is 0
      text = "大家都在修仙。"
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return @botApi.sendMessage(update["message"]["chat"]["id"], \
      text, \
      {"reply_to_message_id": update["message"]["message_id"]})
    )

  onEvening: (update) =>
    d = new Date()
    # Refresh eveningList at 18:00 everyday.
    if d.getTime() - d.getTimezoneOffset() * 60 * 1000 - \
    (@constructor.eveningDate.getTime() - \
    @constructor.eveningDate.getTimezoneOffset() * 60 * 1000 - \
    (@constructor.eveningDate.getTime() - \
    @constructor.eveningDate.getTimezoneOffset() * 60 * 1000) % \
    (24 * 60 * 60 * 1000) + 18 * 60 * 60 * 1000) > 24 * 60 * 60 * 1000
      @constructor.eveningDate = d
      @constructor.eveningList = {}
    @constructor.eveningList[update["message"]["from"]["id"]] = {
      "name": update["message"]["from"]["first_name"],
      "time": d
    }
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return @botApi.sendMessage(update["message"]["chat"]["id"], \
      "你是今天第 #{Object.keys(@constructor.eveningList).length} 个睡觉的少年。", \
      {"reply_to_message_id": update["message"]["message_id"]})
    )

  onSleepTime: (update) =>
    d = new Date()
    if d.getTime() - d.getTimezoneOffset() * 60 * 1000 - \
    (@constructor.morningDate.getTime() - \
    @constructor.morningDate.getTimezoneOffset() * 60 * 1000 - \
    (@constructor.morningDate.getTime() - \
    @constructor.morningDate.getTimezoneOffset() * 60 * 1000) % \
    (24 * 60 * 60 * 1000)) > 24 * 60 * 60 * 1000
      @constructor.morningDate = d
      @constructor.morningList = {}
    # Refresh eveningList at 18:00 everyday.
    if d.getTime() - d.getTimezoneOffset() * 60 * 1000 - \
    (@constructor.eveningDate.getTime() - \
    @constructor.eveningDate.getTimezoneOffset() * 60 * 1000 - \
    (@constructor.eveningDate.getTime() - \
    @constructor.eveningDate.getTimezoneOffset() * 60 * 1000) % \
    (24 * 60 * 60 * 1000) + 18 * 60 * 60 * 1000) > 24 * 60 * 60 * 1000
      @constructor.eveningDate = d
      @constructor.eveningList = {}
    text = ""
    if @constructor.morningList.length is 0 or \
    @constructor.eveningList.length is 0
      text = "不好意思，这个 bot 是新来的，还没有足够的数据，请投喂。"
    else if not @constructor.eveningList[update["message"]["from"]["id"]]?
      text = "Pia!!!骗谁呢你，你是要修仙吧！"
    else if not @constructor.morningList[update["message"]["from"]["id"]]?
      text = "Pia!!!骗谁呢你，你还没起床呢！"
    else
      sleepMs = \
      @constructor.morningList[update["message"]["from"]["id"]]["time"] - \
      @constructor.eveningList[update["message"]["from"]["id"]]["time"]
      if sleepMs < 0
        text = "Pia!!!骗谁呢你，你昨晚睡觉比今早起床还晚？？？"
        delete @constructor.morningList[update["message"]["from"]["id"]]
        delete @constructor.eveningList[update["message"]["from"]["id"]]
      else
        sleepHours = sleepMs / (60 * 60 * 1000)
        sleepMins = sleepMs % (60 * 60 * 1000) / (60 * 1000)
        text = "你昨晚睡了 #{Math.floor(sleepHours)} 小时 #{Math.floor(sleepMins)} 分钟。"
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return @botApi.sendMessage(update["message"]["chat"]["id"], \
      text, \
      {"reply_to_message_id": update["message"]["message_id"]})
    )

  onChat: (update) =>
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return botUtils.getTuling(tulingApiKey, \
      update["message"]["text"].replace(
        new RegExp("^/?[cC]hat(@#{@botName})?"), ""
      ), \
      update["message"]["from"]["id"])
    ).then((res) =>
      for r in res then do (r) =>
        @botApi.sendMessage(update["message"]["chat"]["id"], \
        r["values"]["text"], \
        {"reply_to_message_id": update["message"]["message_id"]})
    ).catch(botUtils.error)

  onPhoto: (update) =>
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "upload_photo").then(() ->
      return botUtils.readFileAsObj("./AlynxLogo.png")
    ).then((fileObj) =>
      return @botApi.sendPhoto(update["message"]["chat"]["id"], \
      fileObj, \
      {"reply_to_message_id": update["message"]["message_id"]})
    )

  onDocument: (update) =>
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "upload_document").then(() ->
      return botUtils.readFileAsObj("./AlynxLogo.png")
    ).then((fileObj) =>
      return @botApi.sendDocument(update["message"]["chat"]["id"], \
      fileObj, \
      {"reply_to_message_id": update["message"]["message_id"]})
    )

  onTime: (update) =>
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return @botApi.sendMessage(update["message"]["chat"]["id"], \
      Date(), \
      {"reply_to_message_id": update["message"]["message_id"]})
    ).catch(botUtils.error)

  onCode: (update) =>
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return @botApi.sendMessage(update["message"]["chat"]["id"], \
      "https://github.com/AlynxZhou/coffee-telegram-bot/", \
      {"reply_to_message_id": update["message"]["message_id"]})
    )

  onAddForward: (update) =>
    if (not update["message"]["from"]["username"]?) or \
    update["message"]["from"]["username"] isnt adminUser
      return
    if update["message"]["chat"]["type"] is "private"
      return
    if update["message"]["chat"]["id"] not in @constructor.forwardList
      @constructor.forwardList.push(update["message"]["chat"]["id"])
      @botApi.sendChatAction(update["message"]["chat"]["id"], \
      "typing").then(() =>
        return @botApi.sendMessage(update["message"]["chat"]["id"], \
        "已添加 #{update["message"]["chat"]["id"]}#\
        #{update["message"]["chat"]["title"]} 到转发列表。", \
        {"reply_to_message_id": update["message"]["message_id"]})
      ).catch(botUtils.error)

  onRemoveForward: (update) =>
    if (not update["message"]["from"]["username"]?) or \
    update["message"]["from"]["username"] isnt adminUser
      return
    if update["message"]["chat"]["type"] is "private"
      return
    @constructor.forwardList = (chatID for chatID in @constructor.forwardList \
    when chatID isnt update["message"]["chat"]["id"])
    @botApi.sendChatAction(update["message"]["chat"]["id"], \
    "typing").then(() =>
      return @botApi.sendMessage(update["message"]["chat"]["id"], \
      "已从转发列表中移除 #{update["message"]["chat"]["id"]}#\
      #{update["message"]["chat"]["title"]}。", \
      {"reply_to_message_id": update["message"]["message_id"]})
    ).catch(botUtils.error)

  onText: (regex, callback) =>
    @textRouter.push({ "regex": regex, "callback": callback })

  forwardUpdate: (update) =>
    for chatID in @constructor.forwardList then do (chatID) =>
      if chatID isnt update["message"]["chat"]["id"]
        @botApi.sendChatAction(chatID, \
        "typing").then(() =>
          return @botApi.forwardMessage(chatID, \
          update["message"]["chat"]["id"], \
          update["message"]["message_id"], \
          { "disable_notification": true })
        )

  addAllTextRouter: () =>
    @onText(new RegExp("^/?[sS]tart(@#{@botName})?"), @onStart)
    @onText(new RegExp("^/?[hH]elp(@#{@botName})?"), @onHelp)
    @onText(new RegExp("^/?[hH]ello(@#{@botName})?"), @onHello)
    @onText(new RegExp("^echo#.+"), @onEchoChoice)
    @onText(new RegExp("^/?[eE]cho(@#{@botName})?"), @onEcho)
    @onText(new RegExp("^/?[dD]alao(@#{@botName})?"), @onDalao)
    @onText(new RegExp("^/?[mM]orning[lL]ist(@#{@botName})?"), @onMorningList)
    @onText(new RegExp("^/?[mM]orning(@#{@botName})?"), @onMorning)
    @onText(new RegExp("^/?[eE]vening[lL]ist(@#{@botName})?"), @onEveningList)
    @onText(new RegExp("^/?[eE]vening(@#{@botName})?"), @onEvening)
    @onText(new RegExp("^/?[sS]leep[tT]ime(@#{@botName})?"), @onSleepTime)
    @onText(new RegExp("^/?[cC]hat(@#{@botName})?"), @onChat)
    @onText(new RegExp("^/?[pP]hoto(@#{@botName})?"), @onPhoto)
    @onText(new RegExp("^/?[dD]ocument(@#{@botName})?"), @onDocument)
    @onText(new RegExp("^/?[tT]ime(@#{@botName})?"), @onTime)
    @onText(new RegExp("^/?[cC]ode(@#{@botName})?"), @onCode)
    @onText(new RegExp("^/?[aA]dd[fF]orward(@#{@botName})?"), @onAddForward)
    @onText(new RegExp("^/?[rR]emove[fF]orward(@#{@botName})?"), \
    @onRemoveForward)

  onReceiveText: (update, counter) =>
    botUtils.log("#{@botName}##{@identifier}: Got No.#{counter} \
    text \"#{update["message"]["text"]}\".")
    for r in @textRouter
      if update["message"]["text"].match(r["regex"])?
        r["callback"](update)
        @handled = true
        break

  updateEchoList: (update) =>
    switch update["message"]["chat"]["type"]
      when "private"
        if "#{update["message"]["chat"]["id"]}##{update["message"]["chat"]\
        ["first_name"]}" not in @constructor.echoList
          @constructor.echoList.push("#{update["message"]["chat"]["id"]}#\
          #{update["message"]["chat"]["first_name"]}")
      else
        if "#{update["message"]["chat"]["id"]}#\
        #{update["message"]["chat"]["title"]}" not in @constructor.echoList
          @constructor.echoList.push("#{update["message"]["chat"]["id"]}#\
          #{update["message"]["chat"]["title"]}")
    while @constructor.echoList.length > 7
      @constructor.echoList.shift()

  processUpdate: (update) =>
    if update["message"]
      @handled = false
      ++@counter
      @updateEchoList(update)
      if update["message"]["text"]?
        @onReceiveText(update, @counter)
      if (not @handled) and \
      update["message"]["chat"]["id"] in @constructor.forwardList and \
      update["message"]["from"]["id"] isnt @botID
        @forwardUpdate(update)


botManager = new BotManager(new BotApi(process.argv[2]), \
TeleBot, botUtils.perFromID)
botManager.loop(loadData, saveData)
