import SwiftUI

struct ResultBreakdown: View {
    let result: EstimateResult

    var body: some View {
        VStack(spacing: 18) {
            if !result.warnings.isEmpty {
                Panel(title: "Warnings") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(result.warnings, id: \.self) { warning in
                            Label(warning, systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }

            Panel(title: "Calculation Breakdown") {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                    GridRow {
                        Text("Step").foregroundStyle(.secondary)
                        Text("Amount").foregroundStyle(.secondary)
                        Text("Note").foregroundStyle(.secondary)
                    }
                    Divider()
                        .gridCellColumns(3)
                    ForEach(result.breakdown) { line in
                        GridRow {
                            Label(line.label, systemImage: icon(for: line.type))
                            Text(amountText(for: line))
                                .monospacedDigit()
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            Text(line.note ?? "")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Panel(title: "Engine Checks") {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                    GridRow {
                        Text("Months Since Reference")
                        Text("\(result.monthsSinceReference)")
                    }
                    GridRow {
                        Text("Target Profit Isolation")
                        Text("Affects buy offer only")
                            .foregroundStyle(.secondary)
                    }
                    GridRow {
                        Text("Interest Premium Isolation")
                        Text("Affects buy offer only")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func icon(for type: BreakdownLineType) -> String {
        switch type {
        case .base: "square.stack.3d.up"
        case .modifier: "plusminus"
        case .penalty: "minus.circle"
        case .multiplier: "multiply.circle"
        case .result: "equal.circle"
        }
    }

    private func amountText(for line: BreakdownLine) -> String {
        if line.type == .multiplier {
            return String(format: "%.3f", line.amount)
        }
        if line.type == .base || line.type == .result {
            return line.amount.currencyText
        }
        return line.amount.signedCurrencyText
    }
}
