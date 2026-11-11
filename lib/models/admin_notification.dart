part of pawlink_admin;

class AdminNotification {
  final String id,title,message; final DateTime time; final int pageIndex; bool read;
  AdminNotification({required this.id,required this.title,required this.message,required this.time,required this.pageIndex,this.read=false});
}

