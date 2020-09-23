import UIKit

public extension CGSize {
    /// Returns a new CGSize resized to fit inside `containerSize` while keeping its original aspect ratio
    func scaledToFitAspectRatio(inside containerSize: CGSize) -> CGSize {
        let aspectRatio = width / height

        if containerSize.width / aspectRatio < containerSize.height {
            return CGSize(width: containerSize.width, height: containerSize.width / aspectRatio)
        } else {
            return CGSize(width: containerSize.height * aspectRatio, height: containerSize.height)
        }
    }
}
