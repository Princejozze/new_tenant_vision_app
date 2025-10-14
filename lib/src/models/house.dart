class House {
  final String name;
  final String location;
  final String price;
  final String imageUrl;
  final String address;
  final int totalRooms;
  final int occupiedRooms;

  House({
    required this.name,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.address,
    required this.totalRooms,
    required this.occupiedRooms,
  });

  static List<House> get dummyData => [
        House(
          name: 'Modern Glass House',
          location: 'New York, USA',
          price: '\$2,500,000',
          imageUrl: 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?q=80&w=2940&auto=format&fit=crop',
          address: '123 Luxury Ave, New York, NY',
          totalRooms: 5,
          occupiedRooms: 3,
        ),
        House(
          name: 'Luxury Villa',
          location: 'Los Angeles, USA',
          price: '\$4,200,000',
          imageUrl: 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?q=80&w=2874&auto=format&fit=crop',
          address: '456 Grand View, Los Angeles, CA',
          totalRooms: 7,
          occupiedRooms: 6,
        ),
        House(
          name: 'Cozy Cottage',
          location: 'London, UK',
          price: '\$1,800,000',
          imageUrl: 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?q=80&w=2940&auto=format&fit=crop',
          address: '789 English Rose, London, UK',
          totalRooms: 4,
          occupiedRooms: 4,
        ),
        House(
          name: 'Beachfront Paradise',
          location: 'Malibu, USA',
          price: '\$7,500,000',
          imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=2940&auto=format&fit=crop',
          address: '101 Ocean Drive, Malibu, CA',
          totalRooms: 8,
          occupiedRooms: 2,
        ),
        House(
          name: 'Mountain Retreat',
          location: 'Aspen, USA',
          price: '\$3,100,000',
          imageUrl: 'https://images.unsplash.com/photo-1599809275671-b5942cabc7a2?q=80&w=2876&auto=format&fit=crop',
          address: '212 Snowy Peak, Aspen, CO',
          totalRooms: 6,
          occupiedRooms: 1,
        ),
         House(
          name: 'Urban Loft',
          location: 'Paris, France',
          price: '\$1,500,000',
          imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=2940&auto=format&fit=crop',
          address: '33 Rue de Art, Paris, France',
          totalRooms: 3,
          occupiedRooms: 3,
        ),
      ];
}
