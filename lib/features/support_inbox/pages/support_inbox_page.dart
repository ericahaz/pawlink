part of pawlink_admin;

class SupportInboxPage extends StatefulWidget{
  const SupportInboxPage({super.key}); @override State<SupportInboxPage> createState()=>_SupportInboxPageState();
}
class _SupportInboxPageState extends State<SupportInboxPage>{
  @override Widget build(BuildContext context)=>AdminPage(title:'Support Inbox',
    subtitle:'Messages sent by users through the Help Center are delivered here.',
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Container(width:double.infinity,padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:softBeige,borderRadius:BorderRadius.circular(14)),
        child:const Row(children:[Icon(Icons.inbox_outlined,color:forestGreen),SizedBox(width:12),Expanded(child:Text('Help Center messages go directly to this administrator inbox. Open a message to review it and write an admin response.'))])),
      const SizedBox(height:18),
      if(supportMessages.isEmpty) const EmptyCard(text:'No support messages yet.')
      else for(final m in supportMessages) Padding(padding:const EdgeInsets.only(bottom:10),child:AppCard(child:ListTile(
        leading:CircleAvatar(backgroundColor:softBeige,child:Icon(m.status=='New'?Icons.mark_email_unread_outlined:Icons.drafts_outlined,color:forestGreen)),
        title:Text(m.subject,style:const TextStyle(fontWeight:FontWeight.bold)),
        subtitle:Text('${m.sender} • ${m.email}\n${m.message}',maxLines:2,overflow:TextOverflow.ellipsis),isThreeLine:true,
        trailing:const Icon(Icons.chevron_right),onTap:()=>_open(context,m)))),
    ]));
  void _open(BuildContext context,SupportMessage m){
    if(m.status=='New')setState(()=>m.status='Read'); final c=TextEditingController();
    showDialog(context:context,builder:(_)=>AlertDialog(title:Row(children:[const Icon(Icons.support_agent,color:forestGreen),const SizedBox(width:8),Expanded(child:Text(m.subject)),IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.close))]),
      content:SizedBox(width:580,child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
        DetailLine(icon:Icons.person_outline,label:'From',value:m.sender),DetailLine(icon:Icons.email_outlined,label:'Email',value:m.email),
        const FormLabel('Message'),Container(width:double.infinity,padding:const EdgeInsets.all(12),color:pageBackground,child:Text(m.message)),
        const SizedBox(height:14),const FormLabel('Admin Reply'),TextField(controller:c,maxLines:4,decoration:const InputDecoration(hintText:'Type your response...'))
      ])),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Close')),FilledButton.icon(onPressed:(){
        if(c.text.trim().isEmpty)return;setState(()=>m.status='Replied');logActivity('Replied to Help Center message',m.id);Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Reply recorded. Connect Firebase/email to deliver replies outside this prototype.')));
      },icon:const Icon(Icons.send_outlined),label:const Text('Send Reply'))]));
  }
}

