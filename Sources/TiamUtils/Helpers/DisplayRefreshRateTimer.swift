import QuartzCore

/// Simple helper wrapping a CADisplayLink and a callback synchronized with the refresh rate of the display
public final class DisplayRefreshRateTimer {
    private let displayLink: CADisplayLink
    private let timerTarget: TimerTarget

    /// Instantiates a timer in a paused state. Call `resume()` when ready.
    /// - Parameters:
    ///   - preferredFramesPerSecond: Pass a low value (eg. 15 or 30) to decrease battery usage. By default it's equal to the maximum refresh rate of the display (usually 60 FPS).
    ///   - callback: Called when the screen refreshes.
    public init(preferredFramesPerSecond: Int? = nil, callback: @escaping () -> Void) {
        self.timerTarget = TimerTarget(callback: callback)
        self.displayLink = CADisplayLink(target: timerTarget, selector: #selector(TimerTarget.timerFired))

        if let preferredFPS = preferredFramesPerSecond {
            displayLink.preferredFramesPerSecond = preferredFPS
        }
        displayLink.isPaused = true
        displayLink.add(to: .main, forMode: .common)
    }

    /// Pause the timer
    public func pause() {
        displayLink.isPaused = true
    }

    /// Resume a paused timer
    public func resume() {
        displayLink.isPaused = false
    }

    deinit {
        displayLink.invalidate()
    }

    private final class TimerTarget {
        private let callback: () -> Void

        init(callback: @escaping () -> Void) {
            self.callback = callback
        }

        @objc func timerFired(displaylink: CADisplayLink) {
            callback()
        }
    }
}
