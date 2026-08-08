import Foundation

func getCategory(_ categoryId: String, _ config: PricingConfig) -> Category? {
    config.categories.first { $0.id == categoryId }
}

func getGeneration(_ generationId: String, _ config: PricingConfig) -> DeviceGeneration? {
    config.deviceGenerations.first { $0.id == generationId }
}

func getVariantModifier(_ categoryId: String, _ variantId: String, _ config: PricingConfig) -> Double {
    config.variantRules.first { $0.categoryId == categoryId && $0.id == variantId }?.modifier ?? 0
}

func getFamilyMultiplier(_ categoryId: String, _ familyId: String?, _ config: PricingConfig) -> Double {
    guard let familyId else { return 1 }
    return (config.familyRules ?? []).first { $0.categoryId == categoryId && $0.id == familyId }?.multiplier ?? 1
}

func getTierMultiplier(_ categoryId: String, _ tierId: String?, _ config: PricingConfig) -> Double {
    guard let tierId else { return 1 }
    return (config.tierRules ?? []).first { $0.categoryId == categoryId && $0.id == tierId }?.multiplier ?? 1
}

func calculateBaseGenerationValue(_ category: Category, _ generation: DeviceGeneration) -> Double {
    switch category.baseCurveType ?? .manual {
    case .manual:
        return generation.baseGenerationValue
    case .iphoneExponential:
        let base = category.referenceBaseValue ?? generation.baseGenerationValue
        let decayRate = category.generationDecayRate ?? 0
        let x = generation.curveX ?? 0
        return base * exp(-decayRate * x)
    case .macBookProPolynomial:
        let x = generation.curveX ?? 0
        let polynomialValue = 25 * pow(x, 4) - 300 * pow(x, 3) + 1225 * pow(x, 2) - 2150 * x + 3000
        return max(0, polynomialValue)
    }
}

func getStorageModifier(_ categoryId: String, _ storageGb: Int, _ config: PricingConfig) -> Double {
    config.storageRules.first { $0.categoryId == categoryId && $0.storageGb == storageGb }?.modifier ?? 0
}

func getConditionModifier(_ categoryId: String, _ conditionId: String, _ config: PricingConfig) -> Double {
    config.conditionRules.first { $0.categoryId == categoryId && $0.id == conditionId }?.modifier ?? 0
}

func getRepairPenaltyTotal(_ categoryId: String, _ repairIds: [String], _ rawValue: Double, _ config: PricingConfig) -> (beforeCap: Double, afterCap: Double, wasCapped: Bool) {
    guard let category = getCategory(categoryId, config) else { return (0, 0, false) }
    let beforeCap = config.repairRules
        .filter { $0.categoryId == categoryId && repairIds.contains($0.id) }
        .reduce(0) { $0 + $1.penalty }
    let cap = max(0, rawValue) * category.repairPenaltyCapPercent
    let afterCap = min(beforeCap, cap)
    return (beforeCap, afterCap, beforeCap > afterCap)
}

func getAccessoryModifierTotal(_ categoryId: String, _ accessoryIds: [String], _ config: PricingConfig) -> Double {
    config.accessoryRules
        .filter { $0.categoryId == categoryId && accessoryIds.contains($0.id) }
        .reduce(0) { $0 + $1.modifier }
}

func getAgeClass(_ categoryId: String, _ releaseYear: Int, _ currentDate: String, _ config: PricingConfig) -> AgeClass? {
    let releaseDate = "\(releaseYear)-09-01"
    let ageMonths = monthsBetween(releaseDate, currentDate)
    return config.ageClasses
        .filter { $0.categoryId == categoryId }
        .first { ageMonths >= $0.minMonths && ($0.maxMonths == nil || ageMonths < ($0.maxMonths ?? Int.max)) }
}

func getBatteryModifier(_ categoryId: String, _ batteryHealth: Double?, _ config: PricingConfig) -> Double {
    guard let batteryHealth else { return 0 }
    let points = config.batteryCurvePoints.filter { $0.categoryId == categoryId }
    return interpolateCurve(points: points, x: batteryHealth)
}

func getBatteryExpectationModifier(_ categoryId: String, _ ageClass: AgeClassName?, _ batteryHealth: Double?, _ config: PricingConfig) -> Double {
    guard
        let ageClass,
        let batteryHealth,
        let rule = config.batteryExpectationRules.first(where: { $0.categoryId == categoryId && $0.ageClass == ageClass })
    else { return 0 }

    if batteryHealth < rule.expectedBatteryHealth {
        return -1 * (rule.expectedBatteryHealth - batteryHealth) * rule.penaltyPerPercentBelowExpected
    }

    let reward = batteryHealth - rule.expectedBatteryHealth
    return min(reward, rule.maxPositiveReward)
}

func calculateTimeMultiplier(_ category: Category, _ globalReferenceDate: String, _ currentDate: String) -> Double {
    let months = Double(monthsBetween(globalReferenceDate, currentDate))
    switch category.timeCurveType {
    case .none:
        return 1
    case .linear:
        return max(category.minimumTimeMultiplier, 1 - category.monthlyDecayRate * months)
    case .exponential:
        return max(category.minimumTimeMultiplier, exp(-category.monthlyDecayRate * months))
    }
}

func interpolateCurve(points: [BatteryCurvePoint], x: Double) -> Double {
    let sorted = points.sorted { $0.batteryHealth < $1.batteryHealth }
    guard let first = sorted.first, let last = sorted.last else { return 0 }

    if x <= first.batteryHealth { return first.modifier }
    if x >= last.batteryHealth { return last.modifier }

    for index in 0..<(sorted.count - 1) {
        let lower = sorted[index]
        let upper = sorted[index + 1]
        guard x >= lower.batteryHealth && x <= upper.batteryHealth else { continue }

        let ratio = (x - lower.batteryHealth) / (upper.batteryHealth - lower.batteryHealth)
        return lower.modifier + ratio * (upper.modifier - lower.modifier)
    }

    return 0
}

func clamp(_ value: Double, _ minValue: Double, _ maxValue: Double?) -> Double {
    let upperClamped = maxValue.map { min(value, $0) } ?? value
    return max(minValue, upperClamped)
}

func monthsBetween(_ dateA: String, _ dateB: String) -> Int {
    guard let start = Date.isoDateFormatter.date(from: dateA), let end = Date.isoDateFormatter.date(from: dateB) else {
        return 0
    }

    let components = Calendar.current.dateComponents([.month], from: start, to: end)
    return max(0, components.month ?? 0)
}

extension Date {
    static let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

extension Double {
    var currencyText: String {
        Self.currencyFormatter.string(from: NSNumber(value: self)) ?? "$\(Int(self.rounded()))"
    }

    var signedCurrencyText: String {
        let sign = self >= 0 ? "+" : "-"
        return "\(sign)\(abs(self).currencyText)"
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}
