import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;
class ChatScreen extends StatefulWidget {
  static const String id='chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
final messageTextController= TextEditingController();
  final _auth=FirebaseAuth.instance;

  late String message;
 late  String messageText;
  void getcurrentuser()async{
    try{
    final user=await _auth.currentUser;
  if(user!=null){
    loggedInUser=user;
    print('anything else maybe ');
    print(loggedInUser.email);
  }}
        catch(e){
      print(e);
        }
  }

  @override
  void initState() {
    // TODO: implement initState
    getcurrentuser();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {

                //Implement logout functionality
                _auth.signOut();
               Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessagesStream extends StatelessWidget {
  const MessagesStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      builder:(context,snapshot){
        List<MessageBubble> messagesBubbles=[];
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.yellow,
            ),
          );
        }
        if(snapshot.hasData){
          final messages=snapshot.data?.docs.reversed  ;

          for(var message in messages!){
            final messageText=message.data() as Map<String, dynamic>;
            var messageText2= messageText['text'];
            final messageSender= message.data() as Map<String, dynamic>;
            var messageSender2=messageSender['sender'];
            final currentUser=loggedInUser.email;
            if(currentUser==messageSender){

            }
            final messageBubble=MessageBubble(sender: messageSender2, text: messageText2 , isMe:currentUser==messageSender2 ,);
            messagesBubbles.add(messageBubble);
          }

        }
        return Expanded(
          child: ListView(
            reverse: false,
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
            children: messagesBubbles,
          ),
        );
      } ,
      stream: _firestore.collection('messages').snapshots(),
    );
  }
}


class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  const MessageBubble({Key? key, required this.sender, required this.text, required this.isMe}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: [
          Text(sender,style: TextStyle(
            fontSize: 12.0,
            color: Colors.white54
          ),),
          Material(
          borderRadius: isMe?BorderRadius.only(topLeft: Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight:Radius.circular(30.0) ):BorderRadius.only(topRight: Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight:Radius.circular(30.0) ),
          elevation: 5.0,
          color: isMe ? Colors.green: Colors.amber,
          child: Text('  $text  ',
              style: TextStyle(color: isMe ?Colors.white: Colors.black,
                fontSize: 15.0,)),
        ),],
      ),
    );
  }
}
