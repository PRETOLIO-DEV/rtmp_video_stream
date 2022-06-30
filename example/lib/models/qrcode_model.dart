
class QRCodeModel {
  int? id;
  DateTime? startDateTime;
  double? durationInMinutes;
  String? mediaUrl;
  DateTime? endDateTime;

  QRCodeModel(
      {this.id,
      this.startDateTime,
      this.durationInMinutes,
      this.mediaUrl,
      this.endDateTime});

  QRCodeModel.froMap(Map map){
    this.id = map['id'] != null ? int.tryParse(map['id'].toString()) : null;
    this.startDateTime = map['startDateTime'] != null ? DateTime.tryParse(map['startDateTime']) : null;
    this.endDateTime = map['endDateTime'] != null ? DateTime.tryParse(map['endDateTime']) : null;
    this.durationInMinutes= map['durationInMinutes'] != null && map['durationInMinutes'] > 0 ? map['durationInMinutes'] : null;
    this.mediaUrl= map['mediaUrl'] != null ? map['mediaUrl'] : null;
  }
}