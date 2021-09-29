String convertStringToTitleCase(String? text) {
  if (text == null || text == "") {
    return "No Name";
  } else if (!text.contains(' ')) {
    return text[0].toUpperCase() + text.substring(1, text.length);
  } else {
    final List<String> words = text.split(' ');
    String returnedText = "";
    words.forEach((element) {
      if (words[words.length - 1] == element) {
        returnedText +=
            element[0].toUpperCase() + element.substring(1, element.length);
      } else {
        returnedText += element[0].toUpperCase() +
            element.substring(1, element.length) +
            " ";
      }
    });
    return returnedText;
  }
}
