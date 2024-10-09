import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:team_project2_pure_me/model/feed.dart';
import 'package:team_project2_pure_me/model/user.dart';
import 'package:team_project2_pure_me/vm/calc_handler.dart';
import 'package:http/http.dart' as http;

class ManageHandler extends CalcHandler {
  // List<User> searchedUserList = <User>[].obs;

  //appManage에서 쓸 리스트들
  var signInUserList = <int>[].obs;
  var madeFeedList = <int>[].obs;

  //searchManage에서 쓸 변수들
  /// 나오는 리스트
  var searchFeedList = <Feed>[].obs;
  String searchFeedWord = '';
  int? searchFeedIndex;
  
  // searchUser에서 쓸 변수들

  // 안드로이드를를 위한 URL
  String manageUrl = 'http://10.0.2.2:8000/manage';

  // ios를 위한 URL
  // String manageUrl = 'http://10.0.2.2:8000/manage';

  final CollectionReference _manageFeed =
    FirebaseFirestore.instance.collection('post');


  // SearchUser(String userEMail) async {
  //   /// userEMail을 통해 user를 검색, List로 반환할 수 있는 class
  //   /// searchUserList 에 List<User>를 넣을수 있도록
  //   ///
  // }

  fetchAppManage()async{
    await fetchUserAmount();
    await fetchFeedAmount();
  }




  fetchUserAmount() async {
    var url = Uri.parse("$manageUrl/userperday");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    print(result);

    signInUserList.value = [
      result[0]['count'], 
      result[1]['count'], 
      result[2]['count']
    ];
  }



  fetchFeedAmount()async{
    List tempList = [];
    
    String yesterday = DateTime.now()
    .subtract(Duration(days: 1))    
    .toString().substring(0, 19).replaceFirst(' ', 'T');

    String lastweek = DateTime.now()
    .subtract(Duration(days: 7))    
    .toString().substring(0, 19).replaceFirst(' ', 'T');

    String lastmonth = DateTime.now()
    .subtract(Duration(days: 30))    
    .toString().substring(0, 19).replaceFirst(' ', 'T');

    // 더미데이터
    // Timestamp yesterday = Timestamp.fromDate(DateTime.now()
    // .subtract(Duration(days: 1))
    // );
    // Timestamp lastweek = Timestamp.fromDate(DateTime.now()
    // .subtract(Duration(days: 7))
    // );
    // Timestamp lastmonth = Timestamp.fromDate(DateTime.now()
    // .subtract(Duration(days: 30))
    // );


    dynamic yesterdaysnp =  await _manageFeed
        .where('state', isEqualTo: '게시')
        .where('writetime', isGreaterThan: yesterday)
        .get();
    tempList.add(yesterdaysnp.size);

    dynamic lastweeksnp =  await _manageFeed
        .where('state', isEqualTo: '게시')
        .where('writetime', isGreaterThan: lastweek)
        .get();
    tempList.add(lastweeksnp.size);
    
    dynamic lastmonthsnp =  await _manageFeed
        .where('state', isEqualTo: '게시')
        .where('writetime', isGreaterThan: lastmonth)
        .get();
    tempList.add(lastmonthsnp.size);
    
    madeFeedList.value = [
      tempList[0],
      tempList[1],
      tempList[2],
    ];

  }



  test1()async{

  }



  test2()async{

    Timestamp timestamp = Timestamp.fromDate(DateTime.now()
    .subtract(Duration(days: 1))
    );
    FirebaseFirestore.instance.collection('post').add({
      'writer': 'pureme_id',
      'state': '테스트',
      'content': 'content',
      'testtime':
          timestamp,
      'reply': [],
      'image': 'image',
      'imagename': 'imageName',
    });
  }


//////FeedManage쪽에서 쓰는 함수들
  searchFeed(String searchFeedword)async{
    if (searchFeedword.isEmpty){
      _manageFeed
          .where('state', isEqualTo: '게시')
          .orderBy('writetime', descending: true)
          .snapshots()
          .listen(
        (event) {
          searchFeedList.value = event.docs
              .map(
                (doc) => Feed.fromMap(doc.data() as Map<String, dynamic>, doc.id),
              )
              .toList();
        },
      );
    }else{

    }
  }

  updateSearchFeedWord(String text){
    searchFeedWord = text;
    update();
  }

  changeFeedIndex(int index){
    if (index == searchFeedIndex){
      searchFeedIndex = null;
    } else{
      searchFeedIndex = index;
    }
    update();
  }








}//End
