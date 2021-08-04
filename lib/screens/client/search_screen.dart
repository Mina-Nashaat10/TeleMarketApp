import 'package:flutter/material.dart';
import 'package:tele_market/models/product.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Product> products = [];
  List<Product> resultList = [];

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    products = ModalRoute.of(context).settings.arguments;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: buildSearchField(),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: resultList == null
            ? Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(right: 20, left: 20, top: 10),
                child: Text(
                  "No results for ${searchQueryController.text}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            : Container(
                margin: EdgeInsets.only(top: 10, left: 40),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, '/previewproduct',
                          arguments: resultList[index]),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 15),
                              width: 35,
                              height: 50,
                              decoration: new BoxDecoration(
                                image: DecorationImage(
                                  image:
                                      NetworkImage(resultList[index].imagePath),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                resultList[index].title,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: resultList.length,
                ),
              ),
      ),
    );
  }

  TextEditingController searchQueryController = TextEditingController();

  Widget buildSearchField() {
    return TextField(
      controller: searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search Data...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white54, fontSize: 19),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => searchQuery(query),
      cursorColor: Colors.white,
    );
  }

  void searchQuery(String query) {
    setState(() {
      resultList = [];
      if (query.isNotEmpty) {
        products.forEach((element) {
          if (query.toLowerCase().contains(element.title.toLowerCase()) ||
              element.title.toLowerCase().contains(query.toLowerCase())) {
            resultList.add(element);
          }
        });
        if (resultList.length == 0) resultList = null;
      }
    });
  }
}
