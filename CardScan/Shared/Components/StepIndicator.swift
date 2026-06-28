import SwiftUI

enum ScanStep: Int, CaseIterable {
    case capture  = 1
    case review   = 2
    case export   = 3

    var label: String {
        switch self {
        case .capture: return "Capture"
        case .review:  return "Review"
        case .export:  return "Export"
        }
    }
}

/// Mirrors the web app's 1 → 2 → 3 step progress row.
struct StepIndicator: View {
    let current: ScanStep

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ScanStep.allCases, id: \.self) { step in
                stepBubble(step)
                if step != .export {
                    Rectangle()
                        .fill(Color.csDivider)
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, Spacing.s3)
                }
            }
        }
    }

    @ViewBuilder
    private func stepBubble(_ step: ScanStep) -> some View {
        let isDone   = step.rawValue < current.rawValue
        let isActive = step == current

        HStack(spacing: Spacing.s2) {
            ZStack {
                Circle()
                    .strokeBorder(
                        isDone   ? Color.csSuccess :
                        isActive ? Color.csGreen   : Color.csTextFaint,
                        lineWidth: 2
                    )
                    .background(
                        Circle().fill(
                            isDone   ? Color.csSuccess :
                            isActive ? Color.csGreen   : Color.clear
                        )
                    )
                    .frame(width: 24, height: 24)

                if isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(step.rawValue)")
                        .font(.csXS.bold())
                        .foregroundStyle(
                            isActive ? .white : Color.csTextFaint
                        )
                }
            }

            Text(step.label)
                .font(.csSM)
                .fontWeight(.medium)
                .foregroundStyle(
                    isDone   ? Color.csTextMuted :
                    isActive ? Color.csGreen     : Color.csTextFaint
                )
        }
        .fixedSize()
    }
}

#Preview {
    VStack(spacing: Spacing.s8) {
        StepIndicator(current: .capture)
        StepIndicator(current: .review)
        StepIndicator(current: .export)
    }
    .padding(Spacing.s6)
    .background(Color.csBg)
}
