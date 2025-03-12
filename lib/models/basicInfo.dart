class BasicInfo{
  String name;
  String level;

  BasicInfo({
    required this.name,
    required this.level,
  });
  // corrected fromJson contructor
 BasicInfo.fromJson(Map<String,dynamic>json):this(
   name: json['name']! as String,
   level: json['level']! as String,
 );
  BasicInfo copyWith({
    String? name,
    String? level,
  }) {
    return BasicInfo(
      name: name ?? this.name,
      level: level ?? this.level,
    );
  }
  Map<String, Object?> toJson() {
    return {
      'name': name,
      'level': level,
    };

  }
}