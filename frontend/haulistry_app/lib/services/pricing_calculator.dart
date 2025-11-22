/// Advanced Pricing Calculator for Heavy Machinery Services
/// 
/// Based on Pakistani market rates (2024-2025) for:
/// - Harvester: PKR 8,000-12,000 per hour (agricultural equipment)
/// - Sand Truck/Trolley: PKR 15,000-25,000 per trip (10-12 ton capacity)
/// - Brick Truck/Trolley: PKR 12,000-20,000 per trip (8-10 ton capacity)
/// - Crane: PKR 25,000-50,000 per day (depends on capacity)
/// - Distance: PKR 30-50 per km for fuel
/// - Operator: PKR 1,500-2,500 per day
/// 
/// Pricing factors:
/// - Equipment rental base rate
/// - Distance and fuel costs (Diesel: PKR 280-295/liter)
/// - Operator wages
/// - Service duration
/// - Trip vs hourly rates
/// - Market demand (peak/off-peak)

class PricingCalculator {
  // ========== EQUIPMENT BASE RATES (PKR) ==========
  
  // Hourly rates for agricultural/construction equipment
  static const Map<String, double> hourlyRates = {
    'harvester': 10000.0,        // PKR 8,000-12,000/hour
    'thresher': 8000.0,          // PKR 6,000-10,000/hour
    'tractor': 2500.0,           // PKR 2,000-3,000/hour
    'crane': 6000.0,             // PKR 4,000-8,000/hour (or day rate)
    'excavator': 7000.0,         // PKR 5,000-9,000/hour
    'bulldozer': 8000.0,         // PKR 6,000-10,000/hour
    'loader': 5000.0,            // PKR 4,000-6,000/hour
    'roller': 4500.0,            // PKR 3,500-5,500/hour
    'grader': 6000.0,            // PKR 5,000-7,000/hour
  };

  // Per-trip rates for transport vehicles (includes driver)
  static const Map<String, double> perTripRates = {
    'sand_truck': 20000.0,       // PKR 15,000-25,000/trip (10-12 ton)
    'brick_truck': 16000.0,      // PKR 12,000-20,000/trip (8-10 ton)
    'gravel_truck': 18000.0,     // PKR 13,000-23,000/trip
    'cement_truck': 25000.0,     // PKR 20,000-30,000/trip (mixer)
    'dumper': 15000.0,           // PKR 12,000-18,000/trip
    'truck_10_ton': 18000.0,     // PKR 15,000-22,000/trip
    'truck_20_ton': 30000.0,     // PKR 25,000-35,000/trip
  };

  // Daily rates for certain equipment (8-10 hours)
  static const Map<String, double> dailyRates = {
    'crane': 40000.0,            // PKR 25,000-50,000/day
    'generator': 8000.0,         // PKR 5,000-12,000/day
    'compressor': 6000.0,        // PKR 4,000-8,000/day
  };

  // ========== COST FACTORS ==========
  
  // Fuel consumption (liters per hour)
  static const Map<String, double> fuelConsumptionRates = {
    'harvester': 18.0,           // High consumption during harvest
    'thresher': 12.0,
    'tractor': 8.0,
    'sand_truck': 15.0,          // Per trip average
    'brick_truck': 12.0,
    'crane': 25.0,
    'excavator': 20.0,
    'bulldozer': 25.0,
    'loader': 15.0,
    'dumper': 12.0,
    'roller': 12.0,
    'grader': 18.0,
  };

  // Current diesel price in Pakistan (PKR per liter) - Feb 2025
  static double dieselPricePerLiter = 287.0;  // Updated regularly

  // Operator/driver daily wage (PKR) - included in hourly equipment for trucks
  static const Map<String, double> operatorDailyWage = {
    'skilled_operator': 2000.0,   // Crane, excavator operators
    'driver': 1500.0,             // Truck drivers (often included)
    'helper': 1000.0,             // Assistant/labor
  };

