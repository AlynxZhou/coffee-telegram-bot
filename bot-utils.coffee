http = require("http")
path = require("path")
promisify = require("util").promisify
readFileAsync = promisify(require("fs").readFile)
writeFileAsync = promisify(require("fs").writeFile)
accessAsync = promisify(require("fs").access)

perFromID = (update) ->
  if update["message"]["from"]?["id"]?
    identifier = "#{update["message"]["from"]["id"]}"
  else
    identifier = "0"
  return identifier

readFileAsObj = (filePath) ->
  return readFileAsync(path.normalize(filePath)).then((data) ->
    return {"filePath": filePath, "fileBuf": data}
  )

getTuling = (apiKey, text, userId = 0) ->
  chunks = []
  size = 0
  postParam = {
    "perception": {
      "inputText": {
        "text": text
      }
    },
    "userInfo": {
      "apiKey": "#{apiKey}",
      "userId": "#{userId}"
    }
  }
  httpOptions = {
    "protocol": "http:",
    "host": "openapi.tuling123.com",
    "port": 80,
    "method": "POST",
    "path": "/openapi/api/v2"
  }
  postData = JSON.stringify(postParam)
  if not postData?
    postData = ""
  httpOptions["headers"] = {
    "Content-Type": "application/json",
    "Content-Length": "#{Buffer.byteLength(postData)}"
  }
  return new Promise((resolve, reject) ->
    req = http.request(httpOptions, (res) ->
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
    req.write(postData)
    req.end()
  ).then((resStr) ->
    resJSON = JSON.parse(resStr)
    if resJSON["intent"]["code"] not in [5000, 6000, 4000, 4001, 4002, 4003, \
    4005, 4007, 4100, 4200, 4300, 4400, 4500, 4600, 4602, 7002, 8008]
      return resJSON["results"]
    else
      throw new Error("TulingError: #{resJSON["intent"]["code"]}")
  )

log = (msg) ->
  console.log("#{Date()} LOG: #{msg}")

debug = (msg) ->
  console.debug("#{Date()} DEBUG: #{msg}")

error = (error) ->
  console.error("#{Date()} ERROR: #{error.msg}\n#{error.stack}")

module.exports =
botUtils = {
  perFromID: perFromID,
  readFileAsync: readFileAsync,
  writeFileAsync: writeFileAsync,
  readFileAsObj: readFileAsObj,
  accessAsync: accessAsync,
  getTuling: getTuling,
  log: log,
  debug: debug,
  error: error
}
