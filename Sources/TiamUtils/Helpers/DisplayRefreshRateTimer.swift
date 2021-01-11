import QuartzCore

/// Simple helper class wrapping a CADisplayLink and a callbaack synchronized with the refresh rate of the display
public final class DisplayRefreshRateTimer {
    private var timer: CADisplayLink?
    private let callback: () -> Void

    /// Instatiates a timer in a paused state. Call `resume()` when ready.
    /// - Parameters:
    ///   - preferredFramesPerSecond: Pass a low value (eg. 15 or 30) to decrease battery usage. By default it's equal to the maximum refresh rate of the display (usually 60 FPS).
    ///   - callback: Called when the screen refershes.
    public init(preferredFramesPerSecond: Int? = nil, callback: @escaping () -> Void) {
        self.callback = callback
        self.timer = CADisplayLink(target: self, selector: #selector(timerFired))
        if let preferredFPS = preferredFramesPerSecond {
            timer?.preferredFramesPerSecond = preferredFPS
        }
        timer?.isPaused = true
        timer?.add(to: .main, forMode: .common)
    }

    /// Pause the timer
    public func pause() {
        timer?.isPaused = true
    }

    /// Resume a paused timer
    public func resume() {
        timer?.isPaused = false
    }

    deinit {
        timer?.invalidate()
    }

    @objc private func timerFired(displaylink: CADisplayLink) {
        callback()
    }
}
