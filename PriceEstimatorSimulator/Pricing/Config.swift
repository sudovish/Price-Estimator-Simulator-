import Foundation

enum SeedPricingConfig {
    static let config = PricingConfig(
        globalReferenceDate: "2026-01-01",
        categories: [
            Category(
                id: "iphone",
                name: "iPhone",
                marketMultiplier: 1.0,
                timeCurveType: .none,
                monthlyDecayRate: 0.008,
                minimumTimeMultiplier: 0.75,
                floorValue: 20,
                ceilingValue: 2000,
                defaultTargetProfit: 150,
                minimumBuyOffer: 15,
                repairPenaltyCapPercent: 0.45
            ),
            Category(
                id: "macbook",
                name: "MacBook",
                marketMultiplier: 1.0,
                timeCurveType: .none,
                monthlyDecayRate: 0,
                minimumTimeMultiplier: 0.70,
                floorValue: 75,
                ceilingValue: 4000,
                defaultTargetProfit: 250,
                minimumBuyOffer: 50,
                repairPenaltyCapPercent: 0.50,
                baseCurveType: .macBookProPolynomial,
                referenceBaseValue: nil,
                generationDecayRate: nil
            )
        ],
        deviceGenerations: [
            DeviceGeneration(id: "iphone_5s_7_series", categoryId: "iphone", name: "iPhone 5s to iPhone 7 Series", releaseYear: 2016, baseGenerationValue: 18),
            DeviceGeneration(id: "iphone_8_series", categoryId: "iphone", name: "iPhone 8 Series", releaseYear: 2017, baseGenerationValue: 25),
            DeviceGeneration(id: "iphone_x_series", categoryId: "iphone", name: "iPhone X Series", releaseYear: 2017, baseGenerationValue: 80),
            DeviceGeneration(id: "iphone_xs_xr_series", categoryId: "iphone", name: "iPhone XS / XR / XS Max Series", releaseYear: 2018, baseGenerationValue: 120),
            DeviceGeneration(id: "iphone_11_series", categoryId: "iphone", name: "iPhone 11 Series", releaseYear: 2019, baseGenerationValue: 170),
            DeviceGeneration(id: "iphone_12_series", categoryId: "iphone", name: "iPhone 12 Series", releaseYear: 2020, baseGenerationValue: 230),
            DeviceGeneration(id: "iphone_13_series", categoryId: "iphone", name: "iPhone 13 Series", releaseYear: 2021, baseGenerationValue: 280),
            DeviceGeneration(id: "iphone_14_series", categoryId: "iphone", name: "iPhone 14 Series", releaseYear: 2022, baseGenerationValue: 330),
            DeviceGeneration(id: "iphone_15_series", categoryId: "iphone", name: "iPhone 15 Series", releaseYear: 2023, baseGenerationValue: 420),
            DeviceGeneration(id: "iphone_16_series", categoryId: "iphone", name: "iPhone 16 Series", releaseYear: 2024, baseGenerationValue: 520),
            DeviceGeneration(id: "macbook_m5_pro", categoryId: "macbook", name: "M5 Pro Generation", releaseYear: 2026, baseGenerationValue: 1800, curveX: 1),
            DeviceGeneration(id: "macbook_m4_pro", categoryId: "macbook", name: "M4 Pro Generation", releaseYear: 2024, baseGenerationValue: 1600, curveX: 2),
            DeviceGeneration(id: "macbook_m3_pro", categoryId: "macbook", name: "M3 Pro Generation", releaseYear: 2023, baseGenerationValue: 1500, curveX: 3),
            DeviceGeneration(id: "macbook_m2_pro", categoryId: "macbook", name: "M2 Pro Generation", releaseYear: 2023, baseGenerationValue: 1200, curveX: 4),
            DeviceGeneration(id: "macbook_m1_pro", categoryId: "macbook", name: "M1 Pro Generation", releaseYear: 2021, baseGenerationValue: 1000, curveX: 5)
        ],
        variantRules: [
            VariantRule(id: "standard", categoryId: "iphone", name: "Standard", modifier: 0),
            VariantRule(id: "plus", categoryId: "iphone", name: "Plus", modifier: 30),
            VariantRule(id: "pro", categoryId: "iphone", name: "Pro", modifier: 80),
            VariantRule(id: "pro_max", categoryId: "iphone", name: "Pro Max", modifier: 140),
            VariantRule(id: "macbook_base_spec", categoryId: "macbook", name: "Base Spec", modifier: 0),
            VariantRule(id: "macbook_14_inch", categoryId: "macbook", name: "14-inch", modifier: 0),
            VariantRule(id: "macbook_16_inch", categoryId: "macbook", name: "16-inch", modifier: 180)
        ],
        storageRules: [
            StorageRule(id: "iphone_64", categoryId: "iphone", storageGb: 64, modifier: -25),
            StorageRule(id: "iphone_128", categoryId: "iphone", storageGb: 128, modifier: 0),
            StorageRule(id: "iphone_256", categoryId: "iphone", storageGb: 256, modifier: 50),
            StorageRule(id: "iphone_512", categoryId: "iphone", storageGb: 512, modifier: 80),
            StorageRule(id: "iphone_1024", categoryId: "iphone", storageGb: 1024, modifier: 100),
            StorageRule(id: "macbook_256", categoryId: "macbook", storageGb: 256, modifier: -150),
            StorageRule(id: "macbook_512", categoryId: "macbook", storageGb: 512, modifier: 0),
            StorageRule(id: "macbook_1024", categoryId: "macbook", storageGb: 1024, modifier: 180),
            StorageRule(id: "macbook_2048", categoryId: "macbook", storageGb: 2048, modifier: 320),
            StorageRule(id: "macbook_4096", categoryId: "macbook", storageGb: 4096, modifier: 500)
        ],
        batteryCurvePoints: [
            BatteryCurvePoint(categoryId: "iphone", batteryHealth: 100, modifier: 40),
            BatteryCurvePoint(categoryId: "iphone", batteryHealth: 95, modifier: 25),
            BatteryCurvePoint(categoryId: "iphone", batteryHealth: 90, modifier: 10),
            BatteryCurvePoint(categoryId: "iphone", batteryHealth: 87, modifier: 0),
            BatteryCurvePoint(categoryId: "iphone", batteryHealth: 85, modifier: -25),
            BatteryCurvePoint(categoryId: "iphone", batteryHealth: 82, modifier: -70),
            BatteryCurvePoint(categoryId: "iphone", batteryHealth: 80, modifier: -110)
        ],
        batteryExpectationRules: [
            BatteryExpectationRule(categoryId: "iphone", ageClass: .new, expectedBatteryHealth: 92, penaltyPerPercentBelowExpected: 8, maxPositiveReward: 20),
            BatteryExpectationRule(categoryId: "iphone", ageClass: .recent, expectedBatteryHealth: 89, penaltyPerPercentBelowExpected: 5, maxPositiveReward: 15),
            BatteryExpectationRule(categoryId: "iphone", ageClass: .middle, expectedBatteryHealth: 86, penaltyPerPercentBelowExpected: 3, maxPositiveReward: 10),
            BatteryExpectationRule(categoryId: "iphone", ageClass: .old, expectedBatteryHealth: 84, penaltyPerPercentBelowExpected: 2, maxPositiveReward: 5),
            BatteryExpectationRule(categoryId: "iphone", ageClass: .legacy, expectedBatteryHealth: 82, penaltyPerPercentBelowExpected: 1, maxPositiveReward: 0)
        ],
        conditionRules: [
            ConditionRule(id: "mint", categoryId: "iphone", name: "Mint", modifier: 40),
            ConditionRule(id: "excellent", categoryId: "iphone", name: "Excellent", modifier: 20),
            ConditionRule(id: "good", categoryId: "iphone", name: "Good", modifier: 30),
            ConditionRule(id: "average", categoryId: "iphone", name: "Average", modifier: 0),
            ConditionRule(id: "fair", categoryId: "iphone", name: "Fair", modifier: -50),
            ConditionRule(id: "poor", categoryId: "iphone", name: "Poor", modifier: -120),
            ConditionRule(id: "macbook_mint", categoryId: "macbook", name: "Mint", modifier: 120),
            ConditionRule(id: "macbook_excellent", categoryId: "macbook", name: "Excellent", modifier: 70),
            ConditionRule(id: "macbook_good", categoryId: "macbook", name: "Good", modifier: 0),
            ConditionRule(id: "macbook_average", categoryId: "macbook", name: "Average", modifier: -120),
            ConditionRule(id: "macbook_fair", categoryId: "macbook", name: "Fair", modifier: -300),
            ConditionRule(id: "macbook_poor", categoryId: "macbook", name: "Poor", modifier: -600)
        ],
        repairRules: [
            RepairRule(id: "screen_replaced", categoryId: "iphone", name: "Screen Replaced", penalty: 60, severity: .moderate),
            RepairRule(id: "face_id_broken", categoryId: "iphone", name: "Face ID Broken", penalty: 120, severity: .major),
            RepairRule(id: "back_glass_cracked", categoryId: "iphone", name: "Back Glass Cracked", penalty: 70, severity: .moderate),
            RepairRule(id: "logic_board_repaired", categoryId: "iphone", name: "Logic Board Repaired", penalty: 180, severity: .major),
            RepairRule(id: "macbook_display_damage", categoryId: "macbook", name: "Display Damage", penalty: 500, severity: .major),
            RepairRule(id: "macbook_keyboard_issue", categoryId: "macbook", name: "Keyboard / Trackpad Issue", penalty: 250, severity: .moderate),
            RepairRule(id: "macbook_battery_service", categoryId: "macbook", name: "Battery Service Needed", penalty: 220, severity: .moderate),
            RepairRule(id: "macbook_liquid_history", categoryId: "macbook", name: "Liquid Damage History", penalty: 700, severity: .major)
        ],
        accessoryRules: [
            AccessoryRule(id: "cable", categoryId: "iphone", name: "Charging Cable", modifier: 0),
            AccessoryRule(id: "box", categoryId: "iphone", name: "Original Box", modifier: 10),
            AccessoryRule(id: "charger", categoryId: "iphone", name: "Wall Charger", modifier: 15),
            AccessoryRule(id: "macbook_charger", categoryId: "macbook", name: "Original Charger", modifier: 60),
            AccessoryRule(id: "macbook_box", categoryId: "macbook", name: "Original Box", modifier: 25)
        ],
        ageClasses: [
            AgeClass(id: "iphone_new", categoryId: "iphone", name: .new, minMonths: 0, maxMonths: 12),
            AgeClass(id: "iphone_recent", categoryId: "iphone", name: .recent, minMonths: 12, maxMonths: 30),
            AgeClass(id: "iphone_middle", categoryId: "iphone", name: .middle, minMonths: 30, maxMonths: 60),
            AgeClass(id: "iphone_old", categoryId: "iphone", name: .old, minMonths: 60, maxMonths: 84),
            AgeClass(id: "iphone_legacy", categoryId: "iphone", name: .legacy, minMonths: 84, maxMonths: nil),
            AgeClass(id: "macbook_new", categoryId: "macbook", name: .new, minMonths: 0, maxMonths: 12),
            AgeClass(id: "macbook_recent", categoryId: "macbook", name: .recent, minMonths: 12, maxMonths: 30),
            AgeClass(id: "macbook_middle", categoryId: "macbook", name: .middle, minMonths: 30, maxMonths: 60),
            AgeClass(id: "macbook_old", categoryId: "macbook", name: .old, minMonths: 60, maxMonths: 84),
            AgeClass(id: "macbook_legacy", categoryId: "macbook", name: .legacy, minMonths: 84, maxMonths: nil)
        ],
        familyRules: [
            FamilyRule(id: "iphone_pro_max_family", categoryId: "iphone", name: "Pro Max", multiplier: 1.00),
            FamilyRule(id: "iphone_pro_family", categoryId: "iphone", name: "Pro", multiplier: 0.86),
            FamilyRule(id: "iphone_plus_air_family", categoryId: "iphone", name: "Plus / Air", multiplier: 0.72),
            FamilyRule(id: "iphone_regular_family", categoryId: "iphone", name: "Regular", multiplier: 0.64),
            FamilyRule(id: "iphone_e_se_family", categoryId: "iphone", name: "e / SE", multiplier: 0.45),
            FamilyRule(id: "macbook_pro_family", categoryId: "macbook", name: "MacBook Pro", multiplier: 1.00),
            FamilyRule(id: "macbook_air_15_family", categoryId: "macbook", name: "MacBook Air 15-inch", multiplier: 0.72),
            FamilyRule(id: "macbook_air_13_family", categoryId: "macbook", name: "MacBook Air 13-inch", multiplier: 0.64)
        ],
        tierRules: [
            TierRule(id: "iphone_default_tier", categoryId: "iphone", name: "Default", multiplier: 1.00),
            TierRule(id: "macbook_max_chip", categoryId: "macbook", name: "Max Chip", multiplier: 1.28),
            TierRule(id: "macbook_pro_chip", categoryId: "macbook", name: "Pro Chip", multiplier: 1.00),
            TierRule(id: "macbook_base_m_chip", categoryId: "macbook", name: "Base M Chip", multiplier: 0.80)
        ]
    )
}
