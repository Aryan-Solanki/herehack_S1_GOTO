import 'dart:math' show asin, cos, pow, sqrt;

class CalculateDistance{

  String calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    if ((12742 *1000* asin(sqrt(a))).round()>500){
      return roundDouble((12742 * asin(sqrt(a))), 2).toString()+" km away";
    }
    return (12742 *1000* asin(sqrt(a))).round().toString()+" m away";
  }

  double roundDouble(double value, int places){
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }


}


