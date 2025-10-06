# Spec Summary (Lite)

Optimize enemy party controller performance by implementing staggered decision weight updates. Currently all party members recalculate weights every frame (500-1000 operations/frame with 10 enemies), causing lag. Switch to round-robin updates where only 1-2 members update per frame, reducing load by 90% while maintaining responsive AI behavior (updates every 5-10 frames = 0.08-0.16 seconds).
