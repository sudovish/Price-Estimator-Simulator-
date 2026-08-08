import Foundation

enum TimeCurveType: String, Codable, CaseIterable, Identifiable {
    case none
    case linear
    case exponential

    var id: String { rawValue }
}

enum BaseCurveType: String, Codable, CaseIterable, Identifiable {
    case manual
    case iphoneExponential
    case macBookProPolynomial

    var id: String { rawValue }
}

enum Severity: String, Codable, CaseIterable, Identifiable {
    case minor
    case moderate
    case major

    var id: String { rawValue }
}

enum AgeClassName: String, Codable, CaseIterable, Identifiable {
    case new
    case recent
    case middle
    case old
    case legacy

    var id: String { rawValue }
}

enum BreakdownLineType: String, Codable {
    case base
    case modifier
    case penalty
    case multiplier
    case result
}

struct PricingConfig: Codable, Equatable {
    var globalReferenceDate: String
    var categories: [Category]
    var deviceGenerations: [DeviceGeneration]
    var variantRules: [VariantRule]
    var storageRules: [StorageRule]
    var batteryCurvePoints: [BatteryCurvePoint]
    var batteryExpectationRules: [BatteryExpectationRule]
    var conditionRules: [ConditionRule]
    var repairRules: [RepairRule]
    var accessoryRules: [AccessoryRule]
    var ageClasses: [AgeClass]
    var familyRules: [FamilyRule]? = nil
    var tierRules: [TierRule]? = nil
}

struct Category: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var marketMultiplier: Double
    var timeCurveType: TimeCurveType
    var monthlyDecayRate: Double
    var minimumTimeMultiplier: Double
    var floorValue: Double
    var ceilingValue: Double?
    var defaultTargetProfit: Double
    var minimumBuyOffer: Double
    var repairPenaltyCapPercent: Double
    var baseCurveType: BaseCurveType? = nil
    var referenceBaseValue: Double? = nil
    var generationDecayRate: Double? = nil
}

struct DeviceGeneration: Codable, Identifiable, Equatable {
    var id: String
    var categoryId: String
    var name: String
    var releaseYear: Int
    var baseGenerationValue: Double
    var curveX: Double? = nil
}

struct VariantRule: Codable, Identifiable, Equatable {
    var id: String
    var categoryId: String
    var name: String
    var modifier: Double
}

struct FamilyRule: Codable, Identifiable, Equatable {
    var id: String
    var categoryId: String
    var name: String
    var multiplier: Double
}

struct TierRule: Codable, Identifiable, Equatable {
    var id: String
    var categoryId: String
    var name: String
    var multiplier: Double
}

struct StorageRule: Codable, Identifiable, Equatable {
    var id: String
    var categoryId: String
    var storageGb: Int
    var modifier: Double
}

struct BatteryCurvePoint: Codable, Identifiable, Equatable {
    var categoryId: String
    var batteryHealth: Double
    var modifier: Double

    var id: String { "\(categoryId)-\(batteryHealth)" }
}

struct BatteryExpectationRule: Codable, Identifiable, Equatable {
    var categoryId: String
    var ageClass: AgeClassName
    var expectedBatteryHealth: Double
    var penaltyPerPercentBelowExpected: Double
    var maxPositiveReward: Double

    var id: String { "\(categoryId)-\(ageClass.rawValue)" }
}

struct ConditionRule: Codable, Identifiable, Equatable {
    var id: String
    var categoryId: String
    var name: String
    var modifier: Double
}

struct RepairRule: Codable, Identifiable, Equatable {
    var id: String
    var categoryId: String
    var name: String
    var penalty: Double
    var severity: Severity
}

struct AccessoryRule: Codable, Identifiable, Equatable {
    var id: String
    var categoryId: String
    var name: String
    var modifier: Double
}

struct AgeClass: Codable, Identifiable, Equatable {
    var id: String
    var categoryId: String
    var name: AgeClassName
    var minMonths: Int
    var maxMonths: Int?
}

struct EstimateInput: Codable, Equatable {
    var categoryId: String
    var generationId: String
    var familyId: String? = nil
    var tierId: String? = nil
    var variantId: String
    var storageGb: Int
    var batteryHealth: Double?
    var conditionId: String
    var repairIds: [String]
    var accessoryIds: [String]
    var currentDate: String
    var targetProfit: Double?
    var interestPremium: Double?
}

struct EstimateResult: Equatable {
    var baseGenerationValue: Double
    var variantModifier: Double
    var storageModifier: Double
    var batteryModifier: Double
    var batteryExpectationModifier: Double
    var conditionModifier: Double
    var repairPenaltyTotalBeforeCap: Double
    var repairPenaltyTotal: Double
    var accessoryModifierTotal: Double
    var rawValueBeforeSafeguards: Double
    var rawValue: Double
    var marketMultiplier: Double
    var timeMultiplier: Double
    var expectedResaleValueBeforeClamp: Double
    var expectedResaleValue: Double
    var targetProfit: Double
    var interestPremium: Double
    var recommendedBuyOfferBeforeClamp: Double
    var recommendedBuyOffer: Double
    var ageClass: String
    var monthsSinceReference: Int
    var warnings: [String]
    var breakdown: [BreakdownLine]
}

struct BreakdownLine: Identifiable, Equatable {
    let id = UUID()
    var label: String
    var amount: Double
    var type: BreakdownLineType
    var note: String?
}
