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
  exec(function() { cordova.fireWindowEvent("cfreaderattached") }, null, "CDVCardFlight", "setCallbackOnReaderAttached", []);
  exec(function() { cordova.fireWindowEvent("cfreaderconnected") }, null, "CDVCardFlight", "setCallbackOnReaderConnected", []);
  exec(function() { cordova.fireWindowEvent("cfreaderdisconnected") }, null, "CDVCardFlight", "setCallbackOnReaderDisconnected", []);
  exec(function() { cordova.fireWindowEvent("cfreaderconnecting") }, null, "CDVCardFlight", "setCallbackOnReaderConnecting", []);
  exec(function(data) { cordova.fireWindowEvent("cfreaderswipecomplete", {card: data}) }, null, "CDVCardFlight", "setCallbackOnSwipeComplete", []);

  channel.onCordovaCardFlightReady.fire();
}

CardFlight.prototype.setApiTokens = function(successCallback, errorCallback, options) {
    exec(successCallback, errorCallback, "CDVCardFlight", "setApiTokens", [options.apiToken, options.accountToken]);
};

CardFlight.prototype.cancelSwipe = function() {
  exec(null, null, "CDVCardFlight", "cancelSwipe", []);
};

CardFlight.prototype.beginSwipe = function(successCallback, errorCallback, opts) {
    if(! 'swipeMessage' in opts) {
      opts.swipeMessage = "Swipe Card Please";
    }
    exec(successCallback, errorCallback, "CDVCardFlight", "swipeCard", [opts.swipeMessage]);
};

module.exports = new CardFlight();
