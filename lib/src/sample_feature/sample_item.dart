/// A placeholder class that represents an entity or model.
class SampleItem {
  const SampleItem(this.id);

  final int id;

  Map<String, dynamic> toJson() => {
        "id": id,
      };

  factory SampleItem.fromJson(Map<String, dynamic> json) {
    return SampleItem(json["id"] as int);
  }
}
