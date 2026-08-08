import SwiftUI

struct RuleEditor: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                topBar
                importExportPanel
                globalPanel
                categoriesPanel
                generationsPanel
                familiesPanel
                tiersPanel
                variantsPanel
                storagePanel
                batteryCurvePanel
                batteryExpectationPanel
                conditionPanel
                repairPanel
                accessoryPanel
                ageClassPanel
            }
            .padding(24)
        }
        .navigationTitle("Rule Editor")
    }

    private var topBar: some View {
        HStack {
            Button("Reset to Seed Data", action: state.resetToSeedData)
            Button("Export Config JSON", action: state.exportConfigJSON)
            Button("Import Config JSON", action: state.importConfigJSON)
            Text(state.importMessage)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var importExportPanel: some View {
        Panel(title: "Import / Export") {
            TextEditor(text: $state.importExportText)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 180)
                .scrollContentBackground(.hidden)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var globalPanel: some View {
        Panel(title: "Global Reference") {
            LabeledContent("Global Reference Date") {
                TextField("YYYY-MM-DD", text: $state.config.globalReferenceDate)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    private var categoriesPanel: some View {
        editorPanel("Categories") {
            ForEach($state.config.categories) { $category in
                GridRow {
                    TextField("ID", text: $category.id)
                    TextField("Name", text: $category.name)
                    Picker("", selection: baseCurveBinding(for: $category.baseCurveType)) {
                        ForEach(BaseCurveType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    DoubleField(title: "Ref Base", value: optionalDoubleBinding(for: $category.referenceBaseValue))
                    DoubleField(title: "Decay", value: optionalDoubleBinding(for: $category.generationDecayRate))
                    DoubleField(title: "Market", value: $category.marketMultiplier)
                    Picker("", selection: $category.timeCurveType) {
                        ForEach(TimeCurveType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    DoubleField(title: "Decay", value: $category.monthlyDecayRate)
                    DoubleField(title: "Floor", value: $category.floorValue)
                    DoubleField(title: "Ceiling", value: ceilingBinding(for: $category.ceilingValue))
                    DoubleField(title: "Profit", value: $category.defaultTargetProfit)
                    DoubleField(title: "Min Offer", value: $category.minimumBuyOffer)
                    DoubleField(title: "Repair Cap", value: $category.repairPenaltyCapPercent)
                }
            }
            Button("Add Category") {
                state.config.categories.append(Category(id: "new_category", name: "New Category", marketMultiplier: 1, timeCurveType: .none, monthlyDecayRate: 0, minimumTimeMultiplier: 0.75, floorValue: 0, ceilingValue: nil, defaultTargetProfit: 100, minimumBuyOffer: 10, repairPenaltyCapPercent: 0.45))
            }
        }
    }

    private var generationsPanel: some View {
        editorPanel("Device Generations") {
            ForEach($state.config.deviceGenerations) { $generation in
                GridRow {
                    TextField("ID", text: $generation.id)
                    TextField("Category", text: $generation.categoryId)
                    TextField("Name", text: $generation.name)
                    IntField(title: "Year", value: $generation.releaseYear)
                    DoubleField(title: "Base", value: $generation.baseGenerationValue)
                    DoubleField(title: "Curve X", value: optionalDoubleBinding(for: $generation.curveX))
                }
            }
            Button("Add Generation") {
                state.config.deviceGenerations.append(DeviceGeneration(id: "new_generation", categoryId: "iphone", name: "New Generation", releaseYear: 2026, baseGenerationValue: 0))
            }
        }
    }

    private var familiesPanel: some View {
        editorPanel("Family Multipliers") {
            ForEach($state.config.familyRules.withDefault([])) { $rule in
                GridRow {
                    TextField("ID", text: $rule.id)
                    TextField("Category", text: $rule.categoryId)
                    TextField("Name", text: $rule.name)
                    DoubleField(title: "Multiplier", value: $rule.multiplier)
                }
            }
            Button("Add Family") {
                if state.config.familyRules == nil { state.config.familyRules = [] }
                state.config.familyRules?.append(FamilyRule(id: "new_family", categoryId: "macbook", name: "New Family", multiplier: 1))
            }
        }
    }

    private var tiersPanel: some View {
        editorPanel("Tier Multipliers") {
            ForEach($state.config.tierRules.withDefault([])) { $rule in
                GridRow {
                    TextField("ID", text: $rule.id)
                    TextField("Category", text: $rule.categoryId)
                    TextField("Name", text: $rule.name)
                    DoubleField(title: "Multiplier", value: $rule.multiplier)
                }
            }
            Button("Add Tier") {
                if state.config.tierRules == nil { state.config.tierRules = [] }
                state.config.tierRules?.append(TierRule(id: "new_tier", categoryId: "macbook", name: "New Tier", multiplier: 1))
            }
        }
    }

    private var variantsPanel: some View {
        editorPanel("Variant Rules") {
            ForEach($state.config.variantRules) { $rule in
                GridRow {
                    TextField("ID", text: $rule.id)
                    TextField("Category", text: $rule.categoryId)
                    TextField("Name", text: $rule.name)
                    DoubleField(title: "Modifier", value: $rule.modifier)
                }
            }
            Button("Add Variant") {
                state.config.variantRules.append(VariantRule(id: "new_variant", categoryId: "iphone", name: "New Variant", modifier: 0))
            }
        }
    }

    private var storagePanel: some View {
        editorPanel("Storage Rules") {
            ForEach($state.config.storageRules) { $rule in
                GridRow {
                    TextField("ID", text: $rule.id)
                    TextField("Category", text: $rule.categoryId)
                    IntField(title: "GB", value: $rule.storageGb)
                    DoubleField(title: "Modifier", value: $rule.modifier)
                }
            }
            Button("Add Storage") {
                state.config.storageRules.append(StorageRule(id: "new_storage", categoryId: "iphone", storageGb: 128, modifier: 0))
            }
        }
    }

    private var batteryCurvePanel: some View {
        editorPanel("Battery Curve Points") {
            ForEach($state.config.batteryCurvePoints) { $point in
                GridRow {
                    TextField("Category", text: $point.categoryId)
                    DoubleField(title: "Health", value: $point.batteryHealth)
                    DoubleField(title: "Modifier", value: $point.modifier)
                }
            }
            Button("Add Battery Point") {
                state.config.batteryCurvePoints.append(BatteryCurvePoint(categoryId: "iphone", batteryHealth: 88, modifier: 0))
            }
        }
    }

    private var batteryExpectationPanel: some View {
        editorPanel("Battery Expectation Rules") {
            ForEach($state.config.batteryExpectationRules) { $rule in
                GridRow {
                    TextField("Category", text: $rule.categoryId)
                    Picker("", selection: $rule.ageClass) {
                        ForEach(AgeClassName.allCases) { ageClass in
                            Text(ageClass.rawValue).tag(ageClass)
                        }
                    }
                    DoubleField(title: "Expected", value: $rule.expectedBatteryHealth)
                    DoubleField(title: "Penalty", value: $rule.penaltyPerPercentBelowExpected)
                    DoubleField(title: "Reward Cap", value: $rule.maxPositiveReward)
                }
            }
            Button("Add Battery Expectation") {
                state.config.batteryExpectationRules.append(BatteryExpectationRule(categoryId: "iphone", ageClass: .middle, expectedBatteryHealth: 86, penaltyPerPercentBelowExpected: 3, maxPositiveReward: 10))
            }
        }
    }

    private var conditionPanel: some View {
        editorPanel("Condition Rules") {
            ForEach($state.config.conditionRules) { $rule in
                GridRow {
                    TextField("ID", text: $rule.id)
                    TextField("Category", text: $rule.categoryId)
                    TextField("Name", text: $rule.name)
                    DoubleField(title: "Modifier", value: $rule.modifier)
                }
            }
            Button("Add Condition") {
                state.config.conditionRules.append(ConditionRule(id: "new_condition", categoryId: "iphone", name: "New Condition", modifier: 0))
            }
        }
    }

    private var repairPanel: some View {
        editorPanel("Repair Rules") {
            ForEach($state.config.repairRules) { $rule in
                GridRow {
                    TextField("ID", text: $rule.id)
                    TextField("Category", text: $rule.categoryId)
                    TextField("Name", text: $rule.name)
                    DoubleField(title: "Penalty", value: $rule.penalty)
                    Picker("", selection: $rule.severity) {
                        ForEach(Severity.allCases) { severity in
                            Text(severity.rawValue).tag(severity)
                        }
                    }
                }
            }
            Button("Add Repair") {
                state.config.repairRules.append(RepairRule(id: "new_repair", categoryId: "iphone", name: "New Repair", penalty: 0, severity: .minor))
            }
        }
    }

    private var accessoryPanel: some View {
        editorPanel("Accessory Rules") {
            ForEach($state.config.accessoryRules) { $rule in
                GridRow {
                    TextField("ID", text: $rule.id)
                    TextField("Category", text: $rule.categoryId)
                    TextField("Name", text: $rule.name)
                    DoubleField(title: "Modifier", value: $rule.modifier)
                }
            }
            Button("Add Accessory") {
                state.config.accessoryRules.append(AccessoryRule(id: "new_accessory", categoryId: "iphone", name: "New Accessory", modifier: 0))
            }
        }
    }

    private var ageClassPanel: some View {
        editorPanel("Age Classes") {
            ForEach($state.config.ageClasses) { $ageClass in
                GridRow {
                    TextField("ID", text: $ageClass.id)
                    TextField("Category", text: $ageClass.categoryId)
                    Picker("", selection: $ageClass.name) {
                        ForEach(AgeClassName.allCases) { name in
                            Text(name.rawValue).tag(name)
                        }
                    }
                    IntField(title: "Min", value: $ageClass.minMonths)
                    IntField(title: "Max", value: maxMonthsBinding(for: $ageClass.maxMonths))
                }
            }
            Button("Add Age Class") {
                state.config.ageClasses.append(AgeClass(id: "new_age_class", categoryId: "iphone", name: .middle, minMonths: 0, maxMonths: nil))
            }
        }
    }

    private func editorPanel<Content: View>(_ title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        DisclosureGroup {
            ScrollView(.horizontal) {
                Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                    content()
                }
                .padding(.top, 8)
            }
        } label: {
            Text(title)
                .font(.headline)
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func ceilingBinding(for value: Binding<Double?>) -> Binding<Double> {
        Binding(
            get: { value.wrappedValue ?? 0 },
            set: { value.wrappedValue = $0 <= 0 ? nil : $0 }
        )
    }

    private func maxMonthsBinding(for value: Binding<Int?>) -> Binding<Int> {
        Binding(
            get: { value.wrappedValue ?? 0 },
            set: { value.wrappedValue = $0 <= 0 ? nil : $0 }
        )
    }

    private func optionalDoubleBinding(for value: Binding<Double?>) -> Binding<Double> {
        Binding(
            get: { value.wrappedValue ?? 0 },
            set: { value.wrappedValue = $0 == 0 ? nil : $0 }
        )
    }

    private func baseCurveBinding(for value: Binding<BaseCurveType?>) -> Binding<BaseCurveType> {
        Binding(
            get: { value.wrappedValue ?? .manual },
            set: { value.wrappedValue = $0 }
        )
    }
}
