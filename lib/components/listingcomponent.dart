import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class ListingComponent extends StatefulWidget {
  final String Title;
  final String Dist;
  final bool ishome;

  const ListingComponent({Key? key,required this.Title,required this.Dist, this.ishome=true}) : super(key: key);

  @override
  _ListingComponentState createState() => _ListingComponentState();
}

Random random = new Random();

class _ListingComponentState extends State<ListingComponent> {

  var stars=random.nextDouble()*1.5+3.5;
  var reviews=random.nextInt(100)+30;
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: widget.ishome?MainAxisAlignment.start:MainAxisAlignment.center,
            crossAxisAlignment: widget.ishome?CrossAxisAlignment.start:CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    width: 1,
                    color: Colors.white,  // red as border color
                  ),),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cmVzdGF1cmFudHxlbnwwfHwwfHw%3D&w=1000&q=80",height: 80,width: 80,fit: BoxFit.cover,),
                ),
              ),
              SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: widget.ishome?MainAxisAlignment.start:MainAxisAlignment.center,
                children: [
                  Container(
                    width: widget.ishome?MediaQuery.of(context).size.width-150:MediaQuery.of(context).size.width-150-55,
                    child: Text(widget.Title,maxLines: 1,overflow: TextOverflow.ellipsis,style: GoogleFonts.openSans(
                      textStyle: TextStyle(fontWeight: FontWeight.w700,fontSize: 20,color: widget.ishome?Colors.white:Colors.black),
                    ),),
                  ),
                  SizedBox(height: 2,),
                  Row(
                    children: [
                      Text(stars.toStringAsFixed(1),style: GoogleFonts.openSans(
                        textStyle: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: widget.ishome?Colors.white:Colors.black),
                      ),),
                      SizedBox(width: 8,),
                      RatingBarIndicator(
                        rating: stars,
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 18.0,
                        direction: Axis.horizontal,
                      ),
                      SizedBox(width: 8,),
                      Text("($reviews)",style: GoogleFonts.openSans(
                        textStyle: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: widget.ishome?Colors.white:Colors.black,letterSpacing: 1.4),
                      ),),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    children: [
                      Text("${widget.Dist}",style: GoogleFonts.openSans(
                        textStyle: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: widget.ishome?Colors.white:Colors.black),
                      ),),
                      SizedBox(width: 15,),
                      Text("Open 24 hours",style: GoogleFonts.openSans(
                        textStyle: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: widget.ishome?Colors.white:Colors.black),
                      ),),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        widget.ishome?SizedBox(height: 13,):SizedBox(),
        widget.ishome?Divider(
            thickness: 0.3,
            color: Colors.white
        ):SizedBox()
      ],
    );
  }
}
