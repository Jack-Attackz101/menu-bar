import CoreGraphics
import SwiftUI

/// Fruit mark geometry traced from the studio mango stamp (body + detached leaf).
/// Canvas is the original 470×666 artboard; points are stored in unit canvas space.
enum MangoGeometry {
    static let canvasSize = CGSize(width: 470, height: 666)

    /// Combined body+leaf bounding box in canvas points (for aspect-fit).
    static let contentBounds = CGRect(x: 23.998, y: 24.003, width: 421.003, height: 616.996)

    static let markAspect: CGFloat = contentBounds.width / contentBounds.height

    /// Unit-canvas points (x / 470, y / 666), y-down.
    static let bodyUnits: [(CGFloat, CGFloat)] = [
        (0.62340, 0.20420), (0.70000, 0.20571), (0.78511, 0.22673), (0.85106, 0.26276),
        (0.91064, 0.32432), (0.93830, 0.38589), (0.94681, 0.47447), (0.92979, 0.56306),
        (0.88511, 0.66066), (0.82553, 0.74174), (0.75532, 0.80931), (0.68085, 0.86186),
        (0.58723, 0.90841), (0.49149, 0.93994), (0.39574, 0.95796), (0.29574, 0.96246),
        (0.21277, 0.95195), (0.17021, 0.93844), (0.12766, 0.91742), (0.09362, 0.89189),
        (0.07234, 0.86637), (0.05106, 0.80781), (0.05319, 0.76877), (0.07234, 0.72222),
        (0.10213, 0.68468), (0.20000, 0.60511), (0.25745, 0.54505), (0.30426, 0.46997),
        (0.34043, 0.38138), (0.39149, 0.30781), (0.45319, 0.25826), (0.50213, 0.23273),
        (0.57021, 0.21171), (0.62128, 0.20571),
    ]

    static let leafUnits: [(CGFloat, CGFloat)] = [
        (0.88085, 0.03604), (0.90851, 0.03754), (0.94468, 0.04505), (0.94468, 0.05556),
        (0.93404, 0.08258), (0.91702, 0.10511), (0.90000, 0.12012), (0.86596, 0.14114),
        (0.82979, 0.15465), (0.80426, 0.16066), (0.78298, 0.16366), (0.73404, 0.16366),
        (0.71064, 0.16066), (0.70851, 0.14264), (0.71277, 0.12763), (0.72979, 0.10060),
        (0.74255, 0.08709), (0.77660, 0.06306), (0.79574, 0.05405), (0.84468, 0.03904),
        (0.87872, 0.03754),
    ]

    /// Aspect-fit the mark into `rect`, centered, preserving the stamp’s portrait proportions.
    static func fittedFrame(in rect: CGRect) -> CGRect {
        let rectAspect = rect.width / max(rect.height, 0.0001)
        if rectAspect > markAspect {
            let width = rect.height * markAspect
            return CGRect(x: rect.midX - width / 2, y: rect.minY, width: width, height: rect.height)
        }
        let height = rect.width / markAspect
        return CGRect(x: rect.minX, y: rect.midY - height / 2, width: rect.width, height: height)
    }

    static func point(_ unit: (CGFloat, CGFloat), in frame: CGRect) -> CGPoint {
        let px = unit.0 * canvasSize.width
        let py = unit.1 * canvasSize.height
        let x = frame.minX + (px - contentBounds.minX) / contentBounds.width * frame.width
        let y = frame.minY + (py - contentBounds.minY) / contentBounds.height * frame.height
        return CGPoint(x: x, y: y)
    }

    static func addPolygon(_ units: [(CGFloat, CGFloat)], to path: CGMutablePath, in frame: CGRect) {
        guard let first = units.first else { return }
        path.move(to: point(first, in: frame))
        for unit in units.dropFirst() {
            path.addLine(to: point(unit, in: frame))
        }
        path.closeSubpath()
    }

    static func bodyPath(in rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        addPolygon(bodyUnits, to: path, in: fittedFrame(in: rect))
        return path
    }

    static func leafPath(in rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        addPolygon(leafUnits, to: path, in: fittedFrame(in: rect))
        return path
    }

    /// Combined silhouette (body + leaf) for the cream tray stamp.
    static func stampPath(in rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        let frame = fittedFrame(in: rect)
        addPolygon(bodyUnits, to: path, in: frame)
        addPolygon(leafUnits, to: path, in: frame)
        return path
    }
}

struct MangoBody: Shape {
    func path(in rect: CGRect) -> Path {
        Path(MangoGeometry.bodyPath(in: rect))
    }
}

struct MangoLeaf: Shape {
    func path(in rect: CGRect) -> Path {
        Path(MangoGeometry.leafPath(in: rect))
    }
}

/// In-panel fruit mark: fruit `#FFE169` + leaf `#4BA33D`, no stroke.
struct FruitMark: View {
    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            context.fill(Path(MangoGeometry.bodyPath(in: rect)), with: .color(Theme.fruit))
            context.fill(Path(MangoGeometry.leafPath(in: rect)), with: .color(Theme.leaf))
        }
        .accessibilityHidden(true)
    }
}

/// Cream silhouette for reuse (same geometry as the tray stamp).
struct CreamMangoStamp: View {
    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            context.fill(Path(MangoGeometry.stampPath(in: rect)), with: .color(Theme.cream))
        }
        .accessibilityHidden(true)
    }
}
