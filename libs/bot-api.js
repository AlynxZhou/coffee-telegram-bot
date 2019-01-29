// Generated by CoffeeScript 2.2.4
(function() {
  var BotApi, botUtils, http, path;

  path = require("path");

  http = require("http");

  // querystring = require("querystring")
  botUtils = require("./bot-utils");

  /*
  Official Document: https://core.telegram.org/bots/api/
  TODO: Inline mode (I need to learn what is inline mode first).
  */
  BotApi = class BotApi {
    constructor(token) {
      this.request = this.request.bind(this);
      this.getMe = this.getMe.bind(this);
      this.sendChatAction = this.sendChatAction.bind(this);
      this.sendMessage = this.sendMessage.bind(this);
      this.forwardMessage = this.forwardMessage.bind(this);
      this.sendPhoto = this.sendPhoto.bind(this);
      this.sendAudio = this.sendAudio.bind(this);
      this.sendDocument = this.sendDocument.bind(this);
      this.sendVideo = this.sendVideo.bind(this);
      this.sendVideoNote = this.sendVideoNote.bind(this);
      this.sendLocation = this.sendLocation.bind(this);
      this.sendContact = this.sendContact.bind(this);
      this.getUserProfilePhotos = this.getUserProfilePhotos.bind(this);
      this.getFile = this.getFile.bind(this);
      this.kickChatMember = this.kickChatMember.bind(this);
      this.unbanChatMember = this.unbanChatMember.bind(this);
      this.restrictChatMember = this.restrictChatMember.bind(this);
      this.promoteChatMember = this.promoteChatMember.bind(this);
      this.exportChatInviteLink = this.exportChatInviteLink.bind(this);
      this.setChatPhoto = this.setChatPhoto.bind(this);
      this.deleteChatPhoto = this.deleteChatPhoto.bind(this);
      this.setChatTitle = this.setChatTitle.bind(this);
      this.setChatDescription = this.setChatDescription.bind(this);
      this.pinChatMessage = this.pinChatMessage.bind(this);
      this.unpinChatMessage = this.unpinChatMessage.bind(this);
      this.leaveChat = this.leaveChat.bind(this);
      this.getChat = this.getChat.bind(this);
      this.getChatAdministrators = this.getChatAdministrators.bind(this);
      this.getChatMembersCount = this.getChatMembersCount.bind(this);
      this.getChatMember = this.getChatMember.bind(this);
      this.setChatStickerSet = this.setChatStickerSet.bind(this);
      this.deleteChatStickerSet = this.deleteChatStickerSet.bind(this);
      this.editMessageText = this.editMessageText.bind(this);
      this.editMessageCaption = this.editMessageCaption.bind(this);
      this.editMessageReplyMarkup = this.editMessageReplyMarkup.bind(this);
      this.deleteMessage = this.deleteMessage.bind(this);
      this.sendSticker = this.sendSticker.bind(this);
      this.getStickerSet = this.getStickerSet.bind(this);
      this.uploadStickerFile = this.uploadStickerFile.bind(this);
      this.createNewStickerSet = this.createNewStickerSet.bind(this);
      this.addStickerToSet = this.addStickerToSet.bind(this);
      this.setStickerPositionInSet = this.setStickerPositionInSet.bind(this);
      this.deleteStickerFromSet = this.deleteStickerFromSet.bind(this);
      /*
      param: Object: https://core.telegram.org/bots/api#getupdates
      return: Promise() -> Update Object: https://core.telegram.org/bots/api#update
      WARNING: You shouldn't not call this manually, instead you'd better use
      BotManager with your own BotTemplate, Manager will poll updates
      automatically and call your Template to process updates.
      */
      this.getUpdates = this.getUpdates.bind(this);
      this.token = token;
    }

    request(botMethod, postParam, fileData) {
      var boundary, chunks, fileBegin, fileEnd, httpOptions, k, postData, size;
      chunks = [];
      size = 0;
      httpOptions = {
        "protocol": "http:",
        "host": "api.telegram.org",
        "port": 443,
        "method": "POST",
        "path": `/bot${this.token}/${botMethod}`,
        "timeout": 1500
      };
      if (fileData == null) {
        postData = JSON.stringify(postParam);
        if (postData == null) {
          postData = "";
        }
        httpOptions["headers"] = {
          "Content-Type": "application/json",
          "Content-Length": `${Buffer.byteLength(postData)}`
        };
      } else {
        boundary = Math.random().toString(16);
        fileBegin = `\r\n--${boundary}\r\n`;
        for (k in postParam) {
          fileBegin += `Content-Disposition: form-data; name="${k}"\r\n\r\n${postParam[k]}\r\n--${boundary}\r\n`;
        }
        fileBegin += `Content-Disposition: form-data; name="${fileData["name"]}"; filename="${path.basename(path.normalize(fileData["filePath"]))}"\r\n\r\n`;
        fileEnd = `\r\n--${boundary}--`;
        httpOptions["headers"] = {
          "Content-Type": `multipart/form-data; boundary=${boundary}`,
          "Transfer-Encoding": "chunked",
          "Content-Length": Buffer.byteLength(fileBegin) + Buffer.byteLength(fileData["fileBuf"]) + Buffer.byteLength(fileEnd)
        };
      }
      return new Promise(function(resolve, reject) {
        var req;
        req = http.request(httpOptions, function(res) {
          // If there is wide character between chunks, it cannot be
          // encoded easily due to spliting. Instead we need to concat
          // them then encoding.
          // res.setEncoding("utf8")
          res.on("data", function(chunk) {
            return chunks.push(chunk);
          });
          return res.on("end", function() {
            resolve(Buffer.concat(chunks).toString("utf8"));
            return chunks = [];
          });
        });
        req.on("error", reject);
        if (fileData == null) {
          req.write(postData);
        } else {
          req.write(fileBegin);
          req.write(fileData["fileBuf"]);
          req.write(fileEnd);
        }
        return req.end();
      }).then(function(resStr) {
        var resJSON;
        resJSON = JSON.parse(resStr);
        if (resJSON["ok"]) {
          return resJSON["result"];
        } else {
          throw new Error(`TelegramError: ${resJSON["error_code"]}: ${resJSON["description"]}`);
        }
      });
    }

    getMe() {
      return this.request("getMe");
    }

    sendChatAction(chatID, action) {
      return this.request("sendChatAction", {
        "chat_id": chatID,
        "action": action
      });
    }

    sendMessage(chatID, text, postParam = {}) {
      postParam["chat_id"] = chatID;
      postParam["text"] = text;
      return this.request("sendMessage", postParam);
    }

    forwardMessage(chatID, fromChatID, messageID, postParam = {}) {
      postParam["chat_id"] = chatID;
      postParam["from_chat_id"] = fromChatID;
      postParam["message_id"] = messageID;
      return this.request("forwardMessage", postParam);
    }

    sendPhoto(chatID, photo, postParam = {}) {
      postParam["chat_id"] = chatID;
      if (photo instanceof String) {
        postParam["photo"] = photo;
        photo = null;
      } else if (photo instanceof Object && (photo["filePath"] != null) && (photo["fileBuf"] != null)) {
        // For the file part name
        photo["name"] = "photo";
      } else {
        throw new Error("Invalid photo.");
      }
      return this.request("sendPhoto", postParam, photo);
    }

    sendAudio(chatID, audio, postParam = {}) {
      postParam["chat_id"] = chatID;
      if (audio instanceof String) {
        postParam["audio"] = audio;
        audio = null;
      } else if (audio instanceof Object && (audio["filePath"] != null) && (audio["fileBuf"] != null)) {
        // For the file part name
        audio["name"] = "audio";
      } else {
        throw new Error("Invalid audio.");
      }
      return this.request("sendAudio", postParam, audio);
    }

    sendDocument(chatID, document, postParam = {}) {
      postParam["chat_id"] = chatID;
      if (document instanceof String) {
        postParam["document"] = document;
        document = null;
      } else if (document instanceof Object && (document["filePath"] != null) && (document["fileBuf"] != null)) {
        document["name"] = "document";
      } else {
        throw new Error("Invalid document.");
      }
      return this.request("sendDocument", postParam, document);
    }

    sendVideo(chatID, video, postParam = {}) {
      postParam["chat_id"] = chatID;
      if (video instanceof String) {
        postParam["video"] = video;
        video = null;
      } else if (video instanceof Object && (video["filePath"] != null) && (video["fileBuf"] != null)) {
        video["name"] = "video";
      } else {
        throw new Error("Invalid video.");
      }
      return this.request("sendVideo", postParam, video);
    }

    sendVideoNote(chatID, videoNote, postParam = {}) {
      postParam["chat_id"] = chatID;
      if (videoNote instanceof String) {
        postParam["video_note"] = videoNote;
        videoNote = null;
      } else if (videoNote instanceof Object && (videoNote["filePath"] != null) && (videoNote["fileBuf"] != null)) {
        videoNote["name"] = "video_note";
      } else {
        throw new Error("Invalid videoNote.");
      }
      return this.request("sendVideo", postParam, videoNote);
    }

    sendLocation(chatID, latitude, longitude, postParam = {}) {
      postParam["chat_id"] = chatID;
      postParam["latitude"] = latitude;
      postParam["longitude"] = longitude;
      return this.request("sendLocation", postParam);
    }

    sendContact(chatID, phoneNumber, firstName, postParam = {}) {
      postParam["chat_id"] = chatID;
      postParam["phone_number"] = phoneNumber;
      postParam["first_name"] = firstName;
      return this.request("sendLocation", postParam);
    }

    getUserProfilePhotos(userID, postParam = {}) {
      postParam["user_id"] = userID;
      return this.request("getUserProfilePhotos", postParam);
    }

    getFile(fileID) {
      return this.request("getFile", {
        "file_id": fileID
      });
    }

    kickChatMember(chatID, userID, postParam = {}) {
      postParam["chat_id"] = chatID;
      postParam["user_id"] = userID;
      return this.request("kickChatMember", postParam);
    }

    unbanChatMember(chatID, userID) {
      return this.request("unbanChatMember", {
        "chat_id": chatID,
        "user_id": userID
      });
    }

    restrictChatMember(chatID, userID, postParam = {}) {
      postParam["chat_id"] = chatID;
      postParam["user_id"] = userID;
      return this.request("restrictChatMember", postParam);
    }

    promoteChatMember(chatID, userID, postParam = {}) {
      postParam["chat_id"] = chatID;
      postParam["user_id"] = userID;
      return this.request("promoteChatMember", postParam);
    }

    exportChatInviteLink(chatID) {
      return this.request("exportChatInviteLink", {
        "chat_id": chatID
      });
    }

    setChatPhoto(chatID, photo) {
      return this.request("setChatPhoto", {
        "chat_id": chatID
      }, photo);
    }

    deleteChatPhoto(chatID) {
      return this.request("deleteChatPhoto", {
        "chat_id": chatID
      });
    }

    setChatTitle(chatID, title) {
      return this.request("setChatTitle", {
        "chat_id": chatID,
        "title": title
      });
    }

    setChatDescription(chatID, postParam = {}) {
      postParam["chat_id"] = chatID;
      return this.request("setChatDescription", postParam);
    }

    pinChatMessage(chatID, messageID, postParam = {}) {
      postParam["chat_id"] = chatID;
      postParam["message_id"] = messageID;
      return this.request("pinChatMessage", postParam);
    }

    unpinChatMessage(chatID) {
      return this.request("unpinChatMessage", {
        "chat_id": chatID
      });
    }

    leaveChat(chatID) {
      return this.request("leaveChat", {
        "chat_id": chatID
      });
    }

    getChat(chatID) {
      return this.request("getChat", {
        "chat_id": chatID
      });
    }

    getChatAdministrators(chatID) {
      return this.request("getChatAdministrators", {
        "chat_id": chatID
      });
    }

    getChatMembersCount(chatID) {
      return this.request("getChatMembersCount", {
        "chat_id": chatID
      });
    }

    getChatMember(chatID, userID) {
      return this.request("getChatMember", {
        "chat_id": chatID,
        "user_id": userID
      });
    }

    setChatStickerSet(chatID, stickerSetName) {
      return this.request("setChatStickerSet", {
        "chat_id": chatID,
        "sticker_set_name": stickerSetName
      });
    }

    deleteChatStickerSet(chatID) {
      return this.request("deleteChatStickerSet", {
        "chat_id": chatID
      });
    }

    editMessageText(text, postParam = {}) {
      postParam["text"] = text;
      return this.return(this.request("editMessageText", postParam));
    }

    editMessageCaption(postParam = {}) {
      return this.request("editMessageCaption", postParam);
    }

    editMessageReplyMarkup(postParam = {}) {
      return this.request("editMessageReplyMarkup", postParam);
    }

    deleteMessage(chatID, messageID) {
      return this.request("deleteMessage", {
        "chat_id": chatID,
        "message_id": messageID
      });
    }

    sendSticker(chatID, sticker, postParam = {}) {
      postParam["chat_id"] = chatID;
      if (sticker instanceof String) {
        postParam["sticker"] = sticker;
        sticker = null;
      } else if (sticker instanceof Object && (sticker["filePath"] != null) && (sticker["fileBuf"] != null)) {
        sticker["name"] = "sticker";
      } else {
        throw new Error("Invalid sticker.");
      }
      return this.request("sendSticker", postParam, sticker);
    }

    getStickerSet(name) {
      return this.request("getStickerSet", {
        "name": name
      });
    }

    uploadStickerFile(userID, pngSticker) {
      if (pngSticker instanceof Object && (pngSticker["filePath"] != null) && (pngSticker["fileBuf"] != null)) {
        pngSticker["name"] = "png_sticker";
      } else {
        throw new Error("Invalid sticker.");
      }
      return this.request("uploadStickerFile", {
        "user_id": userID
      }, pngSticker);
    }

    createNewStickerSet(userID, name, title, pngSticker, emojis, postParam = {}) {
      if (pngSticker instanceof String) {
        postParam["png_sticker"] = pngSticker;
        pngSticker = null;
      } else if (pngSticker instanceof Object && (pngSticker["filePath"] != null) && (pngSticker["fileBuf"] != null)) {
        pngSticker["name"] = "png_sticker";
      } else {
        throw new Error("Invalid sticker.");
      }
      return this.request("createNewStickerSet", postParam, pngSticker);
    }

    addStickerToSet(userID, name, pngSticker, emojis, postParam = {}) {
      if (pngSticker instanceof String) {
        postParam["png_sticker"] = pngSticker;
        pngSticker = null;
      } else if (pngSticker instanceof Object && (pngSticker["filePath"] != null) && (pngSticker["fileBuf"] != null)) {
        pngSticker["name"] = "png_sticker";
      } else {
        throw new Error("Invalid sticker.");
      }
      return this.request("addStickerToSet", postParam, pngSticker);
    }

    setStickerPositionInSet(sticker, position) {
      return this.request("setStickerPositionInSet", {
        "sticker": sticker,
        "position": position
      });
    }

    deleteStickerFromSet(sticker) {
      return this.request("deleteStickerFromSet", {
        "sticker": sticker
      });
    }

    getUpdates(postParam) {
      return this.request("getUpdates", postParam);
    }

  };

  module.exports = BotApi;

}).call(this);