import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserModel {
  String id;
  String name;
  String imgUrl;

  UserModel({this.id = '', this.name = '', this.imgUrl = ''});

  //define == operator for use in duplicate removal
  @override
  bool operator ==(other) {
    if (other is! UserModel) {
      return false;
    }
    return (id == other.id && name == other.name && imgUrl == other.imgUrl);
  }
}

class UserService {
  static Future<List<UserModel>> getUsers() async {
    List<UserModel> output = [];
    Uri url = Uri.parse(
        'https://gist.githubusercontent.com/erni-ph-mobile-team/c5b401c4fad718da9038669250baff06/raw/7e390e8aa3f7da4c35b65b493fcbfea3da55eac9/test.json');
    var data = await http.get(url);

    if (data.statusCode == 200) {
      // print(data.body);
      dynamic j = jsonDecode(data.body);
      print('j is a ${j.runtimeType}');

      if (j is List) {
        j.forEach((element) {
          output.add(UserModel(
              id: element['id'],
              name: element['name'],
              imgUrl: element['imageUrl']));
        });
      }
    }
    return output;
  }
}

class UserListViewModel extends ChangeNotifier {
  List<UserModel> data = [];

  Future<void> fetchUsers() async {
    data = await UserService.getUsers();
    data = _removeDuplicates(data);
    notifyListeners();
  }

  List<UserModel> _removeDuplicates(List<UserModel> inList) {
    List<UserModel> outList = [];

    inList.forEach((element) {
      if (outList.contains(element) == false) outList.add(element);
    });

    return outList;
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Erni Assignment'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<UserModel> data = [];
  UserListViewModel listViewModel = UserListViewModel();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listViewModel.fetchUsers();

    listViewModel.addListener(() {
      setState(() {
        data = listViewModel.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Text('hello'),
          if (data.isNotEmpty)
            ...data.map((e) => Card(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8),
                    leading: Image.network(e.imgUrl),
                    title: Text(e.name),
                    trailing: Text(e.id),
                  ),
                )),
          if (data.isEmpty) CircularProgressIndicator()
        ],
      ),
    );
  }
}
