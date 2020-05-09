class ToDo{
  int id;
  String item;

  ToDo(this.id,this.item);

  Map<String, dynamic> toMap(){
    var map=<String, dynamic>{
      'id':id,
      'item':item,
    };
    return map;
  }

ToDo.fromMap(Map<String, dynamic> map){
  id=map['id'];
  item=map['item'];

}

}