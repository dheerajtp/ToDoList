import 'package:flutter/material.dart';
import 'todolist.dart';
import 'dart:async';
import 'dbhelper.dart';
void main(){
  runApp(ToDoList());
}

class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  Future<List<ToDo>> todovariable;
  TextEditingController controller = TextEditingController();
  String item;
  int curTodoId;

  final formKey = new GlobalKey<FormState>();
  var dbHelper;
  bool isUpdating;
  @override
  void initState(){
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
    refreshList();
  }

  refreshList(){
    setState(() {
      todovariable = dbHelper.gettodo();
    });  
  }

  clearTask(){
    controller.text = '';
  }
  validate(){
    if(formKey.currentState.validate()){
      formKey.currentState.save();
      if(isUpdating){
        ToDo t = ToDo(curTodoId, item);
        dbHelper.update(t);
        setState((){
          isUpdating = false;
        });
      }else{
        ToDo t = ToDo(null,item);
        dbHelper.save(t);
      }
      clearTask();
      refreshList();
    }
  }


  form(){
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            TextFormField(
              controller: controller,
              keyboardType:TextInputType.text,
              decoration:InputDecoration(labelText: 'TASK',
              ),
              validator: (val) => val.length ==0 ? 'Enter Your Item':null,
              onSaved: (val) => item=val,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  onPressed: validate , 
                  child: Text(isUpdating ? 'UPDATE':'ADD',
                  style:TextStyle(
                    fontFamily: 'Muli',
                  ),),
                  ),
                  FlatButton(
                  onPressed: (){
                    setState((){
                      isUpdating = false;
                    });
                    clearTask();
                  },
                  child: Text('CANCEL',
                  style:TextStyle(
                    fontFamily: 'Muli',
                  ),),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView dataTable(List<ToDo> todovariable){
    return SingleChildScrollView(
      scrollDirection:Axis.vertical,
      child:DataTable(
        columns:[
          DataColumn(
            label: Text('ITEM',
            style:TextStyle(
              fontFamily: 'Muli',
            ),), 
            ),
          DataColumn(
            label: Text('DELETE',
            style:TextStyle(
              fontFamily: 'Muli',
            ),
            ),
            ),
        ],
        rows:todovariable.map((todovariable) => DataRow(
          cells:[
            DataCell(
              Text(
                todovariable.item
                ),
                onTap:(){
                  setState((){
                    isUpdating=true;
                    curTodoId = todovariable.id; 
                  });
                  controller.text = todovariable.item;
                },
                ),
          DataCell(
            IconButton(
              icon:Icon(
                Icons.delete_outline),
                onPressed: (){
                  dbHelper.delete(todovariable.id);
                  refreshList();
                },
                ),
                )
                ,]
        ),).toList() ,
      ),
    );
  }

  list(){
    return Expanded(
      child:FutureBuilder(
        future: todovariable,
        builder:(context, snapshot){
          if(snapshot.hasData){
            return dataTable(snapshot.data);
          }
          if(null == snapshot.data || snapshot.data.length ==0){
            return Text("No Data Found");
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Scaffold(
        backgroundColor:Colors.white,
        appBar:AppBar(
          title:Text(
            "ToDo List",
            style:TextStyle(
              fontFamily: 'Poppins',
              fontWeight:FontWeight.bold,
              fontSize:20.0,
            ),
            ),
            backgroundColor: Colors.black,
            centerTitle: true,
            elevation: 0.0,
        ),
        body:Container(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              form(),
              list(),
            ],
          ),
        ),
      ), 
    );
  }
}