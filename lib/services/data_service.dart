import '../models/car_model.dart';
import '../models/service_item.dart';
import '../models/work_post.dart';
import '../utils/constants.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  List<CarModel> get sampleCars => [
    const CarModel(
      id: 'c1', brand: 'Maruti Suzuki', model: 'Swift', variant: 'VXi',
      year: 2019, fuelType: 'Petrol', plateNumber: 'GJ-05-AB-1234',
      currentKm: 52100, lastServiceKm: 42000, color: 'White',
      insuranceExpiry: '2026-03-15',
    ),
    const CarModel(
      id: 'c2', brand: 'Tata', model: 'Nexon EV', variant: 'XZ+',
      year: 2022, fuelType: 'Electric', plateNumber: 'GJ-01-ZZ-9988',
      currentKm: 18400, lastServiceKm: 10000, color: 'Blue',
      insuranceExpiry: '2026-11-20',
    ),
  ];

  List<ServiceItem> get services => [
    const ServiceItem(id: 's1', name: 'Oil Change', icon: '🛢️', priceRange: '₹800–₹1,500', duration: '45 min', category: 'Mechanical'),
    const ServiceItem(id: 's2', name: 'AC Service', icon: '❄️', priceRange: '₹1,500–₹3,000', duration: '2 hrs', category: 'AC'),
    const ServiceItem(id: 's3', name: 'Tyre Rotation', icon: '🛞', priceRange: '₹400–₹700', duration: '30 min', category: 'Tyres'),
    const ServiceItem(id: 's4', name: 'Car Wash', icon: '🚿', priceRange: '₹300–₹600', duration: '1 hr', category: 'Cleaning'),
    const ServiceItem(id: 's5', name: 'Brake Service', icon: '🛑', priceRange: '₹1,200–₹4,000', duration: '2–3 hrs', category: 'Mechanical'),
    const ServiceItem(id: 's6', name: 'Battery', icon: '🔋', priceRange: '₹500–₹6,000', duration: '30 min', category: 'Electrical'),
    const ServiceItem(id: 's7', name: 'Dent & Paint', icon: '🎨', priceRange: '₹2,000–₹15,000', duration: '1–3 days', category: 'Body'),
    const ServiceItem(id: 's8', name: 'Diagnostics', icon: '🔬', priceRange: '₹500–₹1,500', duration: '1 hr', category: 'Diagnostics'),
    const ServiceItem(id: 's9', name: 'Insurance', icon: '📋', priceRange: 'Free Assist', duration: 'Online', category: 'Documents'),
    const ServiceItem(id: 's10', name: 'Full Service', icon: '🔧', priceRange: '₹2,500–₹8,000', duration: '4–6 hrs', category: 'Mechanical'),
  ];

  List<WorkPost> get workPosts => [
    WorkPost(id: 'w1', title: 'Engine Oil Change + Filter', vehicle: 'Maruti Alto',
      postedBy: 'Sharma Motors', distanceKm: 1.8, amount: '₹1,200', time: 'Today, 3–5 PM',
      category: 'Mechanical', location: 'Navrangpura, Ahmedabad'),
    WorkPost(id: 'w2', title: 'Denting & Painting — Rear Bumper', vehicle: 'Toyota Fortuner',
      postedBy: 'Krishna Auto Works', distanceKm: 3.2, amount: '₹8,500', time: 'Tomorrow, 10 AM',
      category: 'Body Work', location: 'Satellite, Ahmedabad'),
    WorkPost(id: 'w3', title: 'AC Gas Refill + Leak Check', vehicle: 'Honda City',
      postedBy: 'Cool Car Service', distanceKm: 4.5, amount: '₹3,200', time: 'Today, 6 PM',
      category: 'AC Service', location: 'Bopal, Ahmedabad'),
    WorkPost(id: 'w4', title: 'Tyre Change — All 4 Tyres', vehicle: 'Hyundai i10',
      postedBy: 'Wheel Masters', distanceKm: 0.9, amount: '₹3,500', time: 'Today, 4 PM',
      category: 'Tyres', location: 'Prahlad Nagar, Ahmedabad'),
  ];
}