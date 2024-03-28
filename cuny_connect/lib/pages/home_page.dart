import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'profile.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false, //turns debug corner on/off
//       theme: ThemeData(
//         primarySwatch: Colors.purple,
//         primaryColor: const Color.fromARGB(255, 63, 4, 73),
//       ),
//       home: const HomePage(),
//     );
//   }
// }

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //this section is for the top purple bar and its icons
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            //Need to add code here to trigger a new text message
          },
          icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
        ),
        title:
            const Text('CUNY Connect', style: TextStyle(color: Colors.white)),
        actions: [
          //search icon
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            color: Colors.white,
          ),

          //profile icon
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 36.0, 8.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              icon: const Icon(Icons.person_outlined),
              color: Colors.white,
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: Theme.of(context)
            .primaryColor, // had to explicitly set background color
      ),
      //body: const ChatPage() is where we target our chats/ socket.io/firebase
      body: const ChatPage(),
      //the following chunk is for the bottom purple bar and its icons.
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Schedule",
          ),
        ],
      ),
    );
  }
}
