  class Service {
    final String id;
    final String agencyId;
    final String type;
    final String country;
    final int price;
    final DateTime postedDate;
    final String? visaType;
    final String description;
    final int? numberOfPeople;
    final String? destination;
    final DateTime? date;
    final String? mainImageUrl;
    final List<String>? secondaryImageUrls;

    Service({
      required this.id,
      required this.agencyId,
      required this.type,
      required this.country,
      required this.price,
      this.visaType,
      required this.postedDate,
      required this.description,
      this.numberOfPeople,
      this.destination,
      this.date,
      this.mainImageUrl,
      this.secondaryImageUrls,
    });

    Map<String, dynamic> toMap() {
      return {
        'id': id,
        'agencyId': agencyId,
        'type': type,
        'country': country,
        'price': price,
        'postedDate': postedDate,
        'visaType': visaType,
        'description': description,
        'numberOfPeople': numberOfPeople,
        'destination': destination,
        'date': date,
        'mainImageUrl': mainImageUrl,
        'secondaryImageUrls': secondaryImageUrls,
      };
    }
  }
