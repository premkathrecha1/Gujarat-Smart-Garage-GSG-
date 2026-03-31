class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  Future<String> getResponse(String query) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final lowerQuery = query.toLowerCase();
    
    if (lowerQuery.contains('oil') || lowerQuery.contains('swift')) {
      return '🛢️ For your Maruti Swift (Petrol), I recommend:\n\n• Castrol GTX 10W-40 Semi-Synthetic\n• Shell Helix HX5 10W-40\n• Mobil Super 3000 5W-40\n\n💰 Cost in Gujarat: ₹800–₹1,200 including labour\n\n⚠️ Since your gap is 10,100 km (over limit), please book immediately to avoid engine damage!';
    } else if (lowerQuery.contains('ev') || lowerQuery.contains('nexon') || lowerQuery.contains('electric')) {
      return '⚡ Tata Nexon EV Service Schedule:\n\n• Every 10,000 km: Brake fluid, coolant, cabin filter\n• Every 20,000 km: Battery health diagnostic\n• Every 40,000 km: Full suspension check\n\n✅ EVs need ~40% less maintenance than petrol cars!\n\n💰 Annual maintenance cost: ₹3,000–₹8,000 (vs ₹15,000+ for petrol)';
    } else if (lowerQuery.contains('knock') || lowerQuery.contains('sound') || lowerQuery.contains('noise')) {
      return '🔊 Engine knocking causes:\n\n1. Low octane fuel → Use 95+ octane\n2. Carbon deposits on pistons\n3. Ignition timing issue → ECU check needed\n4. Low engine oil → Check immediately!\n\n🚨 If constant knocking: Visit garage within 24 hours. Ignoring it can cause permanent engine damage worth ₹50,000+!';
    } else if (lowerQuery.contains('ac') || lowerQuery.contains('cool')) {
      return '❄️ AC not cooling diagnosis:\n\n1. Low refrigerant (gas leak) → Most common\n   Cost to regas: ₹1,200–₹2,500\n\n2. Dirty cabin air filter\n   Replace for: ₹300–₹600\n\n3. Compressor failure\n   Major repair: ₹8,000–₹25,000\n\n💡 Quick test: If AC works 5 mins then reduces → gas leak. Book today!';
    } else if (lowerQuery.contains('fuel') || lowerQuery.contains('mileage')) {
      return '⛽ Fuel efficiency tips for Gujarat roads:\n\n1. Tyre pressure: Check weekly (saves 3–5%)\n2. Air filter: Replace every 15,000 km\n3. Smooth driving: Avoid sudden braking\n4. Service on time: Tuned engine = 10–15% better FE\n5. Highway speed: 60–80 km/h is most efficient\n\n🚗 Average FE for Swift: 18–22 km/l (highway)';
    } else if (lowerQuery.contains('garage') || lowerQuery.contains('ahmedabad')) {
      return '📍 Top Garages in Ahmedabad:\n\n⭐⭐⭐⭐⭐ Patel Auto Service\n   Navrangpura · 1.2 km · Maruti specialist\n\n⭐⭐⭐⭐⭐ Krishna Auto Works\n   Satellite · 3.1 km · Multi-brand\n\n⭐⭐⭐⭐ Sharma Motors\n   Vastrapur · 2.4 km · Economy pricing\n\n✅ All have verified records on Smart Garage Gujarat!';
    } else {
      return '🔧 Great question! Based on your vehicles, here\'s what I know:\n\nYour Maruti Swift (petrol) and Tata Nexon EV both need different care approaches.\n\nCould you be more specific? For example:\n• What warning light did you see?\n• What sound/symptom are you noticing?\n• Which vehicle is giving trouble?\n\nI\'ll give you a precise answer! 🙏';
    }
  }
}