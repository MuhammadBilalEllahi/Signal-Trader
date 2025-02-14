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
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              AppConstants.messagePage,
              style: TextStyle(color: Colors.black, fontSize: 22),
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                child: Icon(
                  Icons.edit,
                  color: Colors.black,
                  size: 26,
                ),
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
