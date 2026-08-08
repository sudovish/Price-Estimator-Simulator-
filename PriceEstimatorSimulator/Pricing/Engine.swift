import Foundation

enum PricingEngine {
    static func estimateDevicePrice(input: EstimateInput, config: PricingConfig) -> EstimateResult {
        guard
            let category = getCategory(input.categoryId, config),
            let generation = getGeneration(input.generationId, config)
        else {
            return emptyResult(message: "Missing category or generation.")
        }

        var warnings: [String] = []
        let ageClass = getAgeClass(input.categoryId, generation.releaseYear, input.currentDate, config)
        let ageClassName = ageClass?.name

        let baseGenerationValue = calculateBaseGenerationValue(category, generation)
        let familyMultiplier = getFamilyMultiplier(input.categoryId, input.familyId, config)
        let tierMultiplier = getTierMultiplier(input.categoryId, input.tierId, config)
        let variantModifier = getVariantModifier(input.categoryId, input.variantId, config)
        let storageModifier = getStorageModifier(input.categoryId, input.storageGb, config)
        let batteryModifier = getBatteryModifier(input.categoryId, input.batteryHealth, config)
        let batteryExpectationModifier = getBatteryExpectationModifier(input.categoryId, ageClassName, input.batteryHealth, config)
        let conditionModifier = getConditionModifier(input.categoryId, input.conditionId, config)
        let accessoryModifierTotal = getAccessoryModifierTotal(input.categoryId, input.accessoryIds, config)

        if let batteryHealth = input.batteryHealth, batteryHealth < 82 {
            warnings.append("Battery health is very low. High resale risk.")
        }

        if
            let batteryHealth = input.batteryHealth,
            let ageClassName,
            [.new, .recent].contains(ageClassName),
            let expectationRule = config.batteryExpectationRules.first(where: { $0.categoryId == input.categoryId && $0.ageClass == ageClassName }),
            batteryHealth <= expectationRule.expectedBatteryHealth - 3
        {
            warnings.append("Battery health is low for this device age.")
        }

        let baseValueAfterMultipliers = baseGenerationValue * familyMultiplier * tierMultiplier

        let valueBeforeRepairs = baseValueAfterMultipliers
            + variantModifier
            + storageModifier
            + batteryModifier
            + batteryExpectationModifier
            + conditionModifier
            + accessoryModifierTotal

        let repairPenalty = getRepairPenaltyTotal(input.categoryId, input.repairIds, valueBeforeRepairs, config)
        if repairPenalty.wasCapped {
            warnings.append("Repair penalties were capped to prevent over-penalizing.")
        }

        let rawValueBeforeSafeguards = valueBeforeRepairs - repairPenalty.afterCap
        let rawValue = max(0, rawValueBeforeSafeguards)
        let marketMultiplier = category.marketMultiplier
        let timeMultiplier = calculateTimeMultiplier(category, config.globalReferenceDate, input.currentDate)
        let expectedResaleValueBeforeClamp = rawValue * marketMultiplier * timeMultiplier
        let expectedResaleValue = clamp(expectedResaleValueBeforeClamp, category.floorValue, category.ceilingValue)

        if expectedResaleValue != expectedResaleValueBeforeClamp {
            if let ceiling = category.ceilingValue, expectedResaleValue == ceiling {
                warnings.append("Expected resale value was capped by ceiling safeguard.")
            }
            if expectedResaleValue == category.floorValue {
                warnings.append("Expected resale value was raised by floor safeguard.")
            }
        }

        let targetProfit = input.targetProfit ?? category.defaultTargetProfit
        let interestPremium = input.interestPremium ?? 0
        let recommendedBuyOfferBeforeClamp = expectedResaleValue - targetProfit + interestPremium
        let recommendedBuyOffer = max(category.minimumBuyOffer, recommendedBuyOfferBeforeClamp)

        if recommendedBuyOfferBeforeClamp < category.minimumBuyOffer {
            warnings.append("Recommended buy offer is below minimum offer.")
        }

        if targetProfit < expectedResaleValue * 0.15 {
            warnings.append("Profit margin is tight.")
        }

        let breakdown = [
            BreakdownLine(label: "Base Generation Value", amount: baseGenerationValue, type: .base, note: generation.name),
            BreakdownLine(label: "Family Multiplier", amount: familyMultiplier, type: .multiplier, note: input.familyId),
            BreakdownLine(label: "Tier Multiplier", amount: tierMultiplier, type: .multiplier, note: input.tierId),
            BreakdownLine(label: "Base After Multipliers", amount: baseValueAfterMultipliers, type: .result, note: nil),
            BreakdownLine(label: "Variant Modifier", amount: variantModifier, type: .modifier, note: nil),
            BreakdownLine(label: "Storage Modifier", amount: storageModifier, type: .modifier, note: "\(input.storageGb)GB"),
            BreakdownLine(label: "Battery Modifier", amount: batteryModifier, type: .modifier, note: input.batteryHealth.map { "\($0)%" }),
            BreakdownLine(label: "Battery Expectation Modifier", amount: batteryExpectationModifier, type: .modifier, note: ageClassName?.rawValue),
            BreakdownLine(label: "Condition Modifier", amount: conditionModifier, type: .modifier, note: nil),
            BreakdownLine(label: "Repair Penalties Before Cap", amount: -repairPenalty.beforeCap, type: .penalty, note: nil),
            BreakdownLine(label: "Repair Penalties After Cap", amount: -repairPenalty.afterCap, type: .penalty, note: nil),
            BreakdownLine(label: "Accessory Modifier", amount: accessoryModifierTotal, type: .modifier, note: nil),
            BreakdownLine(label: "Raw Value", amount: rawValue, type: .result, note: nil),
            BreakdownLine(label: "Market Multiplier", amount: marketMultiplier, type: .multiplier, note: nil),
            BreakdownLine(label: "Time Multiplier", amount: timeMultiplier, type: .multiplier, note: nil),
            BreakdownLine(label: "Expected Resale Value Before Clamp", amount: expectedResaleValueBeforeClamp, type: .result, note: nil),
            BreakdownLine(label: "Expected Resale Value After Clamp", amount: expectedResaleValue, type: .result, note: nil),
            BreakdownLine(label: "Target Profit", amount: -targetProfit, type: .penalty, note: nil),
            BreakdownLine(label: "Interest Premium", amount: interestPremium, type: .modifier, note: nil),
            BreakdownLine(label: "Recommended Buy Offer Before Clamp", amount: recommendedBuyOfferBeforeClamp, type: .result, note: nil),
            BreakdownLine(label: "Recommended Buy Offer After Clamp", amount: recommendedBuyOffer, type: .result, note: nil)
        ]

        return EstimateResult(
            baseGenerationValue: baseGenerationValue,
            variantModifier: variantModifier,
            storageModifier: storageModifier,
            batteryModifier: batteryModifier,
            batteryExpectationModifier: batteryExpectationModifier,
            conditionModifier: conditionModifier,
            repairPenaltyTotalBeforeCap: repairPenalty.beforeCap,
            repairPenaltyTotal: repairPenalty.afterCap,
            accessoryModifierTotal: accessoryModifierTotal,
            rawValueBeforeSafeguards: rawValueBeforeSafeguards,
            rawValue: rawValue,
            marketMultiplier: marketMultiplier,
            timeMultiplier: timeMultiplier,
            expectedResaleValueBeforeClamp: expectedResaleValueBeforeClamp,
            expectedResaleValue: expectedResaleValue,
            targetProfit: targetProfit,
            interestPremium: interestPremium,
            recommendedBuyOfferBeforeClamp: recommendedBuyOfferBeforeClamp,
            recommendedBuyOffer: recommendedBuyOffer,
            ageClass: ageClassName?.rawValue ?? "unknown",
            monthsSinceReference: monthsBetween(config.globalReferenceDate, input.currentDate),
            warnings: warnings,
            breakdown: breakdown
        )
    }

    private static func emptyResult(message: String) -> EstimateResult {
        EstimateResult(
            baseGenerationValue: 0,
            variantModifier: 0,
            storageModifier: 0,
            batteryModifier: 0,
            batteryExpectationModifier: 0,
            conditionModifier: 0,
            repairPenaltyTotalBeforeCap: 0,
            repairPenaltyTotal: 0,
            accessoryModifierTotal: 0,
            rawValueBeforeSafeguards: 0,
            rawValue: 0,
            marketMultiplier: 1,
            timeMultiplier: 1,
            expectedResaleValueBeforeClamp: 0,
            expectedResaleValue: 0,
            targetProfit: 0,
            interestPremium: 0,
            recommendedBuyOfferBeforeClamp: 0,
            recommendedBuyOffer: 0,
            ageClass: "unknown",
            monthsSinceReference: 0,
            warnings: [message],
            breakdown: []
        )
    }
}

func estimateDevicePrice(input: EstimateInput, config: PricingConfig) -> EstimateResult {
    PricingEngine.estimateDevicePrice(input: input, config: config)
}
