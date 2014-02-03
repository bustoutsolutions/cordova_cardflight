var argscheck = require('cordova/argscheck'),
  channel = require('cordova/channel'),
  utils = require('cordova/utils'),
  exec = require('cordova/exec'),
  cordova = require('cordova');

channel.createSticky('onCordovaCardFlightReady');
channel.waitForInitialization('onCordovaCardFlightReady');

function CardFlight() {
    this.available = false;
    this.platform = null;
    this.cordova = null;
    this.config = null;

    var _this = this;

    channel.onCordovaReady.subscribe(function() {
      _this.initialize();
    });
}

CardFlight.prototype.configure = function(options) {
  var successCallback = function() {
    console.log("SUCCESSFULLY SET TOKENS");
  }
  var errorCallback = function() {
    console.log("ERROR SETTING TOKENS");
  }
  this.setApiTokens(successCallback, errorCallback, options);
}

CardFlight.prototype.initialize = function() {
  var _this = this;

  var attachedSuccessCallback = function() {
    console.log("startOnReaderAttached Successful", _this);
  };
  var attachedErrorCallback = function() {
    console.log("startOnReaderAttached failure");
  }
  this.startOnReaderAttached(attachedSuccessCallback, attachedErrorCallback);

  var readerConnectedSuccess = function () {
    console.log("startOnReaderConnected Successful", _this);
  }
  var readerConnectedFail = function () {
    console.log("startOnReaderConnected failure");
  }
  this.startOnReaderConnected(readerConnectedSuccess, readerConnectedFail);

  var readerDisconnectedSuccess = function() {
    console.log("startOnReaderDisconnected Successful", _this);
  }
  var readerDisconnectedFail = function() {
    console.log("startOnReaderDisconnected fail");
  }
  this.startOnReaderDisconnected(readerDisconnectedSuccess, readerDisconnectedFail);

  var readerConnectingSuccess = function() {
    console.log("startOnReaderConnecting Successful", _this);
  }
  var readerConnectingFail = function() {
    console.log("startOnReaderConnecting fail");
  }
  this.startOnReaderConnecting(readerConnectingSuccess, readerConnectingFail);

  channel.onCordovaCardFlightReady.fire();
}


CardFlight.prototype.setApiTokens = function(successCallback, errorCallback, options) {
    exec(successCallback, errorCallback, "CDVCardFlight", "setApiTokens", [options.apiToken, options.accountToken]);
};

CardFlight.prototype.beginSwipe = function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, "CDVCardFlight", "swipeCard", []);
};

CardFlight.prototype.startOnReaderAttached = function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, "CDVCardFlight", "startOnReaderAttached", []);
};

CardFlight.prototype.startOnReaderConnected = function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, "CDVCardFlight", "startOnReaderConnected", []);
};

CardFlight.prototype.startOnReaderDisconnected = function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, "CDVCardFlight", "startOnReaderDisconnected", []);
};

CardFlight.prototype.startOnReaderConnecting = function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, "CDVCardFlight", "startOnReaderConnecting", []);
};

module.exports = new CardFlight();
