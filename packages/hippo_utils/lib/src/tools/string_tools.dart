//
String truncateStringToMaxLength(String input, {int maxLength = 64}) {
  if (input.length <= maxLength) {
    return input;
  }
  return input.substring(0, maxLength);
}
