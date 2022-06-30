

import 'package:flutter/material.dart';

class Config {
  static final String urlTeste = 'rtmp://qa-livecommerce.cliqx.com.br:1935/live/f8708d1e74294f56aadb6a36e7e38524';
  final String urlPlayer = 'https://qa-livecommerce.cliqx.com.br:19588/hls/f8708d1e74294f56aadb6a36e7e38524.m3u8';
  static final String finishUrlProd = 'https://livecommerce-pernambucanas.cliqx.com.br/livecommerce-backend/api/VisualContent/Finish/';
  static final String finishUrlHomolog = 'https://qa-livecommerce.cliqx.com.br/livecommerce-backend/api/VisualContent/Finish/';


  static const MaterialColor colorPri = MaterialColor(
    0xff1cc0de,
    <int, Color>{
      50: Color(0xFFe1f8fc),
      100: Color(0xFFb4edf6),
      200: Color(0xFF83e1f1),
      300: Color(0xFF53d4ea),
      400: Color(0xFF30cae4),
      500: Color(0xff1cc0de),
      600: Color(0xFF18b1ca),
      700: Color(0xFF139cb0),
      800: Color(0xFF0F8897),
      900: Color(0xFF06656B),
    },
  );
  static final Color colorSec = Color(0xff1c8dc1);

  static const MaterialColor colorBlack = MaterialColor(
    0xff000000,
    <int, Color>{
      50: Color(0xFFf5f5f5),
      100: Color(0xFFe9e9e9),
      200: Color(0xFFd9d9d9),
      300: Color(0xFFc4c4c4),
      400: Color(0xFF9d9d9d),
      500: Color(0xff7b7b7b),
      600: Color(0xFF555555),
      700: Color(0xFF434343),
      800: Color(0xFF262626),
      900: Color(0xff000000),
    },
  );
  //static final Color colorBlack = Color(0xff18272B);
  static final Color colorGrey = Color(0xff757575);
  static final Color colorSucess = Color(0xff45E973);
  static final Color colorErro = Color(0xffFA3535);
  static final Color colorInfo = Color(0xffFDFDFD);

}