// Generated by CoffeeScript 2.2.4
(function() {
  var accessAsync, botUtils, debug, error, getTuling, http, log, path, perFromID, promisify, readFileAsObj, readFileAsync, writeFileAsync;

  http = require("http");

  path = require("path");

  promisify = require("util").promisify;

  accessAsync = promisify(require("fs").access);

  readFileAsync = promisify(require("fs").readFile);

  writeFileAsync = promisify(require("fs").writeFile);

  perFromID = function(update) {
    var identifier, ref, ref1;
    if (((ref = update["message"]) != null ? (ref1 = ref["from"]) != null ? ref1["id"] : void 0 : void 0) != null) {
      identifier = `${update["message"]["from"]["id"]}`;
    } else {
      identifier = "0";
    }
    return identifier;
  };

  readFileAsObj = function(filePath) {
    return readFileAsync(path.normalize(filePath)).then(function(data) {
      return {
        "filePath": filePath,
        "fileBuf": data
      };
    });
  };

  getTuling = function(apiKey, text, userId = 0) {
    var chunks, httpOptions, postData, postParam, size;
    chunks = [];
    size = 0;
    postParam = {
      "perception": {
        "inputText": {
          "text": text
        }
      },
      "userInfo": {
        "apiKey": `${apiKey}`,
        "userId": `${userId}`
      }
    };
    httpOptions = {
      "protocol": "http:",
      "host": "openapi.tuling123.com",
      "port": 80,
      "method": "POST",
      "path": "/openapi/api/v2"
    };
    postData = JSON.stringify(postParam);
    if (postData == null) {
      postData = "";
    }
    httpOptions["headers"] = {
      "Content-Type": "application/json",
      "Content-Length": `${Buffer.byteLength(postData)}`
    };
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
      req.write(postData);
      return req.end();
    }).then(function(resStr) {
      var ref, resJSON;
      resJSON = JSON.parse(resStr);
      if ((ref = resJSON["intent"]["code"]) !== 5000 && ref !== 6000 && ref !== 4000 && ref !== 4001 && ref !== 4002 && ref !== 4003 && ref !== 4005 && ref !== 4007 && ref !== 4100 && ref !== 4200 && ref !== 4300 && ref !== 4400 && ref !== 4500 && ref !== 4600 && ref !== 4602 && ref !== 7002 && ref !== 8008) {
        return resJSON["results"];
      } else {
        throw new Error(`TulingError: ${resJSON["intent"]["code"]}`);
      }
    });
  };

  log = function(msg) {
    return console.log(`${Date()} LOG: ${msg}`);
  };

  debug = function(msg) {
    return console.debug(`${Date()} DEBUG: ${msg}`);
  };

  error = function(error) {
    return console.error(`${Date()} ERROR: ${error.msg}\n${error.stack}`);
  };

  module.exports = botUtils = {
    "perFromID": perFromID,
    "readFileAsync": readFileAsync,
    "writeFileAsync": writeFileAsync,
    "readFileAsObj": readFileAsObj,
    "accessAsync": accessAsync,
    "getTuling": getTuling,
    "log": log,
    "debug": debug,
    "error": error
  };

}).call(this);
