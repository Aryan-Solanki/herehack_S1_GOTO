import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:search_app/Pages/MapPage.dart';

class SearchBarButton extends StatefulWidget {
  const SearchBarButton({Key? key}) : super(key: key);

  @override
  _SearchBarButtonState createState() => _SearchBarButtonState();
}

class _SearchBarButtonState extends State<SearchBarButton> {


  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 15),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        elevation: 20.0,
        shadowColor: Colors.black,
        child: TextField(
          // focusNode: focusNode,
          autofocus: false,
          readOnly: true,
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MapPage()));
          },
          decoration: InputDecoration(
              focusColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              suffixIcon: Icon(Icons.location_pin,size: 30,color: Colors.black.withOpacity(0.7),),
              filled: true,
              hintStyle: GoogleFonts.openSans(
                textStyle: TextStyle(fontWeight: FontWeight.w600,fontSize: 17,color: Colors.black.withOpacity(0.7)),
              ),
              hintText: "Looking for something else ?",
              prefixIcon: Icon(Icons.search_outlined,size: 30,color: Colors.black.withOpacity(0.7),),
              fillColor: Colors.white),
        ),
      ),
    );
  }
}
