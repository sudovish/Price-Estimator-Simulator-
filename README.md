# Price Estimator Simulator

A standalone macOS SwiftUI simulator for testing used-device resale values and recommended buy offers. The app models iPhone and MacBook pricing with editable business rules, live estimate feedback, scenario comparisons, and a detailed calculation breakdown.

This project was built as an internal pricing lab: instead of hard-coding one final price, it exposes the full valuation logic so changes to condition, battery health, repairs, storage, generation, market multipliers, and profit targets can be tested safely before being used in a real buyback or resale workflow.

## What It Does

- Calculates expected resale value for used devices
- Calculates a recommended buy offer after target profit and optional interest premium
- Supports iPhone and MacBook pricing categories
- Lets the user change generation, model family, tier, variant, storage, battery, condition, repairs, accessories, and date assumptions
- Shows every pricing adjustment in a readable breakdown
- Flags pricing warnings such as low battery health, tight profit margin, capped repair penalties, and minimum-offer safeguards
- Includes a full rule editor for changing pricing config without editing code
- Supports reset, JSON export, and JSON import for pricing rules
- Includes a scenario comparison screen for side-by-side pricing checks

## App Screens

| Screen | Purpose |
|---|---|
| Estimator | Main live simulator. User changes device inputs and pricing controls while the result updates immediately. |
| Rule Editor | Editable pricing configuration for categories, generations, families, tiers, variants, storage, battery curves, condition, repairs, accessories, and age classes. |
| Scenarios | Side-by-side checks for sample inputs, battery interpolation, and market multiplier changes. |

## Pricing Model

The pricing engine is centered on one function:

```swift
estimateDevicePrice(input:config:)
```

The UI calls this single function for valuation, which keeps the business logic separate from the SwiftUI screens.

The estimate flow is:

1. Find the selected category and device generation.
2. Calculate a base generation value.
3. Apply family and tier multipliers.
4. Add variant, storage, battery, condition, and accessory modifiers.
5. Apply repair penalties with category-specific penalty caps.
6. Apply market and time multipliers.
7. Clamp resale value to floor and ceiling safeguards.
8. Subtract target profit and add interest premium to recommend a buy offer.
9. Clamp the buy offer to the category minimum.
10. Return warnings and a full calculation breakdown.

Important distinction:

- `expectedResaleValue` is the estimated resale-side value of the device.
- `recommendedBuyOffer` is the offer after profit target and interest premium.

Target profit and interest premium affect only the recommended buy offer, not the expected resale value.

## Pricing Rules Included

The seed config includes:

- iPhone generations from iPhone 5s/7 through iPhone 16 series
- MacBook Pro generations from M1 Pro through M5 Pro
- iPhone family multipliers for Pro Max, Pro, Plus/Air, Regular, and e/SE
- MacBook family multipliers for Pro and Air sizes
- MacBook chip tier multipliers for Max, Pro, and base M chips
- Storage modifiers from 64GB through 1TB for iPhone and 256GB through 4TB for MacBook
- Battery curve points and age-based battery expectation penalties
- Condition modifiers from mint through poor
- Repair penalties with severity labels
- Accessory modifiers
- Age classes from new through legacy
- Floor values, ceiling values, repair penalty caps, default target profit, and minimum buy offer settings

## Repository Layout

```text
.
├── README.md
├── PriceEstimatorSimulator.xcodeproj/
└── PriceEstimatorSimulator/
    ├── AppState.swift
    ├── ContentView.swift
    ├── PriceEstimatorSimulatorApp.swift
    ├── Assets.xcassets/
    ├── Pricing/
    │   ├── Config.swift
    │   ├── Engine.swift
    │   ├── Helpers.swift
    │   ├── TestScenarios.swift
    │   └── Types.swift
    └── Views/
        ├── EstimatorForm.swift
        ├── ResultBreakdown.swift
        ├── RuleEditor.swift
        ├── ScenarioComparison.swift
        └── SharedControls.swift
```

## Key Files

| File | Role |
|---|---|
| `Pricing/Types.swift` | Codable pricing models, estimate input, estimate result, warnings, and breakdown line types. |
| `Pricing/Config.swift` | Seed pricing configuration for iPhone and MacBook categories. |
| `Pricing/Helpers.swift` | Category lookup, interpolation, date math, clamps, multipliers, repair caps, and curve calculations. |
| `Pricing/Engine.swift` | Core pricing engine and the public `estimateDevicePrice(input:config:)` function. |
| `Pricing/TestScenarios.swift` | Starter test scenarios for comparison mode. |
| `AppState.swift` | Shared app state, UserDefaults persistence, config reset, JSON import, and JSON export. |
| `ContentView.swift` | NavigationSplitView with Estimator, Rule Editor, and Scenarios sections. |
| `Views/EstimatorForm.swift` | Main interactive estimator UI. |
| `Views/ResultBreakdown.swift` | Detailed resale and buy-offer calculation output. |
| `Views/RuleEditor.swift` | Editable pricing tables and import/export controls. |
| `Views/ScenarioComparison.swift` | Side-by-side scenario cards for checking pricing behavior. |

## Tech Stack

| Layer | Technology |
|---|---|
| App | SwiftUI macOS app |
| State | `ObservableObject`, `@Published`, `EnvironmentObject` |
| Persistence | `UserDefaults` storing encoded pricing config |
| Serialization | `Codable`, `JSONEncoder`, `JSONDecoder` |
| UI | `NavigationSplitView`, forms, grids, toggles, pickers, editable tables |
| Build Tooling | Xcode / `xcodebuild` |

## Running The App

Open the project in Xcode:

```bash
open PriceEstimatorSimulator.xcodeproj
```

Then run the `PriceEstimatorSimulator` scheme on macOS.

## CLI Build

```bash
xcodebuild \
  -project PriceEstimatorSimulator.xcodeproj \
  -scheme PriceEstimatorSimulator \
  -configuration Debug \
  -derivedDataPath ../tmp/PriceEstimatorSimulatorDerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Portfolio Notes

This repo is organized to show the pricing logic clearly. The most important implementation detail is that the calculation engine is isolated from the UI, making it easier to test, review, and reuse in a production app or backend service later.
