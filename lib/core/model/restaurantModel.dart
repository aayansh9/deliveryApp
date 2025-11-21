import 'package:equatable/equatable.dart';

class RestaurantModel extends Equatable {
  final String id;
  final String owner;
  final String name;
  final String description;
  final String address;
  final String phone;
  final List<String> cuisines;
  final String image;
  final String openingTime;
  final String closingTime;
  final bool isOpen;

  const RestaurantModel({
    required this.id,
    required this.owner,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.cuisines,
    required this.image,
    required this.openingTime,
    required this.closingTime,
    required this.isOpen,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['_id'] ?? json['id'] ?? '',
      owner: json['owner'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      cuisines: List<String>.from(json['cuisines'] ?? []),
      image: json['image'] ?? '',
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      isOpen: json['isOpen'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'owner': owner,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'cuisines': cuisines,
      'image': image,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'isOpen': isOpen,
    };
  }

  @override
  List<Object?> get props => [
        id,
        owner,
        name,
        description,
        address,
        phone,
        cuisines,
        image,
        openingTime,
        closingTime,
        isOpen,
      ];
}
