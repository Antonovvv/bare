Crash analysis: CGRectContainsRect invalid frame in QNSPanel

Summary
-------
Xcode crash message:

  Invalid parameter not satisfying: CGRectContainsRect(
    CGRectMake((CGFloat)INT_MIN, (CGFloat)INT_MIN,
               (CGFloat)INT_MAX - (CGFloat)INT_MIN,
               (CGFloat)INT_MAX - (CGFloat)INT_MIN),
    frame).
  self=<QNSPanel: 0x1322719b0; contentView=NSObject(0x0)>
  frame={{-2147483648, 2147484285}, {640, 480}}

The window frame being applied to QNSPanel is outside the "safe"
CGRect range. The y origin is very close to INT_MAX and the height
pushes maxY beyond INT_MAX:

  2147484285 + 480 = 2147484765 > 2147483647 (INT_MAX)

This violates the CGRectContainsRect guard in AppKit and triggers
the assertion.

Likely root cause
-----------------
QNSPanel is the Qt AppKit wrapper for panels. The failure indicates
that geometry reaching AppKit already contains sentinel values or
overflowed coordinates. Typical causes include:

1) Uninitialized / invalid geometry.
   - A QRect or QWindow geometry that is not valid yet gets used.
   - Sentinel values (INT_MIN / INT_MAX) leak into the frame.

2) Overflow while flipping coordinates.
   - Converting from top-left to bottom-left coordinates using
     screenHeight - y - height when y is already extreme.

3) Persisted window state with corrupt values.
   - Restoring stored window position before validation.

4) "Move offscreen" logic using extreme coordinates.
   - Using INT_MIN / INT_MAX for hiding windows instead of orderOut.

Why it crashes here
-------------------
AppKit validates that any frame rect stays within a gigantic, but
finite, rectangle built from INT_MIN..INT_MAX. When the frame's
maxX/maxY exceeds that range (or contains NaN/INF), the check fails.

In this crash, maxY exceeds INT_MAX, so the frame is rejected.

Recommended fix
---------------
Validate and clamp geometry before creating or updating the NSWindow:

1) Guard invalid or uninitialized rectangles:
   - If QRect is not valid or width/height <= 0, bail out.
   - If any coordinate equals INT_MIN/INT_MAX, treat as invalid.

2) Clamp to a reasonable range before calling setFrame:
   - Ensure x/y are finite and within [minX, maxX - width/height].
   - minX/minY can be a generous negative bound (e.g. -100000).
   - maxX/maxY can be screenFrame.maxX/maxY, or a reasonable bound.

3) Avoid using extreme coordinates to hide windows:
   - Use orderOut:, setIsVisible:NO, or setAlphaValue:0.

4) Sanitize restored window state:
   - When loading persisted geometry, validate and clamp.

Extra diagnostics to confirm
----------------------------
Add logging right before the NSWindow/QNSPanel frame is set:

  - Requested frame (x, y, w, h)
  - Screen frame (NSScreen frame / visibleFrame)
  - Source of geometry (restore, layout, user resize, etc.)

If the invalid values come from Qt, trace the call stack to locate
the geometry calculation and add validation there.

Expected outcome
----------------
With geometry validation in place, AppKit will never receive frames
that exceed the INT_MIN..INT_MAX bound, avoiding this crash.
