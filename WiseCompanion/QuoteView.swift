import SwiftUI

struct QuoteView: View {
    private let quote = "Start the day by choosing one thing to do with care."
    private let context =
        "Your attention is your most valuable resource. When you decide where it goes before the day decides for you, you keep your agency. Let today be guided by a single intentional commitment."

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("“\(quote)”")
                .font(.title3)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)

            Text(context)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            HStack(spacing: 10) {
                Text(Date.now, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.plain)
                .help("Settings (coming soon)")
                .disabled(true)
            }
        }
        .padding(16)
        .frame(minWidth: 360, minHeight: 260, alignment: .topLeading)
    }
}


