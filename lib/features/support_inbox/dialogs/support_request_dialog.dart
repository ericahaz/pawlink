part of pawlink_admin;

class SupportRequestDialog extends StatefulWidget{
  const SupportRequestDialog({super.key});@override State<SupportRequestDialog> createState()=>_SupportRequestDialogState();
}
class _SupportRequestDialogState extends State<SupportRequestDialog>{
  final name=TextEditingController(),email=TextEditingController(),subject=TextEditingController(),message=TextEditingController();
  @override Widget build(BuildContext context)=>AlertDialog(title:Row(children:[const Expanded(child:Text('Contact PawLink Support')),IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.close))]),
    content:SizedBox(width:560,child:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('Your message will appear in the administrator Support Inbox.',style:TextStyle(color:textMuted)),
      const SizedBox(height:12),const FormLabel('Name'),TextField(controller:name,decoration:const InputDecoration(prefixIcon:Icon(Icons.person_outline))),
      const SizedBox(height:10),const FormLabel('Email'),TextField(controller:email,decoration:const InputDecoration(prefixIcon:Icon(Icons.email_outlined))),
      const SizedBox(height:10),const FormLabel('Subject'),TextField(controller:subject,decoration:const InputDecoration(prefixIcon:Icon(Icons.subject_outlined))),
      const SizedBox(height:10),const FormLabel('Message'),TextField(controller:message,maxLines:5)
    ]))),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton.icon(onPressed:(){
      if([name,email,subject,message].any((c)=>c.text.trim().isEmpty)){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Please complete all fields.')));return;}
      final id='SUP-${DateTime.now().millisecondsSinceEpoch}';supportMessages.insert(0,SupportMessage(id:id,sender:name.text.trim(),email:email.text.trim(),subject:subject.text.trim(),message:message.text.trim(),time:DateTime.now()));
      adminNotifications.insert(0,AdminNotification(id:'N-${DateTime.now().millisecondsSinceEpoch}',title:'New Help Center message',message:'${name.text.trim()} sent: ${subject.text.trim()}',time:DateTime.now(),pageIndex:17));
      logActivity('Received Help Center message',id);Navigator.pop(context);ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Message sent to the Admin Support Inbox.')));
    },icon:const Icon(Icons.send_outlined),label:const Text('Send Message'))]);
}

// ============================================================
// HELP CENTER
// ============================================================

