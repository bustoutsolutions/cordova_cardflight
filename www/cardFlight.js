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
    console.log("CardFlight: ReaderAttached", _this);
  };
  this.setCallbackOnReaderAttached(attachedSuccessCallback);

  var readerConnectedSuccess = function () {
    console.log("CardFlight: ReaderConnected", _this);
  }
  var readerConnectedFail = function () {
    console.log("CardFlight: ReaderConnected Failure");
  }
  this.setCallbackOnReaderConnected(readerConnectedSuccess, readerConnectedFail);

  var readerDisconnectedSuccess = function() {
    console.log("CardFlight: ReaderDisconnected", _this);
  }
  this.setCallbackOnReaderDisconnected(readerDisconnectedSuccess);

  var readerConnectingSuccess = function() {
    console.log("CardFlight: ReaderConnecting", _this);
  }
  this.setCallbackOnReaderConnecting(readerConnectingSuccess);

  channel.onCordovaCardFlightReady.fire();
}

//  An empty callback to pass into cordova.exec
CardFlight.prototype.nullCallback = function() {};

CardFlight.prototype.setApiTokens = function(successCallback, errorCallback, options) {
    exec(successCallback, errorCallback, "CDVCardFlight", "setApiTokens", [options.apiToken, options.accountToken]);
};

CardFlight.prototype.beginSwipe = function(successCallback, errorCallback, opts) {
    if(! 'swipeMessage' in opts) {
      opts.swipeMessage = "Swipe Card Please";
    }
    exec(successCallback, errorCallback, "CDVCardFlight", "swipeCard", [opts.swipeMessage]);
};

CardFlight.prototype.setCallbackOnReaderAttached = function(successCallback) {
    exec(successCallback, CardFlight.prototype.nullCallback, "CDVCardFlight", "setCallbackOnReaderAttached", []);
};

CardFlight.prototype.setCallbackOnReaderConnected = function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, "CDVCardFlight", "setCallbackOnReaderConnected", []);
};

CardFlight.prototype.setCallbackOnReaderDisconnected = function(successCallback) {
    exec(successCallback, CardFlight.prototype.nullCallback, "CDVCardFlight", "setCallbackOnReaderDisconnected", []);
};

CardFlight.prototype.setCallbackOnReaderConnecting = function(successCallback) {
    exec(successCallback, CardFlight.prototype.nullCallback, "CDVCardFlight", "setCallbackOnReaderConnecting", []);
};

CardFlight.prototype.setCallbackOnSwipeComplete = function(successCallback) {
    exec(successCallback, CardFlight.prototype.nullCallback, "CDVCardFlight", "setCallbackOnSwipeComplete", []);
};

module.exports = new CardFlight();
