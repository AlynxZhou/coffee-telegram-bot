path = require("path")
https = require("https")
# querystring = require("querystring")
botUtils = require("./bot-utils")

###
Official Document: https://core.telegram.org/bots/api/
TODO: Inline mode (I need to learn what is inline mode first).
###
module.exports =
class BotApi
  constructor: (token) ->
    @token = token

  request: (botMethod, postParam, fileData) =>
    chunks = []
    size = 0
    httpOptions = {
      "protocol": "https:",
      "host": "api.telegram.org",
      "port": 443,
      "method": "POST",
      "path": "/bot#{@token}/#{botMethod}",
      "timeout": 1500
    }
    if not fileData?
      postData = JSON.stringify(postParam)
      if not postData?
        postData = ""
      httpOptions["headers"] = {
        "Content-Type": "application/json",
        "Content-Length": "#{Buffer.byteLength(postData)}"
      }
    else
      boundary = Math.random().toString(16)
      fileBegin = "\r\n--#{boundary}\r\n"
      for k of postParam
        fileBegin += "Content-Disposition: form-data; name=\"#{k}\"\r\n\r\n\
        #{postParam[k]}\r\n--#{boundary}\r\n"
      fileBegin += "Content-Disposition: form-data; \
      name=\"#{fileData["name"]}\"; \
      filename=\"#{path.basename(path.normalize(fileData["filePath"]))}\"\
      \r\n\r\n"
      fileEnd = "\r\n--#{boundary}--"
      httpOptions["headers"] = {
        "Content-Type": "multipart/form-data; boundary=#{boundary}",
        "Transfer-Encoding": "chunked",
        "Content-Length": Buffer.byteLength(fileBegin) + \
        Buffer.byteLength(fileData["fileBuf"]) + Buffer.byteLength(fileEnd)
      }
    return new Promise((resolve, reject) ->
      req = https.request(httpOptions, (res) ->
        # If there is wide character between chunks, it cannot be
        # encoded easily due to spliting. Instead we need to concat
        # them then encoding.
        # res.setEncoding("utf8")
        res.on("data", (chunk) ->
          chunks.push(chunk)
        )
        res.on("end", () ->
          resolve(Buffer.concat(chunks).toString("utf8"))
          chunks = []
        )
      )
      req.on("error", reject)
      if not fileData?
        req.write(postData)
      else
        req.write(fileBegin)
        req.write(fileData["fileBuf"])
        req.write(fileEnd)
      req.end()
    ).then((resStr) ->
      resJSON = JSON.parse(resStr)
      if resJSON["ok"]
        return resJSON["result"]
      else
        throw new Error("TelegramError: #{resJSON["error_code"]}: \
        #{resJSON["description"]}")
    )

  getMe: () =>
    return @request("getMe")

  sendChatAction: (chatID, action) =>
    return @request("sendChatAction", {"chat_id": chatID, "action": action})

  sendMessage: (chatID, text, postParam = {}) =>
    postParam["chat_id"] = chatID
    postParam["text"] = text
    return @request("sendMessage", postParam)

  forwardMessage: (chatID, fromChatID, messageID, postParam = {}) =>
    postParam["chat_id"] = chatID
    postParam["from_chat_id"] = fromChatID
    postParam["message_id"] = messageID
    return @request("forwardMessage", postParam)

  sendPhoto: (chatID, photo, postParam = {}) =>
    postParam["chat_id"] = chatID
    if photo instanceof String
      postParam["photo"] = photo
      photo = null
    else if photo instanceof Object and photo["filePath"]? and photo["fileBuf"]?
      # For the file part name
      photo["name"] = "photo"
    else
      throw new Error("Invalid photo.")
    return @request("sendPhoto", postParam, photo)

  sendAudio: (chatID, audio, postParam = {}) =>
    postParam["chat_id"] = chatID
    if audio instanceof String
      postParam["audio"] = audio
      audio = null
    else if audio instanceof Object and \
    audio["filePath"]? and audio["fileBuf"]?
      # For the file part name
      audio["name"] = "audio"
    else
      throw new Error("Invalid audio.")
    return @request("sendAudio", postParam, audio)

  sendDocument: (chatID, document, postParam = {}) =>
    postParam["chat_id"] = chatID
    if document instanceof String
      postParam["document"] = document
      document = null
    else if document instanceof Object and \
    document["filePath"]? and document["fileBuf"]?
      document["name"] = "document"
    else
      throw new Error("Invalid document.")
    return @request("sendDocument", postParam, document)

  sendVideo: (chatID, video, postParam = {}) =>
    postParam["chat_id"] = chatID
    if video instanceof String
      postParam["video"] = video
      video = null
    else if video instanceof Object and \
    video["filePath"]? and video["fileBuf"]?
      video["name"] = "video"
    else
      throw new Error("Invalid video.")
    return @request("sendVideo", postParam, video)

  sendVideoNote: (chatID, videoNote, postParam = {}) =>
    postParam["chat_id"] = chatID
    if videoNote instanceof String
      postParam["video_note"] = videoNote
      videoNote = null
    else if videoNote instanceof Object and \
    videoNote["filePath"]? and videoNote["fileBuf"]?
      videoNote["name"] = "video_note"
    else
      throw new Error("Invalid videoNote.")
    return @request("sendVideo", postParam, videoNote)

  sendLocation: (chatID, latitude, longitude, postParam = {}) =>
    postParam["chat_id"] = chatID
    postParam["latitude"] = latitude
    postParam["longitude"] = longitude
    return @request("sendLocation", postParam)

  sendContact: (chatID, phoneNumber, firstName, postParam = {}) =>
    postParam["chat_id"] = chatID
    postParam["phone_number"] = phoneNumber
    postParam["first_name"] = firstName
    return @request("sendLocation", postParam)

  getUserProfilePhotos: (userID, postParam = {}) =>
    postParam["user_id"] = userID
    return @request("getUserProfilePhotos", postParam)

  getFile: (fileID) =>
    return @request("getFile", {"file_id": fileID})

  kickChatMember: (chatID, userID, postParam = {}) =>
    postParam["chat_id"] = chatID
    postParam["user_id"] = userID
    return @request("kickChatMember", postParam)

  unbanChatMember: (chatID, userID) =>
    return @request("unbanChatMember", {"chat_id": chatID, "user_id": userID})

  restrictChatMember: (chatID, userID, postParam = {}) =>
    postParam["chat_id"] = chatID
    postParam["user_id"] = userID
    return @request("restrictChatMember", postParam)

  promoteChatMember: (chatID, userID, postParam = {}) =>
    postParam["chat_id"] = chatID
    postParam["user_id"] = userID
    return @request("promoteChatMember", postParam)

  exportChatInviteLink: (chatID) =>
    return @request("exportChatInviteLink", {"chat_id": chatID})

  setChatPhoto: (chatID, photo) =>
    @request("setChatPhoto", {"chat_id": chatID}, photo)

  deleteChatPhoto: (chatID) =>
    @request("deleteChatPhoto", {"chat_id": chatID})

  setChatTitle: (chatID, title) =>
    @request("setChatTitle", {"chat_id": chatID, "title": title})

  setChatDescription: (chatID, postParam = {}) =>
    postParam["chat_id"] = chatID
    return @request("setChatDescription", postParam)

  pinChatMessage: (chatID, messageID, postParam = {}) =>
    postParam["chat_id"] = chatID
    postParam["message_id"] = messageID
    return @request("pinChatMessage", postParam)

  unpinChatMessage: (chatID) =>
    return @request("unpinChatMessage", {"chat_id": chatID})

  leaveChat: (chatID) =>
    return @request("leaveChat", {"chat_id": chatID})

  getChat: (chatID) =>
    return @request("getChat", {"chat_id": chatID})

  getChatAdministrators: (chatID) =>
    return @request("getChatAdministrators", {"chat_id": chatID})

  getChatMembersCount: (chatID) =>
    return @request("getChatMembersCount", {"chat_id": chatID})

  getChatMember: (chatID, userID) =>
    return @request("getChatMember", {"chat_id": chatID, "user_id": userID})

  setChatStickerSet: (chatID, stickerSetName) =>
    return @request("setChatStickerSet", \
    {"chat_id": chatID, "sticker_set_name": stickerSetName})

  deleteChatStickerSet: (chatID) =>
    return @request("deleteChatStickerSet", {"chat_id": chatID})

  editMessageText: (text, postParam = {}) =>
    postParam["text"] = text
    @return @request("editMessageText", postParam)

  editMessageCaption: (postParam = {}) =>
    return @request("editMessageCaption", postParam)

  editMessageReplyMarkup: (postParam = {}) =>
    return @request("editMessageReplyMarkup", postParam)

  deleteMessage: (chatID, messageID) =>
    return @request("deleteMessage", \
    {"chat_id": chatID, "message_id": messageID})

  sendSticker: (chatID, sticker, postParam = {}) =>
    postParam["chat_id"] = chatID
    if sticker instanceof String
      postParam["sticker"] = sticker
      sticker = null
    else if sticker instanceof Object and \
    sticker["filePath"]? and sticker["fileBuf"]?
      sticker["name"] = "sticker"
    else
      throw new Error("Invalid sticker.")
    return @request("sendSticker", postParam, sticker)

  getStickerSet: (name) =>
    return @request("getStickerSet", {"name": name})

  uploadStickerFile: (userID, pngSticker) =>
    if pngSticker instanceof Object and \
    pngSticker["filePath"]? and pngSticker["fileBuf"]?
      pngSticker["name"] = "png_sticker"
    else
      throw new Error("Invalid sticker.")
    return @request("uploadStickerFile", \
    {"user_id": userID}, pngSticker)

  createNewStickerSet: (userID, name, title, \
  pngSticker, emojis, postParam = {}) =>
    if pngSticker instanceof String
      postParam["png_sticker"] = pngSticker
      pngSticker = null
    else if pngSticker instanceof Object and \
    pngSticker["filePath"]? and pngSticker["fileBuf"]?
      pngSticker["name"] = "png_sticker"
    else
      throw new Error("Invalid sticker.")
    return @request("createNewStickerSet", postParam, pngSticker)

  addStickerToSet: (userID, name, pngSticker, \
  emojis, postParam = {}) =>
    if pngSticker instanceof String
      postParam["png_sticker"] = pngSticker
      pngSticker = null
    else if pngSticker instanceof Object and \
    pngSticker["filePath"]? and pngSticker["fileBuf"]?
      pngSticker["name"] = "png_sticker"
    else
      throw new Error("Invalid sticker.")
    return @request("addStickerToSet", postParam, pngSticker)

  setStickerPositionInSet: (sticker, position) =>
    return @request("setStickerPositionInSet", \
    {"sticker": sticker, "position": position})

  deleteStickerFromSet: (sticker) =>
    return @request("deleteStickerFromSet", {"sticker": sticker})

  ###
  param: Object: https://core.telegram.org/bots/api#getupdates
  return: Promise() -> Update Object: https://core.telegram.org/bots/api#update
  WARNING: You shouldn't not call this manually, instead you'd better use
  BotManager with your own BotTemplate, Manager will poll updates
  automatically and call your Template to process updates.
  ###
  getUpdates: (postParam) =>
    return @request("getUpdates", postParam)
