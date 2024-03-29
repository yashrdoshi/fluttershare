import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query){
    Future<QuerySnapshot> users = usersRef
    .where("displayName",isGreaterThanOrEqualTo: query)
    .getDocuments();

    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch(){
    searchController.clear();
  }


  AppBar buildSearchField(){
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a User...",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container buildNoContent(){
    final Orientation orientation = MediaQuery.of(context).orientation;
      return Container(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              SvgPicture.asset(
                'assets/images/search.svg',
                height: orientation == Orientation.portrait ?  250.0 : 150,
              ),
              Text(
                "Find Users",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  fontSize: 60.0,
                ),
              ),
            ],
          ),
        ),
      );
  }
  

  buildSearchResults(){
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context,snapshot){
        if(!snapshot.hasData){
          print("No Data");
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc){
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult); 
        });
        return ListView(
          children: searchResults,
        );
      },
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body: searchResultsFuture == null? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  
  final User user;

  UserResult(this.user);


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context,profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: user.photoUrl!= null ?CachedNetworkImageProvider(user.photoUrl) : null,
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.username,  //can't change user name
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
