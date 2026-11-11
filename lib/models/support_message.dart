part of pawlink_admin;

class SupportMessage {
  final String id, sender, email, subject, message;
  final DateTime time;
  String status;
  SupportMessage({required this.id,required this.sender,required this.email,required this.subject,required this.message,required this.time,this.status='New'});
}