  // Distance-based transport cost (PKR per km)
  static double transportCostPerKm = 40.0;  // Fuel + wear & tear


  // ========== PRICING CALCULATION METHODS ==========

  /// Calculate service price based on equipment type and usage pattern
  /// 
  /// For TRUCKS (sand, brick): Calculate per trip + distance
  /// For HOURLY equipment (harvester, crane): Calculate per hour + distance
  /// For DAILY equipment: Calculate per day + distance
  static PriceBreakdown calculateServicePrice({
    required String serviceType,
    required double distanceKm,
    required double durationHours,
    int numberOfTrips = 1,              // For truck services
    bool isHourlyRate = true,           // false for per-trip or daily
    bool includeFuel = true,
    bool includeOperator = true,
    bool includeTransport = true,
    double demandMultiplier = 1.0,      // 1.0 = normal, 1.2 = peak season
  }) {
    final normalizedType = serviceType.toLowerCase().replaceAll(' ', '_');
    
    double equipmentCost = 0.0;
    double fuelCost = 0.0;
    double operatorCost = 0.0;
    double transportCost = 0.0;
    double effectiveHours = durationHours;

    // ========== TRUCK SERVICES (Per Trip) ==========
    if (perTripRates.containsKey(normalizedType)) {
      // Base trip rate
      equipmentCost = perTripRates[normalizedType]! * numberOfTrips;
      
      // Fuel cost per trip (already factored into trip rate, but add extra for long distance)
      if (includeFuel && distanceKm > 50) {
        // Extra fuel beyond normal 50km trip
        final extraKm = distanceKm - 50;
        final fuelConsumption = fuelConsumptionRates[normalizedType] ?? 12.0;
        fuelCost = (extraKm * fuelConsumption / 10) * dieselPricePerLiter * numberOfTrips;
      }
      
      // Operator (driver) cost usually included in trip rate
      operatorCost = 0.0; // Already in base rate
      
      // Transport cost (for mobilization/demobilization if far)
      if (includeTransport && distanceKm > 100) {
        transportCost = (distanceKm - 100) * 20; // PKR 20/km beyond 100km
      }
      
      effectiveHours = numberOfTrips * 4; // Estimate 4 hours per trip
    }
    // ========== DAILY RATE EQUIPMENT (Crane, etc.) ==========
    else if (dailyRates.containsKey(normalizedType)) {
      final days = (durationHours / 8).ceil(); // Round up to full days
      effectiveHours = days * 8.0;
      
      // Base daily rate
      equipmentCost = dailyRates[normalizedType]! * days;
      
      // Fuel cost
      if (includeFuel) {
        final fuelConsumption = fuelConsumptionRates[normalizedType] ?? 15.0;
        fuelCost = fuelConsumption * effectiveHours * dieselPricePerLiter;
      }
      
      // Operator cost
      if (includeOperator) {
        operatorCost = operatorDailyWage['skilled_operator']! * days;
      }
      
      // Transportation cost (mobilization)
      if (includeTransport && distanceKm > 0) {
        transportCost = distanceKm * transportCostPerKm;
      }
    }
    // ========== HOURLY RATE EQUIPMENT (Harvester, Excavator, etc.) ==========
    else {
      // Minimum 4-hour booking
      if (effectiveHours < 4) effectiveHours = 4.0;
      
      // Base hourly rate
      final hourlyRate = hourlyRates[normalizedType] ?? 5000.0;
      equipmentCost = hourlyRate * effectiveHours;
      
      // Fuel cost
      if (includeFuel) {
        final fuelConsumption = fuelConsumptionRates[normalizedType] ?? 12.0;
        fuelCost = fuelConsumption * effectiveHours * dieselPricePerLiter;
      }
      
      // Operator cost
      if (includeOperator) {
        final days = (effectiveHours / 8).ceil();
        operatorCost = operatorDailyWage['skilled_operator']! * days;
      }
      
      // Transportation cost
      if (includeTransport && distanceKm > 0) {
        transportCost = distanceKm * transportCostPerKm;
      }
    }

    // ========== APPLY ADJUSTMENTS ==========
    
    // Duration discount (for multi-day bookings)
    final durationDiscount = _calculateDurationDiscount(effectiveHours);
    
    // Subtotal before discounts
    final subtotal = equipmentCost + fuelCost + operatorCost + transportCost;
    
    // Apply duration discount
    final afterDiscount = subtotal * (1 - durationDiscount);
    
    // Apply demand multiplier (peak season, rush booking, etc.)
    final total = afterDiscount * demandMultiplier;

    // Calculate derivatives
    final pricePerHour = effectiveHours > 0 ? total / effectiveHours : total;
    final pricePerDay = effectiveHours > 0 ? total / (effectiveHours / 8.0) : total;

    return PriceBreakdown(
      equipmentCost: equipmentCost,
      fuelCost: fuelCost,
      operatorCost: operatorCost,
      transportCost: transportCost,
      subtotal: subtotal,
      durationDiscount: subtotal * durationDiscount,
      discountPercentage: durationDiscount * 100,
      demandMultiplier: demandMultiplier,
      total: total,
      pricePerHour: pricePerHour,
      pricePerDay: pricePerDay,
      hours: effectiveHours,
      distanceKm: distanceKm,
    );
  }

