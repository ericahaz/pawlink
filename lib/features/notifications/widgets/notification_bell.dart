part of pawlink_admin;

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});
  @override State<NotificationBell> createState()=>_NotificationBellState();
}
class _NotificationBellState extends State<NotificationBell>{
  @override Widget build(BuildContext context){
    final count=adminNotifications.where((n)=>!n.read).length;
    return Stack(clipBehavior:Clip.none,children:[
      IconButton(tooltip:'Notifications',icon:const Icon(Icons.notifications_none_outlined,color:forestGreen),
        onPressed:()=>showDialog(context:context,builder:(_)=>NotificationsDialog(onChanged:()=>setState((){})))),
      if(count>0) Positioned(right:2,top:1,child:Container(padding:const EdgeInsets.symmetric(horizontal:5,vertical:2),
        decoration:BoxDecoration(color:dangerText,borderRadius:BorderRadius.circular(10)),
        child:Text(count>9?'9+':'$count',style:const TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.bold))))
    ]);
  }
}
