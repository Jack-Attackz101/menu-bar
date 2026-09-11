import SwiftUI

/// Stamped split-flap object cards — each digit is a physical cassette, not stacked plain digits.
struct FlipClockView: View {
    @State private var snapshot = FlipClockSnapshot.from(date: Date())

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            FlipDigit(digit: snapshot.hourTens)
            FlipDigit(digit: snapshot.hourOnes)
            FlipColon()
            FlipDigit(digit: snapshot.minuteTens)
            FlipDigit(digit: snapshot.minuteOnes)
            FlipMeridiem(text: snapshot.meridiem)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Theme.glassDeep.opacity(0.28))
                }
                .overlay {
                    AuroraMesh(intensity: 0.38)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.14), lineWidth: 0.5)
                }
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

/// Mechanical cassette around one stamped flap pair.
struct FlipCardCassette<Content: View>: View {
    var width: CGFloat
    var height: CGFloat
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .frame(width: width - FlipCardTokens.housingPad * 2, height: height - FlipCardTokens.housingPad * 2)
            .padding(FlipCardTokens.housingPad)
            .background {
                housing
            }
            .frame(width: width, height: height)
            .shadow(color: Color.black.opacity(0.42), radius: 5, x: 0, y: 3)
    }

    private var housing: some View {
        ZStack {
            RoundedRectangle(cornerRadius: FlipCardTokens.housingRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.14, green: 0.13, blue: 0.18),
                            Color(red: 0.06, green: 0.05, blue: 0.09)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            RoundedRectangle(cornerRadius: FlipCardTokens.housingRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.34), Color.white.opacity(0.08)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.8
                )
            RoundedRectangle(cornerRadius: FlipCardTokens.housingRadius - 2, style: .continuous)
                .strokeBorder(Color.black.opacity(0.45), lineWidth: 0.7)
                .padding(2)
        }
    }
}