  /// Calculate discount based on booking duration
  /// Multi-day bookings get progressive discounts
  static double _calculateDurationDiscount(double hours) {
    if (hours >= 240) return 0.25;  // 30+ days: 25% discount
    if (hours >= 168) return 0.20;  // 21+ days: 20% discount
    if (hours >= 120) return 0.15;  // 15+ days: 15% discount
    if (hours >= 72) return 0.10;   // 9+ days: 10% discount
    if (hours >= 40) return 0.05;   // 5+ days: 5% discount
    return 0.0;                      // Less than 5 days: no discount
  }

  /// Calculate price per agricultural service (per acre)
  static double calculatePerAcrePrice({
    required String serviceType,
    required double acres,
    required double distanceKm,
  }) {
    // Agricultural service rates in Pakistan (PKR per acre)
    final Map<String, double> perAcreRates = {
      'harvesting': 8000.0,     // Combine harvester: PKR 7,000-10,000/acre
      'plowing': 4000.0,        // Tractor plowing: PKR 3,000-5,000/acre
      'cultivation': 3500.0,    // Cultivator: PKR 3,000-4,000/acre
      'leveling': 5000.0,       // Land leveling: PKR 4,000-6,000/acre
      'sowing': 3000.0,         // Seed drill: PKR 2,500-3,500/acre
      'threshing': 6000.0,      // Thresher: PKR 5,000-7,000/acre
    };

    final ratePerAcre = perAcreRates[serviceType.toLowerCase()] ?? 5000.0;
    final baseCost = ratePerAcre * acres;
    
    // Add transport cost if distance > 20km
    double transportCost = 0.0;
    if (distanceKm > 20) {
      transportCost = (distanceKm - 20) * transportCostPerKm;
    }

    return baseCost + transportCost;
  }

  /// Calculate price range (min, recommended, max) for service estimation
  /// Used in UI to show pricing options before provider sets final price
  static Map<String, double> getSuggestedPriceRange({
    required String serviceType,
    required double durationHours,
    required double distanceKm,
  }) {
    final basePricing = calculateServicePrice(
      serviceType: serviceType,
      distanceKm: distanceKm,
      durationHours: durationHours,
    );

    // Create pricing tiers for provider to choose from
    // Minimum: Cost price (break-even)
    final minPrice = basePricing.subtotal * 0.95;  // 5% below to be competitive
    
    // Recommended: Cost + reasonable profit margin
    final recommendedPrice = basePricing.total;     // Calculated price
    
    // Maximum: Premium pricing for urgent/peak demand
    final maxPrice = basePricing.total * 1.20;      // 20% above for premium service

    return {
      'minimum': minPrice,
      'recommended': recommendedPrice,
      'maximum': maxPrice,
    };
  }

