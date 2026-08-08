import SwiftUI

struct EstimatorForm: View {
    @EnvironmentObject private var state: AppState

    private var category: Category? {
        state.config.categories.first { $0.id == state.input.categoryId }
    }

    private var categoryIndex: Int? {
        state.config.categories.firstIndex { $0.id == state.input.categoryId }
    }

    private var categoryBinding: Binding<Category>? {
        guard let categoryIndex else { return nil }
        return $state.config.categories[categoryIndex]
    }

    private var categoryFamilies: [FamilyRule] {
        (state.config.familyRules ?? []).filter { $0.categoryId == state.input.categoryId }
    }

    private var categoryTiers: [TierRule] {
        (state.config.tierRules ?? []).filter { $0.categoryId == state.input.categoryId }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                HStack(alignment: .top, spacing: 18) {
                    VStack(spacing: 18) {
                        devicePanel
                        pricingPanel
                    }
                    .frame(minWidth: 360, idealWidth: 420)

                    VStack(spacing: 18) {
                        ResultBreakdown(result: state.result)
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("Estimator Simulator")
    }

    private var header: some View {
        HStack(spacing: 14) {
            MetricTile(title: "Expected Resale Value", value: state.result.expectedResaleValue.currencyText, tint: .blue)
            MetricTile(title: "Recommended Buy Offer", value: state.result.recommendedBuyOffer.currencyText, tint: .green)
            MetricTile(title: "Age Class", value: state.result.ageClass.capitalized, tint: .orange)
        }
    }

    private var devicePanel: some View {
        Panel(title: "Device Inputs") {
            Picker("Category", selection: categorySelectionBinding) {
                ForEach(state.config.categories) { category in
                    Text(category.name).tag(category.id)
                }
            }

            Picker("Generation", selection: $state.input.generationId) {
                ForEach(state.config.deviceGenerations.filter { $0.categoryId == state.input.categoryId }) { generation in
                    Text(generation.name).tag(generation.id)
                }
            }

            if !categoryFamilies.isEmpty {
                Picker("Family", selection: familySelectionBinding) {
                    ForEach(categoryFamilies) { family in
                        Text(family.name).tag(family.id)
                    }
                }
            }

            if !categoryTiers.isEmpty {
                Picker("Tier", selection: tierSelectionBinding) {
                    ForEach(categoryTiers) { tier in
                        Text(tier.name).tag(tier.id)
                    }
                }
            }

            Picker("Variant", selection: $state.input.variantId) {
                ForEach(state.config.variantRules.filter { $0.categoryId == state.input.categoryId }) { rule in
                    Text(rule.name).tag(rule.id)
                }
            }

            Picker("Storage", selection: $state.input.storageGb) {
                ForEach(state.config.storageRules.filter { $0.categoryId == state.input.categoryId }) { rule in
                    Text("\(rule.storageGb)GB").tag(rule.storageGb)
                }
            }

            LabeledContent(batteryLabel) {
                DoubleField(title: "Battery", value: batteryBinding)
            }

            Picker("Condition", selection: $state.input.conditionId) {
                ForEach(state.config.conditionRules.filter { $0.categoryId == state.input.categoryId }) { rule in
                    Text(rule.name).tag(rule.id)
                }
            }

            Divider()

            VStack(alignment: .leading) {
                Text("Repairs")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(state.config.repairRules.filter { $0.categoryId == state.input.categoryId }) { repair in
                    Toggle(repair.name, isOn: $state.input.repairIds.contains(repair.id))
                }
            }

            VStack(alignment: .leading) {
                Text("Accessories")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(state.config.accessoryRules.filter { $0.categoryId == state.input.categoryId }) { accessory in
                    Toggle(accessory.name, isOn: $state.input.accessoryIds.contains(accessory.id))
                }
            }
        }
    }

    private var pricingPanel: some View {
        Panel(title: "Pricing Controls") {
            LabeledContent("Current Date") {
                TextField("YYYY-MM-DD", text: $state.input.currentDate)
                    .textFieldStyle(.roundedBorder)
            }

            LabeledContent("Global Reference Date") {
                TextField("YYYY-MM-DD", text: $state.config.globalReferenceDate)
                    .textFieldStyle(.roundedBorder)
            }

            if let categoryBinding {
                LabeledContent("Market Multiplier") {
                    DoubleField(title: "Market", value: categoryBinding.marketMultiplier)
                }

                Picker("Time Curve", selection: categoryBinding.timeCurveType) {
                    ForEach(TimeCurveType.allCases) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }

                LabeledContent("Monthly Decay Rate") {
                    DoubleField(title: "Decay", value: categoryBinding.monthlyDecayRate)
                }
            }

            LabeledContent("Target Profit") {
                DoubleField(title: "Profit", value: targetProfitBinding)
            }

            LabeledContent("Interest Premium") {
                DoubleField(title: "Premium", value: interestPremiumBinding)
            }
        }
    }

    private var batteryBinding: Binding<Double> {
        Binding(
            get: { state.input.batteryHealth ?? 86 },
            set: { state.input.batteryHealth = $0 }
        )
    }

    private var batteryLabel: String {
        state.input.categoryId == "macbook" ? "Battery Health / Cycles" : "Battery Health"
    }

    private var categorySelectionBinding: Binding<String> {
        Binding(
            get: { state.input.categoryId },
            set: { state.selectCategory($0) }
        )
    }

    private var familySelectionBinding: Binding<String> {
        Binding(
            get: { state.input.familyId ?? categoryFamilies.first?.id ?? "" },
            set: { state.input.familyId = $0 }
        )
    }

    private var tierSelectionBinding: Binding<String> {
        Binding(
            get: { state.input.tierId ?? categoryTiers.first?.id ?? "" },
            set: { state.input.tierId = $0 }
        )
    }

    private var targetProfitBinding: Binding<Double> {
        Binding(
            get: { state.input.targetProfit ?? category?.defaultTargetProfit ?? 0 },
            set: { state.input.targetProfit = $0 }
        )
    }

    private var interestPremiumBinding: Binding<Double> {
        Binding(
            get: { state.input.interestPremium ?? 0 },
            set: { state.input.interestPremium = $0 }
        )
    }
}
