import SwiftUI

/// Thin line icons for Super Spade chips.
enum ThinIcons {
    static let line: CGFloat = 1.2

    struct Cloud: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            let r = min(rect.width, rect.height)
            p.addArc(
                center: CGPoint(x: rect.minX + r * 0.34, y: rect.midY + r * 0.08),
                radius: r * 0.22,
                startAngle: .degrees(20),
                endAngle: .degrees(200),
                clockwise: true
            )
            p.addArc(
                center: CGPoint(x: rect.midX + r * 0.02, y: rect.midY - r * 0.04),
                radius: r * 0.26,
                startAngle: .degrees(200),
                endAngle: .degrees(10),
                clockwise: true
            )
            p.addArc(
                center: CGPoint(x: rect.maxX - r * 0.28, y: rect.midY + r * 0.10),
                radius: r * 0.20,
                startAngle: .degrees(250),
                endAngle: .degrees(40),
                clockwise: true
            )
            return p
        }
    }

    struct Quota: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.addEllipse(in: rect.insetBy(dx: rect.width * 0.12, dy: rect.height * 0.12))
            p.move(to: CGPoint(x: rect.midX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.18))
            p.move(to: CGPoint(x: rect.midX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.22, y: rect.midY + rect.height * 0.06))
            return p
        }
    }

    struct CPU: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            let xs: [CGFloat] = [0.22, 0.50, 0.78]
            let hs: [CGFloat] = [0.42, 0.72, 0.55]
            for (xUnit, hUnit) in zip(xs, hs) {
                let x = rect.minX + rect.width * xUnit
                let top = rect.maxY - rect.height * hUnit
                p.move(to: CGPoint(x: x, y: rect.maxY - rect.height * 0.12))
                p.addLine(to: CGPoint(x: x, y: top))
            }
            return p
        }
    }

    struct Calendar: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            let body = rect.insetBy(dx: rect.width * 0.14, dy: rect.height * 0.16)
            p.addRoundedRect(in: body, cornerSize: CGSize(width: 2, height: 2))
            p.move(to: CGPoint(x: body.minX, y: body.minY + body.height * 0.32))
            p.addLine(to: CGPoint(x: body.maxX, y: body.minY + body.height * 0.32))
            p.move(to: CGPoint(x: body.minX + body.width * 0.28, y: rect.minY + rect.height * 0.10))
            p.addLine(to: CGPoint(x: body.minX + body.width * 0.28, y: body.minY + 1))
            p.move(to: CGPoint(x: body.maxX - body.width * 0.28, y: rect.minY + rect.height * 0.10))
            p.addLine(to: CGPoint(x: body.maxX - body.width * 0.28, y: body.minY + 1))
            return p
        }
    }

    struct Bolt: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: rect.midX + rect.width * 0.10, y: rect.minY + rect.height * 0.12))
            p.addLine(to: CGPoint(x: rect.midX - rect.width * 0.18, y: rect.midY + rect.height * 0.04))
            p.addLine(to: CGPoint(x: rect.midX + rect.width * 0.02, y: rect.midY + rect.height * 0.04))
            p.addLine(to: CGPoint(x: rect.midX - rect.width * 0.10, y: rect.maxY - rect.height * 0.12))
            return p
        }
    }

    /// Thin spade — host / overflow mark for Super Spade.
    struct Spade: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            let cx = rect.midX
            let top = rect.minY + rect.height * 0.12
            p.move(to: CGPoint(x: cx, y: top))
            p.addCurve(
                to: CGPoint(x: rect.minX + rect.width * 0.16, y: rect.midY + rect.height * 0.10),
                control1: CGPoint(x: cx - rect.width * 0.02, y: rect.minY + rect.height * 0.36),
                control2: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.midY - rect.height * 0.02)
            )
            p.addCurve(
                to: CGPoint(x: cx, y: rect.midY + rect.height * 0.18),
                control1: CGPoint(x: rect.minX + rect.width * 0.28, y: rect.midY + rect.height * 0.28),
                control2: CGPoint(x: cx - rect.width * 0.12, y: rect.midY + rect.height * 0.22)
            )
            p.addCurve(
                to: CGPoint(x: rect.maxX - rect.width * 0.16, y: rect.midY + rect.height * 0.10),
                control1: CGPoint(x: cx + rect.width * 0.12, y: rect.midY + rect.height * 0.22),
                control2: CGPoint(x: rect.maxX - rect.width * 0.28, y: rect.midY + rect.height * 0.28)
            )
            p.addCurve(
                to: CGPoint(x: cx, y: top),
                control1: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.midY - rect.height * 0.02),
                control2: CGPoint(x: cx + rect.width * 0.02, y: rect.minY + rect.height * 0.36)
            )
            p.move(to: CGPoint(x: cx, y: rect.midY + rect.height * 0.16))
            p.addLine(to: CGPoint(x: cx, y: rect.maxY - rect.height * 0.10))
            p.move(to: CGPoint(x: cx - rect.width * 0.14, y: rect.maxY - rect.height * 0.16))
            p.addLine(to: CGPoint(x: cx + rect.width * 0.14, y: rect.maxY - rect.height * 0.16))
            return p
        }
    }

    struct Tick: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.16))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.16))
            return p
        }
    }
}
