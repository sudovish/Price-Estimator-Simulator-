import Foundation

final class AppState: ObservableObject {
    @Published var config: PricingConfig {
        didSet { saveConfig() }
    }

    @Published var input: EstimateInput
    @Published var importExportText = ""
    @Published var importMessage = ""

    private let defaultsKey = "PriceEstimatorSimulator.config.v2"

    init() {
        if
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let decoded = try? JSONDecoder().decode(PricingConfig.self, from: data)
        {
            config = decoded
        } else {
            config = SeedPricingConfig.config
        }

        input = TestScenarios.target
        importExportText = Self.makeJSONString(from: config)
    }

    var result: EstimateResult {
        estimateDevicePrice(input: input, config: config)
    }

    func selectCategory(_ categoryId: String) {
        input.categoryId = categoryId
        input.generationId = config.deviceGenerations.first { $0.categoryId == categoryId }?.id ?? input.generationId
        input.familyId = (config.familyRules ?? []).first { $0.categoryId == categoryId }?.id
        input.tierId = (config.tierRules ?? []).first { $0.categoryId == categoryId }?.id
        input.variantId = config.variantRules.first { $0.categoryId == categoryId }?.id ?? input.variantId
        input.storageGb = config.storageRules.first { $0.categoryId == categoryId }?.storageGb ?? input.storageGb
        input.conditionId = config.conditionRules.first { $0.categoryId == categoryId }?.id ?? input.conditionId
        input.repairIds = []
        input.accessoryIds = []
    }

    func resetToSeedData() {
        config = SeedPricingConfig.config
        importExportText = Self.makeJSONString(from: config)
        importMessage = "Seed data restored."
    }

    func exportConfigJSON() {
        importExportText = Self.makeJSONString(from: config)
        importMessage = "Config exported."
    }

    func importConfigJSON() {
        guard let data = importExportText.data(using: .utf8) else {
            importMessage = "Import failed: text is not UTF-8."
            return
        }

        do {
            config = try JSONDecoder().decode(PricingConfig.self, from: data)
            importMessage = "Config imported."
        } catch {
            importMessage = "Import failed: \(error.localizedDescription)"
        }
    }

    private func saveConfig() {
        guard let data = try? JSONEncoder().encode(config) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    private static func makeJSONString(from config: PricingConfig) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(config) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
}
