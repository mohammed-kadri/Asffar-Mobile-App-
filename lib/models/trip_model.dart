class Trip {
  final String id;
  final String agencyId;
  final String destination;
  final int period;
  final int price;
  final DateTime departDate;
  final DateTime returnDate;
  final bool family;
  final int availablePlaces;
  final String hotelName;
  final List<String> places;
  final String description;
  final DateTime postedDate;
  final String mainImageUrl;
  final List<String> secondaryImageUrls;

  Trip({
    required this.id,
    required this.agencyId,
    required this.destination,
    required this.period,
    required this.price,
    required this.departDate,
    required this.returnDate,
    required this.family,
    required this.availablePlaces,
    required this.hotelName,
    required this.places,
    required this.description,
    required this.postedDate,
    required this.mainImageUrl,
    required this.secondaryImageUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'agencyId': agencyId,
      'destination': destination,
      'period': period,
      'price': price,
      'departDate': departDate,
      'returnDate': returnDate,
      'family': family,
      'availablePlaces': availablePlaces,
      'hotelName': hotelName,
      'places': places,
      'description': description,
      'postedDate': postedDate,
      'mainImageUrl': mainImageUrl,
      'secondaryImageUrls': secondaryImageUrls,
    };
  }
}