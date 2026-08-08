import Foundation

enum TestScenarios {
    static let target = EstimateInput(
        categoryId: "iphone",
        generationId: "iphone_15_series",
        variantId: "pro",
        storageGb: 256,
        batteryHealth: 86,
        conditionId: "good",
        repairIds: [],
        accessoryIds: ["cable"],
        currentDate: "2026-07-03",
        targetProfit: 130,
        interestPremium: 20
    )

    static let comparison: [EstimateInput] = [
        target,
        EstimateInput(categoryId: "iphone", generationId: "iphone_15_series", variantId: "pro", storageGb: 256, batteryHealth: 90, conditionId: "good", repairIds: [], accessoryIds: ["cable"], currentDate: "2026-07-03", targetProfit: 130, interestPremium: 0),
        EstimateInput(categoryId: "iphone", generationId: "iphone_15_series", variantId: "pro", storageGb: 256, batteryHealth: 95, conditionId: "good", repairIds: [], accessoryIds: ["cable"], currentDate: "2026-07-03", targetProfit: 130, interestPremium: 0),
        EstimateInput(categoryId: "iphone", generationId: "iphone_15_series", variantId: "pro", storageGb: 256, batteryHealth: 86, conditionId: "excellent", repairIds: [], accessoryIds: ["cable"], currentDate: "2026-07-03", targetProfit: 130, interestPremium: 0),
        EstimateInput(categoryId: "iphone", generationId: "iphone_15_series", variantId: "pro", storageGb: 256, batteryHealth: 86, conditionId: "fair", repairIds: [], accessoryIds: ["cable"], currentDate: "2026-07-03", targetProfit: 130, interestPremium: 0),
        EstimateInput(categoryId: "iphone", generationId: "iphone_16_series", variantId: "pro", storageGb: 256, batteryHealth: 86, conditionId: "good", repairIds: [], accessoryIds: ["cable"], currentDate: "2026-07-03", targetProfit: 150, interestPremium: 0)
    ]
}
