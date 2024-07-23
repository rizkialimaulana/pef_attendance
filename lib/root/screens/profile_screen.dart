import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Profile'),
      //   backgroundColor: Colors.orangeAccent,
      // ),
      body: Container(
        padding: EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 50),
        color: Colors.yellow[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/profile_picture.png'), // Ganti dengan path gambar profil Anda
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Nama Pengguna",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "user@example.com",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 10),
                Text(
                  "NIK",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    "1234567890",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.phone),
                SizedBox(width: 10),
                Text(
                  "Phone",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    "+62 8123456789",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Aksi saat tombol ditekan
              },
              icon: Icon(Icons.settings),
              label: Text("Settings"),
              style: ElevatedButton.styleFrom(
                // primary: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