  /// Calculate demand multiplier based on market conditions
  static double calculateDemandMultiplier({
    required DateTime bookingDate,
    int activeBookingsCount = 0,
    bool isPeakSeason = false,
    bool isRushBooking = false,
  }) {
    double multiplier = 1.0;

    // Weekend premium (Friday-Sunday in Pakistan)
    final day = bookingDate.weekday;
    if (day == DateTime.friday || day == DateTime.saturday || day == DateTime.sunday) {
      multiplier += 0.10; // 10% weekend premium
    }

    // Peak season premium
    // Agriculture: April-May (wheat harvest), Oct-Nov (rice/cotton harvest)
    // Construction: Feb-May, Sep-Nov (optimal weather)
    if (isPeakSeason) {
      multiplier += 0.15; // 15% peak season premium
    }

    // Rush booking premium (less than 48 hours notice)
    if (isRushBooking) {
      multiplier += 0.20; // 20% rush booking premium
    }

    // High demand (equipment availability low)
    if (activeBookingsCount > 10) {
      multiplier += 0.10; // 10% high demand premium
    } else if (activeBookingsCount > 5) {
      multiplier += 0.05; // 5% moderate demand premium
    }

    return multiplier.clamp(1.0, 1.6); // Max 60% total premium
  }
}

// ========== DATA MODELS ==========

/// Detailed price breakdown for transparency
class PriceBreakdown {
  final double equipmentCost;      // Base equipment rental
  final double fuelCost;           // Diesel/fuel charges
  final double operatorCost;       // Driver/operator wages
  final double transportCost;      // Mobilization/transportation
  final double subtotal;           // Sum before discounts
  final double durationDiscount;   // Multi-day discount amount
  final double discountPercentage; // Discount percentage
  final double demandMultiplier;   // Market demand factor
  final double total;              // Final price
  final double pricePerHour;       // Hourly rate
  final double pricePerDay;        // Daily rate (8 hours)
  final double hours;              // Effective hours
  final double distanceKm;         // Distance in km

  PriceBreakdown({
    required this.equipmentCost,
    required this.fuelCost,
    required this.operatorCost,
    required this.transportCost,
    required this.subtotal,
    required this.durationDiscount,
    required this.discountPercentage,
    required this.demandMultiplier,
    required this.total,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.hours,
    required this.distanceKm,
  });

  Map<String, dynamic> toJson() => {
    'equipmentCost': equipmentCost.round(),
    'fuelCost': fuelCost.round(),
    'operatorCost': operatorCost.round(),
    'transportCost': transportCost.round(),
    'subtotal': subtotal.round(),
    'durationDiscount': durationDiscount.round(),
    'discountPercentage': discountPercentage.toStringAsFixed(1),
    'demandMultiplier': demandMultiplier.toStringAsFixed(2),
    'total': total.round(),
    'pricePerHour': pricePerHour.round(),
    'pricePerDay': pricePerDay.round(),
    'hours': hours.toStringAsFixed(1),
    'distanceKm': distanceKm.round(),
  };

  @override
  String toString() {
    return '''
Price Breakdown:
- Equipment: PKR ${equipmentCost.round().toStringAsFixed(0)}
- Fuel: PKR ${fuelCost.round().toStringAsFixed(0)}
- Operator: PKR ${operatorCost.round().toStringAsFixed(0)}
- Transport: PKR ${transportCost.round().toStringAsFixed(0)}
- Subtotal: PKR ${subtotal.round().toStringAsFixed(0)}
- Discount: PKR ${durationDiscount.round().toStringAsFixed(0)} (${discountPercentage.toStringAsFixed(1)}%)
- Total: PKR ${total.round().toStringAsFixed(0)}
- Per Hour: PKR ${pricePerHour.round().toStringAsFixed(0)}
- Per Day: PKR ${pricePerDay.round().toStringAsFixed(0)}
''';
  }
}
