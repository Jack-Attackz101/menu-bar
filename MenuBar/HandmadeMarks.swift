import SwiftUI

/// Filled handmade marks — slightly irregular, no outline, no SF Symbols.
enum HandmadeMarks {
    struct Cloud: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.08, y: rect.minY + rect.height * 0.38,
                                    width: rect.width * 0.48, height: rect.height * 0.46))
            p.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.36, y: rect.minY + rect.height * 0.34,
                                    width: rect.width * 0.56, height: rect.height * 0.50))
            p.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.28, y: rect.minY + rect.height * 0.12,
                                    width: rect.width * 0.38, height: rect.height * 0.42))
            return p
        }
    }

    struct Quota: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.addRoundedRect(
                in: rect.insetBy(dx: rect.width * 0.08, dy: rect.height * 0.18),
                cornerSize: CGSize(width: rect.width * 0.18, height: rect.height * 0.18)
            )
            var bite = Path()
            bite.addEllipse(in: CGRect(x: rect.midX, y: rect.minY + rect.height * 0.08,
                                       width: rect.width * 0.52, height: rect.height * 0.52))
            return p.subtracting(bite)
        }
    }

    struct CPUBars: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            let bars: [(CGFloat, CGFloat)] = [(0.08, 0.42), (0.38, 0.72), (0.68, 0.54)]
            let w = rect.width * 0.22
            for (xUnit, hUnit) in bars {
                let h = rect.height * hUnit
                let r = CGRect(x: rect.minX + rect.width * xUnit, y: rect.maxY - h - rect.height * 0.08,
                               width: w, height: h)
                p.addRoundedRect(in: r, cornerSize: CGSize(width: 1.4, height: 1.4))
            }
            return p
        }
    }

    struct Calendar: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            let body = CGRect(x: rect.minX + rect.width * 0.10, y: rect.minY + rect.height * 0.22,
                              width: rect.width * 0.80, height: rect.height * 0.68)
            p.addRoundedRect(in: body, cornerSize: CGSize(width: 2.2, height: 2.2))
            p.addRoundedRect(
                in: CGRect(x: rect.minX + rect.width * 0.22, y: rect.minY + rect.height * 0.06,
                           width: rect.width * 0.16, height: rect.height * 0.28),
                cornerSize: CGSize(width: 1.0, height: 1.0)
            )
            p.addRoundedRect(
                in: CGRect(x: rect.minX + rect.width * 0.62, y: rect.minY + rect.height * 0.06,
                           width: rect.width * 0.16, height: rect.height * 0.28),
                cornerSize: CGSize(width: 1.0, height: 1.0)
            )
            return p
        }
    }

    struct Sun: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            let core = CGRect(x: rect.midX - rect.width * 0.22, y: rect.midY - rect.height * 0.22,
                              width: rect.width * 0.44, height: rect.height * 0.44)
            p.addEllipse(in: core)
            let rays = 7
            for i in 0..<rays {
                let t = Double(i) / Double(rays) * .pi * 2 + 0.18
                let inner = min(rect.width, rect.height) * 0.28
                let outer = min(rect.width, rect.height) * (i.isMultiple(of: 2) ? 0.48 : 0.42)
                let cx = rect.midX
                let cy = rect.midY
                let a = CGPoint(x: cx + CGFloat(cos(t)) * inner, y: cy + CGFloat(sin(t)) * inner)
                let b = CGPoint(x: cx + CGFloat(cos(t + 0.22)) * outer, y: cy + CGFloat(sin(t + 0.22)) * outer)
                let c = CGPoint(x: cx + CGFloat(cos(t - 0.22)) * outer, y: cy + CGFloat(sin(t - 0.22)) * outer)
                p.move(to: a)
                p.addLine(to: b)
                p.addLine(to: c)
                p.closeSubpath()
            }
            return p
        }
    }

    /// Neutral host / overflow mark: three filled dots, slightly uneven.
    struct HostDots: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            let dots: [(CGFloat, CGFloat, CGFloat)] = [
                (0.18, 0.50, 0.13),
                (0.50, 0.48, 0.15),
                (0.80, 0.52, 0.12),
            ]
            for (x, y, r) in dots {
                let radius = min(rect.width, rect.height) * r
                p.addEllipse(in: CGRect(x: rect.minX + rect.width * x - radius,
                                        y: rect.minY + rect.height * y - radius,
                                        width: radius * 2, height: radius * 2))
            }
            return p
        }
    }

    /// Thin handmade tick so the hide drop-point is visible when expanded.
    struct HideTick: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            let w = max(1.4, rect.width * 0.28)
            p.addRoundedRect(
                in: CGRect(x: rect.midX - w / 2, y: rect.minY + rect.height * 0.18,
                           width: w, height: rect.height * 0.64),
                cornerSize: CGSize(width: 0.8, height: 0.8)
            )
            return p
        }
    }
}
