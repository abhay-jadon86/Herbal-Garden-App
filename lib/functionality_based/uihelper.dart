import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class uiHelper {
  customIcomButton(IconData icondata, VoidCallback voidcallback){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          color: Color(0x33FFFFFF),
          shape: BoxShape.circle
        ),
        child: IconButton(onPressed: voidcallback,
            icon: Icon(icondata,
            size: 20,
            color: Colors.white,)),
      ),
    );
  }

  customCardButton(String text , VoidCallback voidcallback, double hei, double? wid, Color color, double textsize){
    return GestureDetector(
      onTap: voidcallback,
      child: Container(
        height: hei,
        width: wid,
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          )],
          color: color,
          borderRadius: BorderRadius.circular(15)
        ),
        child: Center(
          child: Text(text,
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: textsize
            ),),
        ),
      ),

    );

  }

  customHerbContainer( String text , String subtext, String imageurl){
    return Container(
      height: 280,
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(
          color: Color(0x33000000),
          blurRadius: 15,
          offset: Offset(0, 8)
        )],
           gradient: LinearGradient(colors: [Color(0x1AFFFFFF), Color(0x33FFFFFF)],
        stops: [0,1],
        begin: AlignmentDirectional(0, -1),
        end: AlignmentDirectional(0, 1)
        ),
          ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsetsDirectional.fromSTEB(0.0,20.0,20.0,0.0),
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(imageurl,
                fit: BoxFit.cover,),
              ),),
            SizedBox(height: 8,),
            Text(text, style:
              GoogleFonts.interTight(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white
              ),),
            Text(subtext, style:
              GoogleFonts.interTight(
                fontSize: 15,
                color: Colors.white
              ),),
            SizedBox(height: 8,),
            Row(
              children: [
                Icon(Icons.eco,color: Colors.green,size: 25,),
                SizedBox(width: 10,),
                Icon(Icons.volume_up, size: 25, color: Color(0xFF4169E1),),
                SizedBox(width: 60,),
                Icon(Icons.bookmark_border, size: 25, color: Color(0xFFFF6347),)

              ],
            ),

          ],

        ),
      ),
    );
  }
}