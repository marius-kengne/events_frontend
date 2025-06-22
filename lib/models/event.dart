class Event {
  final int id;
  final String title;
  final String? description;
  final DateTime? date;
  final String? location;
  final bool published;
  final String? organizerEmail;

  Event({
    required this.id,
    required this.title,
    this.description,
    this.date,
    this.location,
    required this.published,
    this.organizerEmail,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      location: json['location'],
      published: json['published'],
      organizerEmail: json['organizer_email'],
    );
  }
}
