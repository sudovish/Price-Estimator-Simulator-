import SwiftUI

enum AppScreen: String, CaseIterable, Identifiable {
    case estimator = "Estimator"
    case rules = "Rule Editor"
    case scenarios = "Scenarios"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .estimator: "dollarsign.circle"
        case .rules: "slider.horizontal.3"
        case .scenarios: "rectangle.split.3x1"
        }
    }
}

struct ContentView: View {
    @State private var selectedScreen: AppScreen? = .estimator

    var body: some View {
        NavigationSplitView {
            List(AppScreen.allCases, selection: $selectedScreen) { screen in
                Label(screen.rawValue, systemImage: screen.systemImage)
                    .tag(screen)
            }
            .navigationTitle("Pricing")
        } detail: {
            switch selectedScreen ?? .estimator {
            case .estimator:
                EstimatorForm()
            case .rules:
                RuleEditor()
            case .scenarios:
                ScenarioComparison()
            }
        }
    }
}
