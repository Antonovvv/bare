# Invalid NSPanel frame coordinates

## Symptom

Crash or assertion log similar to:

```
Invalid parameter not satisfying:
CGRectContainsRect(
  CGRectMake((CGFloat)INT_MIN, (CGFloat)INT_MIN,
             (CGFloat)INT_MAX - (CGFloat)INT_MIN,
             (CGFloat)INT_MAX - (CGFloat)INT_MIN),
  frame
).
self=<QNSPanel: 0x...> frame={{-2147483648, 2147484285}, {640, 480}}
```

This indicates an `NSPanel` (or `NSWindow`) is being assigned an
invalid frame. Values like `INT_MIN` are typically sentinel values
from uninitialized state or a corrupted persisted window frame.

## Typical root causes

- Restoring a window frame from user defaults without validation.
- Using a "not set yet" sentinel (like `INT_MIN`) and forgetting to
  replace it before calling `setFrame:` or `setFrameOrigin:`.
- Reading frame values from a file or IPC without bounds checking.

## Recommended fix

Validate and sanitize the frame before applying it. If it is invalid,
fall back to a safe default (e.g. a centered frame on the primary
screen).

### Objective-C example

```objc
static inline BOOL QNSIsFinite(CGFloat value) {
  return isfinite(value);
}

static inline BOOL QNSIsValidRect(NSRect rect) {
  return QNSIsFinite(rect.origin.x) &&
         QNSIsFinite(rect.origin.y) &&
         QNSIsFinite(rect.size.width) &&
         QNSIsFinite(rect.size.height) &&
         rect.size.width > 0.0 &&
         rect.size.height > 0.0;
}

static inline NSRect QNSSanitizeFrame(NSRect rect, NSScreen *screen) {
  if (!QNSIsValidRect(rect)) {
    NSRect screenFrame = screen ? screen.visibleFrame : NSMakeRect(0, 0, 1024, 768);
    CGFloat w = MIN(640.0, screenFrame.size.width);
    CGFloat h = MIN(480.0, screenFrame.size.height);
    CGFloat x = NSMidX(screenFrame) - (w / 2.0);
    CGFloat y = NSMidY(screenFrame) - (h / 2.0);
    return NSMakeRect(x, y, w, h);
  }
  return rect;
}

// Usage when restoring:
NSRect restored = /* read from storage */;
NSRect safeRect = QNSSanitizeFrame(restored, [NSScreen mainScreen]);
[panel setFrame:safeRect display:NO];
```

### Swift example

```swift
func isValid(rect: NSRect) -> Bool {
  func isFinite(_ v: CGFloat) -> Bool { v.isFinite }
  return isFinite(rect.origin.x) &&
         isFinite(rect.origin.y) &&
         isFinite(rect.size.width) &&
         isFinite(rect.size.height) &&
         rect.size.width > 0 &&
         rect.size.height > 0
}

func sanitizeFrame(_ rect: NSRect, screen: NSScreen?) -> NSRect {
  guard isValid(rect: rect) else {
    let screenFrame = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1024, height: 768)
    let width = min(640, screenFrame.width)
    let height = min(480, screenFrame.height)
    let x = screenFrame.midX - width / 2
    let y = screenFrame.midY - height / 2
    return NSRect(x: x, y: y, width: width, height: height)
  }
  return rect
}
```

## Additional mitigation

- When persisting frames, store only validated frames.
- Clamp restored frames to the visible screen area.
- If using multi-monitor setups, verify the saved frame still belongs
  to an active screen.
