import SwiftUI

/// Flip-digit clock — split cards, not a plain digital readout.
struct FlipClockView: View {
    @State private var snapshot = FlipClockSnapshot.from(date: Date())

    var body: some View {
        HStack(spacing: 8) {
            FlipDigit(digit: snapshot.hourTens)
            FlipDigit(digit: snapshot.hourOnes)
            FlipColon()
            FlipDigit(digit: snapshot.minuteTens)
            FlipDigit(digit: snapshot.minuteOnes)
            Text(snapshot.meridiem)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textMuted)
                .padding(.leading, 2)
        }
        .frame(maxWidth: .infinity)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { date in
            let next = FlipClockSnapshot.from(date: date)
            if next != snapshot {
                snapshot = next
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Flip clock")
        .accessibilityValue("\(snapshot.hourTens)\(snapshot.hourOnes):\(snapshot.minuteTens)\(snapshot.minuteOnes) \(snapshot.meridiem)")
    }
}

struct FlipDigit: View {
    var digit: Int
    @State private var displayed: Int
    @State private var previous: Int
    @State private var flip = false

    init(digit: Int) {
        self.digit = digit
        _displayed = State(initialValue: digit)
        _previous = State(initialValue: digit)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 1) {
                half(displayed, top: true)
                half(flip ? previous : displayed, top: false)
            }
            if flip {
                half(previous, top: true)
                    .rotation3DEffect(
                        .degrees(flip ? 90 : 0),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .bottom,
                        perspective: 0.55
                    )
            }
        }
        .frame(width: Theme.flipDigitWidth, height: Theme.flipDigitHeight)
        .onAppear { displayed = digit }
        .onChange(of: digit) { _, newValue in
            previous = displayed
            displayed = newValue
            flip = false
            withAnimation(.easeIn(duration: 0.18)) {
                flip = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                flip = false
            }
        }
    }

    private func half(_ value: Int, top: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.38))
                .overlay {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.16), lineWidth: 0.6)
                }
            Text("\(value)")
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.text)
                .monospacedDigit()
                .frame(height: Theme.flipDigitHeight)
                .offset(y: top ? Theme.flipDigitHeight / 4 : -Theme.flipDigitHeight / 4)
                .frame(height: Theme.flipDigitHeight / 2 - 0.5, alignment: top ? .bottom : .top)
                .clipped()
        }
        .frame(height: Theme.flipDigitHeight / 2 - 0.5)
    }
}

private struct FlipColon: View {
    var body: some View {
        VStack(spacing: 10) {
            Capsule().fill(Theme.text.opacity(0.85)).frame(width: 5, height: 5)
            Capsule().fill(Theme.text.opacity(0.85)).frame(width: 5, height: 5)
        }
        .padding(.horizontal, 2)
    }
}
