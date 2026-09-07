import SwiftUI

/// Object split-flap clock — physical cards, not a plain digital readout.
struct FlipClockView: View {
    @State private var snapshot = FlipClockSnapshot.from(date: Date())

    var body: some View {
        HStack(spacing: 7) {
            FlipDigit(digit: snapshot.hourTens)
            FlipDigit(digit: snapshot.hourOnes)
            FlipColon()
            FlipDigit(digit: snapshot.minuteTens)
            FlipDigit(digit: snapshot.minuteOnes)
            FlipMeridiem(text: snapshot.meridiem)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.glassDeep.opacity(0.45))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 0.7)
                }
                .shadow(color: Color.black.opacity(0.28), radius: 8, x: 0, y: 4)
        }
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
    @State private var topFlip = false
    @State private var bottomFlip = false

    init(digit: Int) {
        self.digit = digit
        _displayed = State(initialValue: digit)
        _previous = State(initialValue: digit)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                flap(displayed, top: true)
                hinge
                flap(bottomFlip ? displayed : previous, top: false)
            }

            if topFlip {
                flap(previous, top: true)
                    .rotation3DEffect(
                        .degrees(topFlip ? 88 : 0),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .bottom,
                        perspective: 0.72
                    )
            }

            if bottomFlip {
                flap(displayed, top: false)
                    .rotation3DEffect(
                        .degrees(bottomFlip ? 0 : -88),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .top,
                        perspective: 0.72
                    )
            }
        }
        .frame(width: Theme.flipDigitWidth, height: Theme.flipDigitHeight)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.7)
        }
        .shadow(color: Color.black.opacity(0.34), radius: 5, x: 0, y: 3)
        .onAppear { displayed = digit }
        .onChange(of: digit) { _, newValue in
            previous = displayed
            displayed = newValue
            topFlip = false
            bottomFlip = false
            withAnimation(.easeIn(duration: 0.16)) {
                topFlip = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                withAnimation(.easeOut(duration: 0.16)) {
                    bottomFlip = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    topFlip = false
                    bottomFlip = false
                    previous = displayed
                }
            }
        }
    }

    private var hinge: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.55))
                .frame(height: 1.4)
            Rectangle()
                .fill(Color.white.opacity(0.18))
                .frame(height: 0.6)
                .offset(y: 0.6)
        }
        .frame(height: 2)
    }

    private func flap(_ value: Int, top: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: top
                            ? [Color.white.opacity(0.16), Color.black.opacity(0.42)]
                            : [Color.black.opacity(0.50), Color.black.opacity(0.28)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Text("\(value)")
                .font(.system(size: 38, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.text)
                .monospacedDigit()
                .shadow(color: Color.black.opacity(0.45), radius: 0, x: 0, y: 1)
                .frame(height: Theme.flipDigitHeight)
                .offset(y: top ? Theme.flipDigitHeight / 4 : -Theme.flipDigitHeight / 4)
                .frame(height: Theme.flipDigitHeight / 2 - 1, alignment: top ? .bottom : .top)
                .clipped()
        }
        .frame(height: Theme.flipDigitHeight / 2 - 1)
    }
}

private struct FlipColon: View {
    var body: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(Theme.text.opacity(0.88))
                .frame(width: 6, height: 6)
                .shadow(color: Color.black.opacity(0.35), radius: 1, x: 0, y: 1)
            Capsule()
                .fill(Theme.text.opacity(0.88))
                .frame(width: 6, height: 6)
                .shadow(color: Color.black.opacity(0.35), radius: 1, x: 0, y: 1)
        }
        .padding(.horizontal, 2)
    }
}

private struct FlipMeridiem: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(Theme.text)
            .padding(.horizontal, 6)
            .padding(.vertical, 7)
            .background {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Theme.glassDeep.opacity(0.55))
                    .overlay {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.16), lineWidth: 0.6)
                    }
            }
            .padding(.leading, 2)
    }
}
