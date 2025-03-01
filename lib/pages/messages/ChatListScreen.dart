import 'package:flutter/material.dart';
import 'package:tradingapp/pages/services/constants/constants.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ChatItem> chats = [
      ChatItem("Kira Artemenko", "Sorry I’ll be late 😊 about 15 minutes",
          "8:45 AM", "assets/images/user.png", Icons.reply_sharp),
      ChatItem(
          "Sergey Levchenko",
          "You can check this out at heartbeat.ua webpage",
          "7:39 AM",
          "assets/images/user.png", Icons.reply_sharp),
      ChatItem("Foodies", "Crap! This is awesome😯 You should try it!",
          "6:10 AM", "assets/images/user.png", Icons.photo_size_select_actual_outlined),
      ChatItem("Dana Lozko", "Can you let me know your rates?", "1 day",
          "assets/images/user.png", Icons.visibility_outlined),
      ChatItem(
          "Chatter",
          "Safety is the state of being safe, the condition of being",
          "",
          "assets/images/user.png"),
      ChatItem("Oleg Vasil", "Call duration 2:45", "2 days",
          "assets/images/user.png", Icons.call),
      ChatItem(
          "Italy trip",
          "Okay, I’ve bought tickets for the Drum festival on Friday👌",
          "1 week",
          "assets/images/user.png", Icons.airplane_ticket_outlined),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              AppConstants.messagePage,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.edit,
                size: 26,
              ),
            )
          ]),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return ChatTile(chat: chats[index]);
        },
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final ChatItem chat;
  const ChatTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        
        
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(chat.imagePath),
        ),
        title: Text(chat.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text(chat.message, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(chat.time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (chat.icon != null)
                Icon(chat.icon, size: 18, color: Colors.grey),
            ],
          ),
        ),
        onTap: () {},
      ),
    );
  }
}

class ChatItem {
  final String name;
  final String message;
  final String time;
  final String imagePath;
  final IconData? icon;

  ChatItem(this.name, this.message, this.time, this.imagePath, [this.icon]);
}


// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:tradingapp/pages/services/constants/constants.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:encrypt/encrypt.dart' as enc;

// class ChatListScreen extends StatefulWidget {
//   const ChatListScreen({super.key});

//   @override
//   _ChatListScreenState createState() => _ChatListScreenState();
// }

// class _ChatListScreenState extends State<ChatListScreen> {
//   late IO.Socket socket;
//   List<ChatItem> onlineUsers = [];




//   final List<String> _messages = [];
//   late Socket socket;
//   final StreamController<Uint8List> _streamController = StreamController();
//   final key = enc.Key.fromUtf8('my 32 length key................');
//   final iv = enc.IV.fromLength(16);

//   @override
//   void initState() {
//     super.initState();
//     initializeSocket();






//   }
//   late String _isOnline= "";


  
//   void initializeSocket() {
//     // const host = "https://socket-server-production-4d79.up.railway.app/";
//     const host = "ws://localhost:8080/hello";

//     socket = io(host,OptionBuilder()
//         .setTransports(['websocket'])
//         .disableAutoConnect()
//         .enableReconnection()
//         // .setQuery({"a":"admin@gmail.com"})
//     .setAuth({
//       "userID":widget.email,
//       'receiverID':widget.receiverEmail
//     })
//         .build());

//     //SOCKET EVENTS
//     // --> listening for connection
//     socket.on('connect', (data) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connected to Server"),duration: Duration(milliseconds: 300),));
//     });

//     //listen for incoming messages from the Server.
//     socket.on('message', (data) {
//       setState(() {
//         _messages.add(data['message']);
//       });
//     });


//     socket.on('data', (data) {
//       Uint8List list = Uint8List.fromList(data['message']);

//       _streamController.add(list);

//     });

//     socket.on('connectionOK', (data) {
//       setState(() {
//         data['isOnline']?_isOnline="Online":_isOnline="Offline";
//       });
//     });

//     //listens when the client is disconnected from the Server
//     socket.on('disconnect', (data) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Disconnected from Server"),duration: Duration(milliseconds: 300),));
//     });

//   }



  

//   @override
//   void initState() {
//     super.initState();
//     connectToServer();
//   }

//  void connectToServer() async {
//   String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
//   print("THIS IS TOEKN $token");
  
//   if (token == null) {
//     print("Error: No Firebase token found!");
//     return;
//   }

//   socket = IO.io('http://192.168.1.8:3000', <String, dynamic>{
//     'transports': ['websocket'],
//     'autoConnect': false,
//     'auth': {'token': token} // Pass the token here directly
//   });
//   print("TRYING...");

//   socket.connect();

//   socket.onConnect((_) {
//     print('Connected to WebSocket');
//   });

//   socket.onConnectError((error) {
//     print('Connection Error: $error');
//   });

//   socket.onDisconnect((_) {
//     print('Disconnected from WebSocket');
//   });
// }


 
//  @override
//   void dispose() {
//     socket.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Text(
//             "Online Users",
//             style: const TextStyle(color: Colors.black, fontSize: 22),
//           ),
//         ),
//         centerTitle: false,
//       ),
//       body: onlineUsers.isEmpty
//           ? const Center(child: CircularProgressIndicator()) // Show loading while fetching users
//           : ListView.builder(
//               padding: const EdgeInsets.all(10),
//               itemCount: onlineUsers.length,
//               itemBuilder: (context, index) {
//                 return ChatTile(chat: onlineUsers[index]);
//               },
//             ),
//     );
//   }
// }

// class ChatTile extends StatelessWidget {
//   final ChatItem chat;
//   const ChatTile({super.key, required this.chat});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 3),
//       child: ListTile(
//         leading: CircleAvatar(
//           radius: 25,
//           backgroundImage: AssetImage(chat.imagePath),
//         ),
//         title: Text(chat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text(chat.message, maxLines: 2, overflow: TextOverflow.ellipsis),
//       ),
//     );
//   }
// }

// class ChatItem {
//   final String name;
//   final String message;
//   final String time;
//   final String imagePath;
//   final IconData? icon;

//   ChatItem(this.name, this.message, this.time, this.imagePath, [this.icon]);
// }
