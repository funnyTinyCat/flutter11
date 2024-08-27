import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_app/components/dialog_box.dart';
import 'package:to_do_app/components/todo_tile.dart';
import 'package:to_do_app/data/database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // reference the hive box
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

  @override
  void initState() {
    // if this is the first time ever opening the app, then create default data
    if (_myBox.get("TODOLIST") == null )  {

      db.createInitialData();
    } else {

      // there already exists data
      db.loadData();
    }


    super.initState();

  }

  // text controller
  final controller = TextEditingController();

  // list of todo tasks
  // List toDoList = [
  //   ["Make Tutoriall", false],
  //   ["Do Excercise", false],
  // ];

  // checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });

    db.updateDatabase();
  }

  // save new task
  void saveNewTask() {

    setState(() {
      db.toDoList.add(
        [controller.text, false]
      );
      
      controller.clear();
    });

    Navigator.of(context).pop();

    db.updateDatabase();
  }

  // create a new task
  void createNewTask() {

    showDialog(
      context: context, 
      builder: (context) {

        return DialogBox(
          controller: controller,
          onCancel: () {
             Navigator.of(context).pop();

             controller.clear();
          },
          onSave: saveNewTask,
        );
      }
    );
  }

  // delete task
  void deleteTask(int index) {

    setState(() {
      db.toDoList.removeAt(index);
    });

    db.updateDatabase();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: const Text("TO DO"),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add,),
      ),
      body: ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          return ToDoTile(
            taskName: db.toDoList[index][0], 
            taskCompleted: db.toDoList[index][1], 
            onChanged: (value) => checkBoxChanged(value, index),
            deleteFunction: (context) => deleteTask(index),
          );
        },

        // children: [ 
        //   ToDoTile(
        //     taskName: "Make Tutorial",
        //     taskCompleted: true,            onChanged: (p0) {},
        //   ),
        //   ToDoTile(
        //     taskName: "Do Excercise",
        //     taskCompleted: false, 
        //     onChanged: (p0) {},
        //   ),
        // ],
      ),
    );
  }
}