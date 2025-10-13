Map<String, dynamic> cleanNullData(Map<String, dynamic> data) {
  var map = Map<String, dynamic>.from(data);
  map.forEach((key, value) {
    if (value == null) {
      data.remove(key);
    }
  });
  return data;
}
