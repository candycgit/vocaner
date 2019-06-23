class Word {
  final int id;
  String name;
  String transcription;
  String description;
  String date; // in YYYY-MM-DD format
  int status; // 0 => new; 10 => learned

  Word(
      {this.id,
      this.name,
      this.transcription,
      this.description,
      this.date,
      this.status});

  factory Word.fromMap(Map<String, dynamic> json) => new Word(
      id: json["id"],
      name: json["name"],
      transcription: json["transcription"],
      description: json["description"],
      date: json["date"],
      status: json["status"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "transcription": transcription,
        "description": description,
        "date": date,
        "status": status
      };

  void setStatus() {
    status = 10;
  }

  void resetStatus() {
    status = 0;
  }

  bool isNew() {
    return status == 0;
  }
}
