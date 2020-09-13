import UIKit
import ImageIO

public extension UIImage {
    func greyScaled() -> UIImage {
        let context = CIContext(options: nil)
        let ciImage = CIImage(image: self)!

        let bwFilter = CIFilter(name: "CIColorControls")!
        bwFilter.setValue(ciImage, forKey: kCIInputImageKey)
        bwFilter.setValue(0.0, forKey: kCIInputBrightnessKey)
        bwFilter.setValue(0.0, forKey: kCIInputSaturationKey)
        bwFilter.setValue(1.1, forKey: kCIInputContrastKey)

        let bwFilterOutput = (bwFilter.outputImage)!

        let exposureFilter = CIFilter(name: "CIExposureAdjust")!
        exposureFilter.setValue(bwFilterOutput, forKey: kCIInputImageKey)
        exposureFilter.setValue(0.7, forKey: kCIInputEVKey)
        let exposureFilterOutput = (exposureFilter.outputImage)!

        let bwCGIImage = context.createCGImage(exposureFilterOutput, from: exposureFilterOutput.extent)!
        let resultImage = UIImage(cgImage: bwCGIImage, scale: UIScreen.main.scale, orientation: self.imageOrientation)

        return resultImage
    }

    /**
     Downsampling large images for display at smaller size.
     ````
     func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = cv.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPAth) as! MyCell
         cell.layoutIfNeeded() // ensure imageView is its final size
         let imageViewSize = cell.imageView.bounds.size
         let scale = cv.traitCollection.displayScale
         cell.imageView.image = .downsample(imageFileAt: imageURLs[indexPath.row], to: imageViewSize, scale: scale)
         return cell
     }
     ````
     Or with prefetching and optionaly with a serial queue to avoid thread explosion if decoding many images at once:
     ````
     let serialQueue = DispatchQueue(label: "Decode queue")
     func collectionView(_ cv: UICollectionView, prefetchItemAt indexPaths: [IndexPath]) {
         for indexPath in indexPaths {
             serialQueue.async { //DispatchQueue.global(qos: .userInitiated).async {
                 let downsampledImage = downsample(images[indexPath.row])
                 DispatchQueue.main.async { self.update(at: indexPath, with: downsampledImage) }
             }
         }
     }
     ````
     */
    class func downsample(imageFileAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =
            [kCGImageSourceCreateThumbnailFromImageAlways: true,
             kCGImageSourceShouldCacheImmediately: true,
             kCGImageSourceCreateThumbnailWithTransform: true,
             kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampledImage)
    }
}