enum FlipCardTokens {
    static let housingPad: CGFloat = 3.5
    static let housingRadius: CGFloat = 10
    static let cardRadius: CGFloat = 5.5
    static let hingeGap: CGFloat = 1.8
    static let digitSize: CGFloat = 36
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
        FlipCardCassette(width: Theme.flipDigitWidth, height: Theme.flipDigitHeight) {
            ZStack {
                VStack(spacing: FlipCardTokens.hingeGap) {
                    flap(displayed, top: true)
                    flap(bottomFlip ? displayed : previous, top: false)
                }

                hinge

                if topFlip {
                    flap(previous, top: true)
                        .rotation3DEffect(
                            .degrees(topFlip ? 88 : 0),
                            axis: (x: 1, y: 0, z: 0),
                            anchor: .bottom,
                            perspective: 0.78
                        )
                }

                if bottomFlip {
                    flap(displayed, top: false)
                        .rotation3DEffect(
                            .degrees(bottomFlip ? 0 : -88),
                            axis: (x: 1, y: 0, z: 0),
                            anchor: .top,
                            perspective: 0.78
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: FlipCardTokens.cardRadius + 0.5, style: .continuous))
        }
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
        HStack(spacing: 0) {
            Capsule()
                .fill(Color.black.opacity(0.72))
                .frame(width: 3.5, height: 5)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.22),
                            Color.black.opacity(0.70),
                            Color.white.opacity(0.10)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 1.6)
            Capsule()
                .fill(Color.black.opacity(0.72))
                .frame(width: 3.5, height: 5)
        }
        .shadow(color: Color.black.opacity(0.5), radius: 1, y: 0.5)
    }

    private func flap(_ value: Int, top: Bool) -> some View {
        ZStack {
            UnevenRoundedRectangle(
                topLeadingRadius: top ? FlipCardTokens.cardRadius : 1.2,
                bottomLeadingRadius: top ? 1.2 : FlipCardTokens.cardRadius,
                bottomTrailingRadius: top ? 1.2 : FlipCardTokens.cardRadius,
                topTrailingRadius: top ? FlipCardTokens.cardRadius : 1.2,
                style: .continuous
            )
            .fill(cardFill(top: top))

            UnevenRoundedRectangle(
                topLeadingRadius: top ? FlipCardTokens.cardRadius : 1.2,
                bottomLeadingRadius: top ? 1.2 : FlipCardTokens.cardRadius,
                bottomTrailingRadius: top ? 1.2 : FlipCardTokens.cardRadius,
                topTrailingRadius: top ? FlipCardTokens.cardRadius : 1.2,
                style: .continuous
            )
            .strokeBorder(
                LinearGradient(
                    colors: top
                        ? [Color.white.opacity(0.28), Color.white.opacity(0.04)]
                        : [Color.white.opacity(0.10), Color.white.opacity(0.16)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 0.6
            )

            if top {
                LinearGradient(
                    colors: [Color.white.opacity(0.16), Color.clear],
                    startPoint: .top,
                    endPoint: .center
                )
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: FlipCardTokens.cardRadius,
                        bottomLeadingRadius: 1.2,
                        bottomTrailingRadius: 1.2,
                        topTrailingRadius: FlipCardTokens.cardRadius,
                        style: .continuous
                    )
                )
            }

            stampedDigit(value, top: top)
        }
        .frame(height: flapHeight)
        .shadow(color: Color.black.opacity(top ? 0.18 : 0.28), radius: 1.2, y: top ? 0.4 : 1)
    }

    private var flapHeight: CGFloat {
        (Theme.flipDigitHeight - FlipCardTokens.housingPad * 2 - FlipCardTokens.hingeGap) / 2
    }

    private func cardFill(top: Bool) -> LinearGradient {
        LinearGradient(
            colors: top
                ? [
                    Color(red: 0.20, green: 0.19, blue: 0.26),
                    Color(red: 0.11, green: 0.10, blue: 0.16)
                ]
                : [
                    Color(red: 0.09, green: 0.08, blue: 0.13),
                    Color(red: 0.15, green: 0.14, blue: 0.20)
                ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func stampedDigit(_ value: Int, top: Bool) -> some View {
        let innerHeight = Theme.flipDigitHeight - FlipCardTokens.housingPad * 2
        let glyph = Text("\(value)")
            .font(.system(size: FlipCardTokens.digitSize, weight: .bold, design: .rounded))
            .fontWidth(.condensed)
            .monospacedDigit()

        return ZStack {
            glyph
                .foregroundStyle(Color.black.opacity(0.55))
                .offset(y: 1)
            glyph
                .foregroundStyle(Color.white.opacity(0.22))
                .offset(y: -0.7)
            glyph
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white.opacity(0.96), Color.white.opacity(0.78)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .frame(height: innerHeight)
        .offset(y: top ? innerHeight / 4 : -innerHeight / 4)
        .frame(height: flapHeight, alignment: top ? .bottom : .top)
        .clipped()
    }
}

private struct FlipColon: View {
    var body: some View {
        VStack(spacing: 11) {
            pellet
            pellet
        }
        .padding(.horizontal, 1)
    }

    private var pellet: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.16, green: 0.15, blue: 0.20),
                            Color(red: 0.07, green: 0.06, blue: 0.10)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.92), Color.white.opacity(0.62)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 5.5, height: 5.5)
                .shadow(color: Color.black.opacity(0.4), radius: 0.6, y: 0.6)
        }
        .frame(width: 11, height: 13)
        .overlay {
            RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
        }
        .shadow(color: Color.black.opacity(0.28), radius: 2, y: 1)
    }
}

private struct FlipMeridiem: View {
    var text: String

    var body: some View {
        FlipCardCassette(width: 34, height: 44) {
            ZStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.18, green: 0.17, blue: 0.24),
                                Color(red: 0.09, green: 0.08, blue: 0.13)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.16), lineWidth: 0.5)
                stamped
            }
        }
        .padding(.leading, 1)
    }

    private var stamped: some View {
        let glyph = Text(text)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .fontWidth(.condensed)

        return ZStack {
            glyph
                .foregroundStyle(Color.black.opacity(0.5))
                .offset(y: 0.8)
            glyph
                .foregroundStyle(Theme.text)
        }
    }
}
