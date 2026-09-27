import { useCallback, useEffect, useLayoutEffect, useRef, useState } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

const clamp01 = (v) => (v < 0 ? 0 : v > 1 ? 1 : v);

/**
 * Drives two CSS custom properties on a card element:
 *
 *   --card-progress  0 -> 1   reveal progress (entry animation)
 *   --card-active    0 -> 1   "dominance" -- peaks while the card sits near
 *                             the vertical centre of the viewport
 *
 * Everything downstream is pure CSS reading those variables, so a scroll frame
 * costs two setProperty calls per visible card and zero React renders.
 */
export function useCardScrollProgress(ref, { enabled = true } = {}) {
  useLayoutEffect(() => {
    const el = ref.current;
    if (!el) return undefined;

    if (!enabled) {
      // Reduced motion: land on the fully-revealed state immediately.
      el.style.setProperty('--card-progress', '1');
      el.style.setProperty('--card-active', '1');
      return undefined;
    }

    // gsap.context() scopes the trigger so revert() cleans it up on unmount
    // (including when the category filter removes this card).
    const ctx = gsap.context(() => {
      ScrollTrigger.create({
        trigger: el,
        start: 'top bottom',
        end: 'bottom top',
        scrub: true,
        onUpdate: (self) => {
          const p = self.progress;
          const reveal = clamp01((p - 0.1) / 0.32);
          const active = 1 - Math.min(1, Math.abs(p - 0.5) / 0.3);
          el.style.setProperty('--card-progress', reveal.toFixed(3));
          el.style.setProperty('--card-active', active.toFixed(3));
        },
      });
    }, el);

    return () => ctx.revert();
  }, [ref, enabled]);
}

/**
 * Very restrained pointer tilt. Writes --tilt-x / --tilt-y (rotation) and
 * --px / --py (pointer position, used to place the EXPLORE indicator).
 * Reads are batched into a single rAF so a fast pointer can't outrun layout.
 */
export function usePointerTilt(ref, { enabled = true, maxTilt = 5 } = {}) {
  const frame = useRef(0);
  const pending = useRef(null);

  const clear = useCallback(() => {
    const el = ref.current;
    if (!el) return;
    el.style.setProperty('--tilt-x', '0deg');
    el.style.setProperty('--tilt-y', '0deg');
  }, [ref]);

  useEffect(() => {
    const el = ref.current;
    if (!el || !enabled) return undefined;

    const flush = () => {
      frame.current = 0;
      const next = pending.current;
      if (!next || !ref.current) return;
      const { rx, ry, px, py } = next;
      ref.current.style.setProperty('--tilt-x', `${rx.toFixed(2)}deg`);
      ref.current.style.setProperty('--tilt-y', `${ry.toFixed(2)}deg`);
      ref.current.style.setProperty('--px', `${px.toFixed(1)}px`);
      ref.current.style.setProperty('--py', `${py.toFixed(1)}px`);
    };

    const onMove = (e) => {
      const rect = el.getBoundingClientRect();
      const px = e.clientX - rect.left;
      const py = e.clientY - rect.top;
      const nx = px / rect.width - 0.5;
      const ny = py / rect.height - 0.5;
      pending.current = { rx: -ny * maxTilt, ry: nx * maxTilt, px, py };
      if (!frame.current) frame.current = requestAnimationFrame(flush);
    };

    const onLeave = () => {
      pending.current = null;
      if (frame.current) {
        cancelAnimationFrame(frame.current);
        frame.current = 0;
      }
      clear();
    };

    el.addEventListener('pointermove', onMove);
    el.addEventListener('pointerleave', onLeave);

    return () => {
      el.removeEventListener('pointermove', onMove);
      el.removeEventListener('pointerleave', onLeave);
      if (frame.current) cancelAnimationFrame(frame.current);
      clear();
    };
  }, [ref, enabled, maxTilt, clear]);
}

/** Matches a media query with proper subscribe/unsubscribe. */
export function useMediaQuery(query) {
  const [matches, setMatches] = useState(() =>
    typeof window !== 'undefined' && window.matchMedia
      ? window.matchMedia(query).matches
      : false
  );

  useEffect(() => {
    if (typeof window === 'undefined' || !window.matchMedia) return undefined;
    const mql = window.matchMedia(query);
    const onChange = (e) => setMatches(e.matches);
    setMatches(mql.matches);
    mql.addEventListener('change', onChange);
    return () => mql.removeEventListener('change', onChange);
  }, [query]);

  return matches;
}

/** Re-measures every trigger after the grid reflows (filter / search change). */
export function useScrollTriggerRefresh(dep) {
  useEffect(() => {
    const id = requestAnimationFrame(() => ScrollTrigger.refresh());
    return () => cancelAnimationFrame(id);
  }, [dep]);
}