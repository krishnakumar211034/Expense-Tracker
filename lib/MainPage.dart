import 'Users/new_users.dart';
import 'Users/user_list.dart';
import 'package:flutter/material.dart';
import 'Models/User.dart';
import 'Transactions/new_transaction.dart';
import 'Transactions/TransactionList.dart';
import 'Models/Transaction.dart';



class MainPage extends StatefulWidget {
  final String tripName;
  const MainPage(this.tripName, {super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double totalAmount = 0;
  int usersCount = 0;
  int transactionCount = 0;
  double divident = 0;
  List<Transaction> _transactionList = [];
  List<User> _userList = [];
  bool _showUsers = false;

  void _addTransaction(String userName,String note,int amount){
    setState((){
      transactionCount++;
      int index = -1;
      totalAmount+=amount;
      usersCount==0 ? divident = 0 : divident = totalAmount/usersCount;
      final Transaction transaction = Transaction(DateTime.now().millisecondsSinceEpoch.toString(),amount,note,userName,DateTime.now());
      for(int i = 0;i<usersCount;i++){
        if(_userList[i].userName.compareTo(userName) == 0) {
          index = i;
          break;
        }
      }
      _transactionList.insert(0,transaction);
      _userList[index].transaction.add(transaction);
      _userList[index].setPaid = (_userList[index].paid+transaction.amount);
      for(int i = 0;i<usersCount;i++){
        _userList[i].setBalance= (_userList[i].paid-divident);
      }
    });
  }
  void _addUser(String userName){
    setState((){
      usersCount++;
      divident = totalAmount/usersCount;
      bool _add = true;
      for (var element in _userList) {
        if(element.userName.compareTo(userName) == 0) {
          _add = false;
          break;
        }
      }
      final User user = User(DateTime.now().millisecondsSinceEpoch.toString(),0,0,userName,"resource");
      if(_add) _userList.insert(0,user);
      for(int i = 0;i<_userList.length;i++){
        _userList[i].setBalance= (_userList[i].paid-divident);
      }
    });
  }
  void _deleteTransaction(String id){
   setState((){
     int transactionIndex = -1,userIndex = -1;
     for(int i = 0;i<transactionCount;i++){
       if(_transactionList[i].id.compareTo(id) == 0) {
         transactionIndex = i;
         break;
       }
     }
     for(int i = 0;i<usersCount;i++){
       if(_userList[i].userName.compareTo(_transactionList[transactionIndex].userName) == 0) {
         userIndex = i;
         break;
       }
     }
     totalAmount -= _transactionList[transactionIndex].amount;
     divident = totalAmount/usersCount;
     int tempIndex = -1;
     _userList[userIndex].setPaid = (_userList[userIndex].paid - _transactionList[transactionIndex].amount);
     _userList[userIndex].transaction.removeWhere((element) => element.id == id);
     _transactionList.removeWhere((element) => element.id==id);
     for(int i = 0;i<usersCount;i++) {
       _userList[i].setBalance = (_userList[i].paid - divident);
     }
   });
  }  // this is the function called from UserList => UserUI

  @override
  Widget build(BuildContext context) {

    final appBar = AppBar(
        title: Text(widget.tripName),
        actions: [// this displays the Widgets at the Topright
          Container(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                (_showUsers)? const Text("hide users list") : const Text("show users list"),
                Switch(onChanged: (val){
                  setState(() {
                    _showUsers = val;
                  });
                },value: _showUsers),
                IconButton(
                  icon: const Icon(Icons.analytics,color: Colors.white),
                  onPressed: () {},
                ),
              ]
            ),
          ),
        ]);
    double appBarHeight = appBar.preferredSize.height;
    double systemPadding = MediaQuery.of(context).padding.top+MediaQuery.of(context).padding.bottom;
    double mainScreenHeight = MediaQuery.of(context).size.height-appBarHeight-systemPadding;
    var userHeader = SizedBox(
      height: mainScreenHeight*0.112,
      child: Card(
        elevation: 7.5,
        margin: const EdgeInsets.only(top: 10),
        child: Container(
          padding: const EdgeInsets.only(left: 20,right: 20,bottom: 5),
          child: ListTile(
              title: const Text("Users List",style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold),),// User List heading
              trailing: Ink(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: const CircleBorder(),
                  ),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        showModalBottomSheet(context: context,
                            isScrollControlled: true,
                            builder: ((builderContext){
                          return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: (){},
                              child: NewUser(_userList,_addUser));
                        }));
                      },
                      icon: const Icon(Icons.add),
                      color: Colors.white,
                      iconSize: 25,),
                  )
              ),
          )
        ),
      ),
    );
    var transactionHeader = SizedBox(
      height: mainScreenHeight*0.112,
      child: Card(
        elevation: 7.5,
        margin: const EdgeInsets.only(top: 10),
        child: Container(
          padding: const EdgeInsets.only(left: 20,right: 20,bottom: 10),
          child: ListTile(
            title: const Text("Transactions List",style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold),),
            trailing: Ink(
                width: 40,
                height: 40,
                decoration: ShapeDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: const CircleBorder(),
                ),
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      showModalBottomSheet(context: context,
                          isScrollControlled: true,
                          builder: ((builderContext){
                        return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: (){},
                            child: NewTransaction(_userList,_addTransaction));
                      }));
                    },
                    icon: const Icon(Icons.add),
                    color: Colors.white,
                    iconSize: 25,),
                )
            ),
          )
        ),
      ),
    );
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
          child: Column(
            children: [
              transactionHeader,
              SizedBox(
                height: _showUsers? (mainScreenHeight*0.348) : (mainScreenHeight*0.888),
                child: SingleChildScrollView(
                  child: TransactionList(_deleteTransaction,_transactionList),
                ),
              ),
              _showUsers? userHeader : const SizedBox(height: 0),
              _showUsers? SizedBox(
                height: mainScreenHeight*0.427,
                child: SingleChildScrollView(
                  child: UserList(_userList),
                ),
              ) : const SizedBox( height: 0,),
            ],
          ),
        )

        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        // floatingActionButton: FloatingActionButton(
        //   child: const Icon(Icons.add,),
        //   onPressed: (){
        //     showModalBottomSheet(context: context, builder: ((builderContext){
        //       return NewTransaction(_addTransaction,_userList);
        //     }));
        //   },
        // )
      ),
    );
  }
}

