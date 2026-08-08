import SwiftUI

struct ScenarioComparison: View {
    @EnvironmentObject private var state: AppState
    @State private var scenarios = TestScenarios.comparison

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                MetricTile(title: "Battery Interpolation Check", value: interpolateCurve(points: state.config.batteryCurvePoints.filter { $0.categoryId == "iphone" }, x: 86).signedCurrencyText, tint: .purple)
                    .frame(maxWidth: 320)

                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(Array(scenarios.enumerated()), id: \.offset) { index, scenario in
                            scenarioCard(index: index, input: scenario)
                        }
                        marketScenarioCard
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding(24)
        }
        .navigationTitle("Scenario Comparison")
    }

    private func scenarioCard(index: Int, input: EstimateInput) -> some View {
        let result = estimateDevicePrice(input: input, config: state.config)
        let generation = state.config.deviceGenerations.first { $0.id == input.generationId }?.name ?? input.generationId
        let variant = state.config.variantRules.first { $0.id == input.variantId }?.name ?? input.variantId
        let condition = state.config.conditionRules.first { $0.id == input.conditionId }?.name ?? input.conditionId

        return VStack(alignment: .leading, spacing: 14) {
            Text("Scenario \(index + 1)")
                .font(.headline)
            Text("\(generation) \(variant)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Expected: \(result.expectedResaleValue.currencyText)")
                    .font(.title3.weight(.semibold))
                Text("Offer: \(result.recommendedBuyOffer.currencyText)")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.green)
            }

            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                GridRow {
                    Text("Battery")
                    Text(input.batteryHealth.map { "\($0)%" } ?? "None")
                }
                GridRow {
                    Text("Condition")
                    Text(condition)
                }
                GridRow {
                    Text("Target Profit")
                    Text((input.targetProfit ?? 0).currencyText)
                }
                GridRow {
                    Text("Storage")
                    Text("\(input.storageGb)GB")
                }
                GridRow {
                    Text("Battery Mod")
                    Text(result.batteryModifier.signedCurrencyText)
                }
                GridRow {
                    Text("Expectation Mod")
                    Text(result.batteryExpectationModifier.signedCurrencyText)
                }
                GridRow {
                    Text("Condition Mod")
                    Text(result.conditionModifier.signedCurrencyText)
                }
            }
            .font(.callout)

            if !result.warnings.isEmpty {
                Divider()
                ForEach(result.warnings, id: \.self) { warning in
                    Label(warning, systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(16)
        .frame(width: 300, alignment: .topLeading)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var marketScenarioCard: some View {
        var adjusted = state.config
        if let index = adjusted.categories.firstIndex(where: { $0.id == "iphone" }) {
            adjusted.categories[index].marketMultiplier = 0.96
        }

        let input = TestScenarios.target
        let result = estimateDevicePrice(input: input, config: adjusted)

        return VStack(alignment: .leading, spacing: 14) {
            Text("Market 0.96")
                .font(.headline)
            Text("Same target scenario with weakened iPhone market")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            Text("Expected: \(result.expectedResaleValue.currencyText)")
                .font(.title3.weight(.semibold))
            Text("Offer: \(result.recommendedBuyOffer.currencyText)")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.green)

            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                GridRow {
                    Text("Market Multiplier")
                    Text("0.96")
                }
                GridRow {
                    Text("Expected Before Clamp")
                    Text(result.expectedResaleValueBeforeClamp.currencyText)
                }
                GridRow {
                    Text("Target Profit")
                    Text(result.targetProfit.currencyText)
                }
            }
            .font(.callout)

            if !result.warnings.isEmpty {
                Divider()
                ForEach(result.warnings, id: \.self) { warning in
                    Label(warning, systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(16)
        .frame(width: 300, alignment: .topLeading)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
