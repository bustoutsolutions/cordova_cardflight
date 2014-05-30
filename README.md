# Usage

## Configuration

```javascript
cardFlight.configure({
  apiToken: "<Card Flight API Token>",
  accountToken: "<Merchant Account Token>"
});
```

## Swipe card

```javascript
cardFlight.beginSwipe(func(<card>), func(<error>)[, options])
```

Pass the options `{swipeMessage: 'none'}` to beginSwipe to swipe without a popup message (the CardFlight `beginSwipeWithMessage:nil`).

### Example

The callback provided to setCallbackOnSwipeComplete returns general card info — card.name, .last4, .cardType, .expirationMonth, .expirationYear. If the swipe is successful, the card is tokenized and the success callback provided to beginSwipe is called.

```javascript

var swipeCallback = function (card) {
  console.log("swipe successful", card);
}
cardFlight.setCallbackOnSwipeComplete(swipeCallback)

// beginSwipe callback returns after tokenize, returns only card.cardToken
var successCallback = function (card) {
  console.log("Tokenize successful", card.cardToken);
}

var errorCallback = function (error) {
  console.log("swipe error", error.message)
}

cardFlight.beginSwipe(successCallback, errorCallback, {
  swipeMessage: "Begin Swipe"
});
```

# Object Reference

### Card

```javascript
{
  cardToken: "<token on merchant>"
}
```

### Error

```javascript
{
  message: "<some descriptive error message>",
  type: "<some type in Error.TYPES>"
}
```
