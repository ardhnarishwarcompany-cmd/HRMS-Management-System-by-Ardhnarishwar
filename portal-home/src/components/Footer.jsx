import React, { useEffect, useMemo, useRef, useState } from 'react';
import {
  motion,
  useMotionValueEvent,
  useReducedMotion,
  useScroll,
  useTransform,
} from 'framer-motion';
import {
  UserPlus,
  Users,
  Building2,
  UserCheck,
  Sparkles,
  Video,
  BarChart3,
  Cpu,
  ShieldCheck,
  Wallet,
  ArrowRight,
  ArrowUpRight,
} from 'lucide-react';
import { PORTALS, resolveUrl } from '../data/portals';

/* ------------------------------------------------------------------ */
/* Data                                                                */
/* ------------------------------------------------------------------ */

// Ecosystem nodes, in reveal order.
const ECOSYSTEM_NODES = [
  { id: 'recruitment', label: 'RECRUITMENT', desc: 'Sourcing & pipeline', icon: UserPlus, color: '#6366f1' },
  { id: 'hr', label: 'HR MANAGEMENT', desc: 'Records & approvals', icon: Users, color: '#a855f7' },
  { id: 'client', label: 'CLIENT PORTAL', desc: 'Delivery & invoicing', icon: Building2, color: '#10b981' },
  { id: 'candidate', label: 'CANDIDATE PORTAL', desc: 'Applications & offers', icon: UserCheck, color: '#3b82f6' },
  { id: 'aiScreening', label: 'AI SCREENING', desc: 'Automated evaluation', icon: Sparkles, color: '#8b5cf6' },
  { id: 'interviews', label: 'INTERVIEWS', desc: 'AI-conducted video calls', icon: Video, color: '#ec4899' },
  { id: 'analytics', label: 'WORKFORCE ANALYTICS', desc: 'Real-time insight', icon: BarChart3, color: '#06b6d4' },
  { id: 'automation', label: 'AUTOMATION', desc: 'Attendance & workflows', icon: Cpu, color: '#f59e0b' },
  { id: 'compliance', label: 'COMPLIANCE', desc: 'Security & audits', icon: ShieldCheck, color: '#2563eb' },
  { id: 'finance', label: 'FINANCE', desc: 'Payroll & revenue', icon: Wallet, color: '#22c55e' },
];

const CAPABILITIES = [
  'HIRE.', 'SCREEN.', 'CONNECT.', 'MANAGE.', 'COLLABORATE.',
  'AUTOMATE.', 'ANALYZE.', 'COMPLY.', 'OPTIMIZE.', 'TRANSFORM.',
];

/**
 * Footer link groups. "Platform" is derived from the real portal registry.
 * The other groups are intentionally empty -- empty groups are not rendered,
 * so no links are invented here. Add `{ label, onClick }` entries once those
 * routes actually exist.
 */
const LINK_GROUPS = [
  {
    title: 'PLATFORM',
    links: PORTALS.map((p) => ({
      label: p.name,
      onClick: () => window.open(resolveUrl(p.key), '_blank', 'noopener'),
    })),
  },
  { title: 'COMPANY', links: [] },
  { title: 'RESOURCES', links: [] },
  { title: 'LEGAL', links: [] },
];

const ORBIT_RADIUS_VMIN = 33;

/* ------------------------------------------------------------------ */
/* Scroll-range helpers                                                */
/* ------------------------------------------------------------------ */

/**
 * Framer Motion accelerates `useTransform` chains that read from `useScroll`
 * by handing them to the Web Animations API with a ScrollTimeline. The input
 * range is passed through as WAAPI keyframe *offsets*, which the browser only
 * accepts in the [0, 1] range and in increasing order -- anything else throws
 * "Failed to execute 'animate' on 'Element': Offsets must be null or in the
 * range [0,1]". Derived ranges (start + n) can drift past 1, so every scroll
 * range goes through here first.
 */
const STOP_EPSILON = 0.0001;

function stops(...values) {
  const n = values.length;
  const out = values.map((v) => Math.min(1, Math.max(0, v)));

  for (let i = 1; i < n; i++) {
    if (out[i] <= out[i - 1]) out[i] = out[i - 1] + STOP_EPSILON;
  }
  for (let i = n - 1; i >= 0; i--) {
    if (out[i] > 1) out[i] = 1;
    if (i < n - 1 && out[i] >= out[i + 1]) out[i] = out[i + 1] - STOP_EPSILON;
  }
  return out;
}

// Nodes reveal in three waves (4 / 4 / 2), matching the 30-55% / 55-75% /
// 75-90% scroll windows from the brief.
function nodeStart(index) {
  if (index < 4) return 0.30 + index * (0.25 / 4);
  if (index < 8) return 0.55 + (index - 4) * (0.20 / 4);
  return 0.75 + (index - 8) * (0.13 / 2);
}

function nodeAngleRad(index) {
  return (-90 + index * 36) * (Math.PI / 180);
}

const CAP_RANGE_START = 0.28;
const CAP_RANGE_END = 0.92;
const CAP_STEP = (CAP_RANGE_END - CAP_RANGE_START) / CAPABILITIES.length;

function capabilityCenter(index) {
  return CAP_RANGE_START + CAP_STEP * (index + 0.5);
}

/* ------------------------------------------------------------------ */
/* Theme tokens                                                        */
/* ------------------------------------------------------------------ */

function useFooterTheme(isDark) {
  return useMemo(
    () =>
      isDark
        ? {
            isDark: true,
            base: '#05070e',
            grid: 'rgba(255,255,255,0.05)',
            heading: '#ffffff',
            body: '#94a3b8',
            muted: '#64748b',
            surface: 'rgba(9, 13, 26, 0.6)',
            hairline: 'rgba(255,255,255,0.06)',
            eyebrow: '#c7d2fe',
            coreGlow:
              'radial-gradient(circle, rgba(99,102,241,0.45), rgba(168,85,247,0.22) 45%, transparent 72%)',
            coreFace:
              'radial-gradient(circle at 35% 30%, rgba(255,255,255,0.14), rgba(99,102,241,0.14) 40%, rgba(5,7,14,0.65) 78%)',
            coreBorder: 'rgba(255,255,255,0.12)',
            coreShadow:
              '0 0 60px -10px rgba(99,102,241,0.6), inset 0 0 40px -15px rgba(168,85,247,0.5)',
            borderAlpha: '45',
            glowStrength: 1,
            gradientText: 'from-indigo-300 via-violet-300 to-blue-300',
            capabilityText: 'from-indigo-200 via-violet-200 to-blue-200',
            particle: 'rgba(165,180,252,0.9)',
          }
        : {
            isDark: false,
            base: '#f5f7fc',
            grid: 'rgba(15,23,42,0.05)',
            heading: '#0f172a',
            body: '#475569',
            muted: '#64748b',
            surface: 'rgba(255, 255, 255, 0.72)',
            hairline: 'rgba(15,23,42,0.08)',
            eyebrow: '#4338ca',
            coreGlow:
              'radial-gradient(circle, rgba(99,102,241,0.22), rgba(168,85,247,0.12) 45%, transparent 72%)',
            coreFace:
              'radial-gradient(circle at 35% 30%, rgba(255,255,255,0.95), rgba(99,102,241,0.12) 45%, rgba(226,232,240,0.85) 80%)',
            coreBorder: 'rgba(15,23,42,0.08)',
            coreShadow:
              '0 0 40px -14px rgba(99,102,241,0.35), inset 0 0 30px -18px rgba(168,85,247,0.28)',
            borderAlpha: '55',
            glowStrength: 0.45,
            gradientText: 'from-indigo-600 via-violet-600 to-blue-600',
            capabilityText: 'from-indigo-600 via-violet-600 to-blue-600',
            particle: 'rgba(99,102,241,0.7)',
          },
    [isDark]
  );
}

/* ------------------------------------------------------------------ */
/* Hooks                                                               */
/* ------------------------------------------------------------------ */

// Picks the layout in JS rather than rendering both trees behind
// `hidden lg:block`, so only one ecosystem is ever mounted and animated.
function useMediaQuery(query) {
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

// Derives the "currently active" node + capability from scroll progress.
// React bails out of the re-render when the index is unchanged, so this costs
// a couple of comparisons per frame rather than a React update per frame.
function useActiveIndices(progress) {
  const [activeNode, setActiveNode] = useState(-1);
  const [activeWord, setActiveWord] = useState(-1);

  useMotionValueEvent(progress, 'change', (v) => {
    let node = -1;
    for (let i = 0; i < ECOSYSTEM_NODES.length; i++) {
      if (v >= nodeStart(i)) node = i;
    }
    setActiveNode(node);

    if (v < CAP_RANGE_START - CAP_STEP || v > CAP_RANGE_END + CAP_STEP) {
      setActiveWord(-1);
    } else {
      const idx = Math.round((v - CAP_RANGE_START) / CAP_STEP - 0.5);
      setActiveWord(Math.min(CAPABILITIES.length - 1, Math.max(0, idx)));
    }
  });

  return { activeNode, activeWord };
}

/* ------------------------------------------------------------------ */
/* Shared actions (existing app behaviour -- no invented routes)       */
/* ------------------------------------------------------------------ */

function scrollToPortalGrid() {
  const el = document.getElementById('portal-grid');
  if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function launchEmployeePortal() {
  window.open(resolveUrl('employee'), '_blank', 'noopener');
}

/* ------------------------------------------------------------------ */
/* Background                                                          */
/* ------------------------------------------------------------------ */

function AmbientBackground({ theme, particleCount = 22, animate = true }) {
  const particles = useMemo(
    () =>
      Array.from({ length: particleCount }, (_, i) => ({
        left: `${(i * 47) % 100}%`,
        top: `${(i * 71) % 100}%`,
        delay: `${(i % 7) * 0.6}s`,
        duration: `${6 + (i % 5)}s`,
        size: i % 3 === 0 ? 2 : 1,
      })),
    [particleCount]
  );

  return (
    <div className="absolute inset-0 pointer-events-none" aria-hidden="true">
      <div className="absolute inset-0" style={{ background: theme.base }} />
      <div
        className="absolute inset-0 footer-grid-lines"
        style={{ '--footer-grid': theme.grid }}
      />
      <div
        className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[70vmin] h-[70vmin] rounded-full"
        style={{ border: `1px solid rgba(99,102,241,${0.1 * theme.glowStrength})` }}
      />
      <div
        className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[95vmin] h-[95vmin] rounded-full"
        style={{ border: `1px solid rgba(168,85,247,${0.08 * theme.glowStrength})` }}
      />
      {animate &&
        particles.map((p, i) => (
          <span
            key={i}
            className="footer-particle absolute rounded-full"
            style={{
              left: p.left,
              top: p.top,
              width: p.size,
              height: p.size,
              background: theme.particle,
              animationDelay: p.delay,
              animationDuration: p.duration,
            }}
          />
        ))}
    </div>
  );
}

function BrandEyebrow({ theme, className = '' }) {
  return (
    <div
      className={`inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full border text-[10px] font-bold tracking-[0.22em] ${className}`}
      style={{
        borderColor: 'rgba(99,102,241,0.35)',
        background: 'rgba(99,102,241,0.1)',
        color: theme.eyebrow,
      }}
    >
      <span className="w-1.5 h-1.5 rounded-full bg-indigo-400 animate-pulse" />
      ARDHNARISHWAR • UNIFIED HR ECOSYSTEM
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Stage 1 -- cinematic intro                                          */
/* ------------------------------------------------------------------ */

function FooterIntro({ progress, theme, compact = false }) {
  const opacity = useTransform(progress, stops(0, 0.05, 0.19, 0.27), [0, 1, 1, 0]);
  const y = useTransform(progress, stops(0, 0.24), [0, -50]);
  const taglineOpacity = useTransform(progress, stops(0.02, 0.08, 0.19, 0.27), [0, 1, 1, 0]);
  const labelOpacity = useTransform(progress, stops(0.16, 0.23, 0.34, 0.42), [0, 1, 1, 0]);

  return (
    <>
      <motion.div
        className={`absolute inset-0 z-30 flex flex-col pointer-events-none ${
          compact
            ? 'items-center justify-start text-center px-6 pt-[16vh]'
            : 'items-start justify-center px-10 xl:px-20'
        }`}
        style={{ opacity, y }}
      >
        <BrandEyebrow theme={theme} className="mb-5" />
        <h2
          className={`font-display font-extrabold leading-[0.95] tracking-tight ${
            compact ? 'text-[11vw]' : 'text-[5.4vw]'
          }`}
          style={{ color: theme.heading }}
        >
          THE WORKFORCE,
          <br />
          <span className={`bg-gradient-to-r ${theme.gradientText} bg-clip-text text-transparent`}>
            CONNECTED.
          </span>
        </h2>
        <motion.p
          className={`mt-5 text-sm sm:text-base ${compact ? 'max-w-sm' : 'max-w-md'}`}
          style={{ opacity: taglineOpacity, color: theme.body }}
        >
          One intelligent ecosystem for every side of modern work.
        </motion.p>
      </motion.div>

      <motion.div
        className={`absolute left-1/2 -translate-x-1/2 z-30 pointer-events-none text-center ${
          compact ? 'top-[7%]' : 'top-[30%]'
        }`}
        style={{ opacity: labelOpacity }}
      >
        <span className="text-[10px] sm:text-xs font-bold tracking-[0.3em]" style={{ color: theme.muted }}>
          ONE INTELLIGENT ECOSYSTEM
        </span>
      </motion.div>
    </>
  );
}

/* ------------------------------------------------------------------ */
/* Stage 2 -- AI core                                                  */
/* ------------------------------------------------------------------ */

function AICore({ progress, theme, animate = true, size = 'lg' }) {
  const opacity = useTransform(progress, stops(0.10, 0.22), [0, 1]);
  const scale = useTransform(progress, stops(0.10, 0.22, 1), [0.7, 1, 1.06]);
  const glow = useTransform(progress, stops(0.1, 0.5, 1), [0.35, 0.7, 1]);

  const box = size === 'lg' ? 'w-52 h-52' : 'w-36 h-36';
  const spin = animate ? 'animate-spin-slow' : '';

  return (
    <motion.div className="relative z-20" style={{ opacity, scale }}>
      <div className={`relative ${box} flex items-center justify-center`}>
        <motion.div
          className="absolute -inset-16 rounded-full blur-3xl"
          style={{ opacity: glow, background: theme.coreGlow }}
        />
        <div
          className={`absolute inset-0 rounded-full ${spin}`}
          style={{ border: `1px solid rgba(99,102,241,${0.28 * theme.glowStrength})` }}
        />
        <div
          className={`absolute inset-3 rounded-full ${spin} [animation-direction:reverse]`}
          style={{ border: `1px solid rgba(168,85,247,${0.22 * theme.glowStrength})` }}
        />
        <div
          className="absolute inset-7 rounded-full"
          style={{ border: `1px solid rgba(6,182,212,${0.16 * theme.glowStrength})` }}
        />

        {animate &&
          [0, 1, 2].map((i) => (
            <div
              key={i}
              className="absolute inset-0 animate-spin-slow"
              style={{ animationDuration: `${14 + i * 6}s`, animationDelay: `${i * -4}s` }}
            >
              <div
                className="absolute w-1.5 h-1.5 rounded-full"
                style={{
                  top: '3%',
                  left: '50%',
                  background: theme.particle,
                  boxShadow: `0 0 8px 2px ${theme.particle}`,
                }}
              />
            </div>
          ))}

        <div
          className="absolute inset-9 rounded-full backdrop-blur-xl"
          style={{
            background: theme.coreFace,
            border: `1px solid ${theme.coreBorder}`,
            boxShadow: theme.coreShadow,
          }}
        />

        <div className="relative z-10 flex flex-col items-center">
          <span
            className={`font-display font-extrabold tracking-wide ${
              size === 'lg' ? 'text-3xl' : 'text-2xl'
            }`}
            style={{ color: theme.heading }}
          >
            AR
          </span>
          <span
            className="mt-1.5 text-[9px] sm:text-[10px] font-semibold tracking-[0.25em]"
            style={{ color: theme.muted }}
          >
            INTELLIGENCE LAYER
          </span>
        </div>
      </div>
    </motion.div>
  );
}

/* ------------------------------------------------------------------ */
/* Stage 2 -- connections + nodes                                      */
/* ------------------------------------------------------------------ */

function ConnectionLine({ node, index, progress, isActive }) {
  const start = nodeStart(index);
  const scaleX = useTransform(progress, stops(start, start + 0.08), [0, 1]);
  const opacity = useTransform(progress, stops(start, start + 0.03), [0, 0.6]);
  const particlePulse = useTransform(progress, stops(start + 0.05, start + 0.12), [0, 1]);
  const angleDeg = -90 + index * 36;

  return (
    <motion.div
      className="absolute top-1/2 left-1/2 origin-left transition-[filter] duration-500"
      style={{
        width: `${ORBIT_RADIUS_VMIN}vmin`,
        height: 1,
        rotate: angleDeg,
        scaleX,
        opacity,
        background: `linear-gradient(90deg, ${node.color}, transparent)`,
        filter: isActive ? `drop-shadow(0 0 4px ${node.color})` : 'none',
      }}
    >
      <motion.span
        className="absolute -top-[3px] left-1/2 w-1.5 h-1.5 rounded-full"
        style={{
          background: node.color,
          opacity: particlePulse,
          boxShadow: `0 0 6px 2px ${node.color}`,
        }}
      />
    </motion.div>
  );
}

function NodeCard({ node, isActive, theme, compact = false }) {
  const Icon = node.icon;
  return (
    <div
      className={`group/node relative flex items-center gap-2.5 rounded-2xl border backdrop-blur-xl transition-all duration-300 hover:-translate-y-0.5 hover:!opacity-100 ${
        compact ? 'px-3 py-2' : 'px-3.5 py-2.5'
      }`}
      style={{
        background: theme.surface,
        borderColor: isActive ? `${node.color}aa` : `${node.color}${theme.borderAlpha}`,
        boxShadow: isActive ? `0 0 26px -6px ${node.color}` : 'none',
        opacity: isActive ? 1 : 0.7,
      }}
    >
      <div
        className="relative z-10 w-8 h-8 rounded-lg flex items-center justify-center shrink-0 transition-transform duration-300 group-hover/node:scale-105"
        style={{ background: `${node.color}22`, color: node.color }}
      >
        <Icon className="w-4 h-4" />
      </div>
      <div className="relative z-10 text-left">
        <div
          className="text-[10.5px] font-bold tracking-wider whitespace-nowrap"
          style={{ color: theme.heading }}
        >
          {node.label}
        </div>
        <div className="text-[10px] whitespace-nowrap" style={{ color: theme.muted }}>
          {node.desc}
        </div>
      </div>
    </div>
  );
}

function EcosystemNode({ node, index, progress, isActive, theme }) {
  const start = nodeStart(index);
  const opacity = useTransform(progress, stops(start, start + 0.06), [0, 1]);
  const scale = useTransform(progress, stops(start, start + 0.06), [0.55, 1]);

  const rad = nodeAngleRad(index);
  const x = Math.cos(rad) * ORBIT_RADIUS_VMIN;
  const y = Math.sin(rad) * ORBIT_RADIUS_VMIN;

  return (
    <motion.div
      className="absolute top-1/2 left-1/2"
      style={{ x: `calc(-50% + ${x}vmin)`, y: `calc(-50% + ${y}vmin)`, opacity, scale }}
    >
      <NodeCard node={node} isActive={isActive} theme={theme} />
    </motion.div>
  );
}

/* ------------------------------------------------------------------ */
/* Stage 2 -- capability typography                                    */
/* ------------------------------------------------------------------ */

function CapabilityWord({ word, index, progress, theme, isActive }) {
  const center = capabilityCenter(index);
  const opacity = useTransform(
    progress,
    stops(
      center - CAP_STEP,
      center - CAP_STEP * 0.35,
      center,
      center + CAP_STEP * 0.35,
      center + CAP_STEP
    ),
    [0.18, 0.55, 1, 0.55, 0.18]
  );
  const scale = useTransform(
    progress,
    stops(center - CAP_STEP * 0.35, center, center + CAP_STEP * 0.35),
    [0.95, 1.06, 0.95]
  );

  return (
    <motion.span
      className={`block font-display font-bold text-sm tracking-wide text-right bg-gradient-to-r ${theme.capabilityText} bg-clip-text text-transparent`}
      style={{
        opacity,
        scale,
        filter: isActive ? 'drop-shadow(0 0 10px rgba(129,140,248,0.45))' : 'none',
      }}
    >
      {word}
    </motion.span>
  );
}

/* ------------------------------------------------------------------ */
/* Stage 2 -- desktop ecosystem                                        */
/* ------------------------------------------------------------------ */

function WorkforceEcosystemDesktop({ theme }) {
  const sectionRef = useRef(null);
  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ['start start', 'end end'],
  });
  const { activeNode, activeWord } = useActiveIndices(scrollYProgress);

  const groupOpacity = useTransform(scrollYProgress, stops(0.90, 0.97, 1), [1, 0.35, 0]);
  const groupScale = useTransform(scrollYProgress, stops(0.90, 1), [1, 0.86]);

  return (
    // No `overflow-hidden` on this element or on any ancestor of the sticky
    // child -- a clipping ancestor silently disables `position: sticky`.
    <section ref={sectionRef} className="relative" style={{ height: '240vh' }}>
      <div className="sticky top-0 h-screen w-full overflow-hidden">
        <AmbientBackground theme={theme} />
        <FooterIntro progress={scrollYProgress} theme={theme} />

        <motion.div
          className="absolute inset-0 z-10"
          style={{ opacity: groupOpacity, scale: groupScale, willChange: 'transform, opacity' }}
        >
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
            <AICore progress={scrollYProgress} theme={theme} />
          </div>

          {ECOSYSTEM_NODES.map((node, i) => (
            <ConnectionLine
              key={node.id}
              node={node}
              index={i}
              progress={scrollYProgress}
              isActive={activeNode === i}
            />
          ))}

          {ECOSYSTEM_NODES.map((node, i) => (
            <EcosystemNode
              key={node.id}
              node={node}
              index={i}
              progress={scrollYProgress}
              isActive={activeNode === i}
              theme={theme}
            />
          ))}

          <div className="absolute top-1/2 right-10 xl:right-20 -translate-y-1/2 flex flex-col gap-3">
            {CAPABILITIES.map((word, i) => (
              <CapabilityWord
                key={word}
                word={word}
                index={i}
                progress={scrollYProgress}
                theme={theme}
                isActive={activeWord === i}
              />
            ))}
          </div>
        </motion.div>
      </div>
    </section>
  );
}

/* ------------------------------------------------------------------ */
/* Stage 2 -- mobile ecosystem (vertical spine, not a shrunk desktop)  */
/* ------------------------------------------------------------------ */

function MobileEcosystemNode({ node, index, progress, isActive, theme }) {
  const start = nodeStart(index);
  const opacity = useTransform(progress, stops(start, start + 0.05), [0, 1]);
  const x = useTransform(progress, stops(start, start + 0.05), [index % 2 === 0 ? -20 : 20, 0]);

  return (
    <motion.div className="flex items-center gap-2" style={{ opacity, x }}>
      <span
        className="h-px w-4 shrink-0"
        style={{ background: `linear-gradient(90deg, ${node.color}, transparent)` }}
      />
      <NodeCard node={node} isActive={isActive} theme={theme} compact />
    </motion.div>
  );
}

function WorkforceEcosystemMobile({ theme }) {
  const sectionRef = useRef(null);
  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ['start start', 'end end'],
  });
  const { activeNode, activeWord } = useActiveIndices(scrollYProgress);

  const spineScale = useTransform(scrollYProgress, stops(0.26, 0.9), [0, 1]);
  const listOpacity = useTransform(scrollYProgress, stops(0.24, 0.32), [0, 1]);
  const groupOpacity = useTransform(scrollYProgress, stops(0.9, 1), [1, 0]);
  const coreShift = useTransform(scrollYProgress, stops(0.1, 0.32), [40, 0]);

  return (
    <section ref={sectionRef} className="relative" style={{ height: '190vh' }}>
      <div className="sticky top-0 h-screen w-full overflow-hidden">
        <AmbientBackground theme={theme} particleCount={10} />
        <FooterIntro progress={scrollYProgress} theme={theme} compact />

        <motion.div
          className="absolute inset-0 z-10 flex flex-col items-center pt-[7vh] px-5"
          style={{ opacity: groupOpacity, willChange: 'transform, opacity' }}
        >
          <motion.div style={{ y: coreShift }}>
            <AICore progress={scrollYProgress} theme={theme} size="sm" />
          </motion.div>

          <motion.div
            className="mt-2 h-6 w-px origin-top"
            style={{
              scaleY: spineScale,
              background: 'linear-gradient(180deg, rgba(99,102,241,0.8), rgba(99,102,241,0.1))',
            }}
          />

          <motion.div
            className="mt-2 w-full max-w-[320px] flex flex-col gap-1.5"
            style={{ opacity: listOpacity }}
          >
            {ECOSYSTEM_NODES.map((node, i) => (
              <MobileEcosystemNode
                key={node.id}
                node={node}
                index={i}
                progress={scrollYProgress}
                isActive={activeNode === i}
                theme={theme}
              />
            ))}
          </motion.div>

          <div className="mt-4 h-7 flex items-center justify-center">
            <span
              className={`font-display font-extrabold text-lg tracking-wide bg-gradient-to-r ${theme.capabilityText} bg-clip-text text-transparent transition-opacity duration-300`}
              style={{ opacity: activeWord >= 0 ? 1 : 0 }}
            >
              {CAPABILITIES[Math.max(0, activeWord)]}
            </span>
          </div>
        </motion.div>
      </div>
    </section>
  );
}

/* ------------------------------------------------------------------ */
/* Reduced-motion fallback                                             */
/* ------------------------------------------------------------------ */

function EcosystemStatic({ theme }) {
  return (
    <section className="relative py-20 px-6 sm:px-10 overflow-hidden">
      <AmbientBackground theme={theme} animate={false} particleCount={0} />

      <div className="relative z-10 max-w-3xl mx-auto text-center">
        <BrandEyebrow theme={theme} className="mb-5" />
        <h2
          className="font-display font-extrabold leading-[1.02] text-[11vw] sm:text-5xl tracking-tight"
          style={{ color: theme.heading }}
        >
          THE WORKFORCE,{' '}
          <span className={`bg-gradient-to-r ${theme.gradientText} bg-clip-text text-transparent`}>
            CONNECTED.
          </span>
        </h2>
        <p className="mt-4 text-sm sm:text-base" style={{ color: theme.body }}>
          One intelligent ecosystem for every side of modern work.
        </p>

        <div className="mt-10 flex items-center justify-center">
          <div className="relative w-24 h-24 rounded-full flex items-center justify-center">
            <div
              className="absolute inset-2 rounded-full backdrop-blur-xl"
              style={{ background: theme.coreFace, border: `1px solid ${theme.coreBorder}` }}
            />
            <span
              className="relative z-10 font-display font-extrabold text-lg"
              style={{ color: theme.heading }}
            >
              AR
            </span>
          </div>
        </div>
      </div>

      <div className="relative z-10 mt-12 max-w-3xl mx-auto grid grid-cols-1 sm:grid-cols-2 gap-3">
        {ECOSYSTEM_NODES.map((node) => (
          <NodeCard key={node.id} node={node} isActive theme={theme} compact />
        ))}
      </div>

      <div className="relative z-10 mt-10 max-w-3xl mx-auto flex flex-wrap justify-center gap-x-4 gap-y-2">
        {CAPABILITIES.map((word) => (
          <span key={word} className="text-xs font-bold tracking-wide" style={{ color: theme.muted }}>
            {word}
          </span>
        ))}
      </div>
    </section>
  );
}

/* ------------------------------------------------------------------ */
/* Stage 3 -- CTA + metadata                                           */
/* ------------------------------------------------------------------ */

function FooterCTA({ theme, reduceMotion }) {
  const motionProps = reduceMotion
    ? {}
    : {
        initial: { opacity: 0, y: 24 },
        whileInView: { opacity: 1, y: 0 },
        viewport: { once: true, amount: 0.4 },
        transition: { duration: 0.6, ease: 'easeOut' },
      };

  return (
    <motion.section
      className="relative z-10 py-24 sm:py-28 px-6 text-center border-t"
      style={{ background: theme.base, borderColor: theme.hairline }}
      {...motionProps}
    >
      <h3
        className="font-display font-extrabold text-[9vw] sm:text-5xl lg:text-6xl leading-[1.05] tracking-tight"
        style={{ color: theme.heading }}
      >
        READY TO CONNECT
        <br />
        YOUR WORKFORCE?
      </h3>
      <p className="mt-5 text-sm sm:text-base" style={{ color: theme.body }}>
        One platform. Multiple portals. Intelligent workflows.
      </p>

      <div className="mt-9 flex flex-col sm:flex-row items-center justify-center gap-4">
        <button
          onClick={scrollToPortalGrid}
          className="group inline-flex items-center gap-2 px-7 py-3.5 rounded-full text-sm font-bold text-white shadow-lg shadow-indigo-600/30 transition-transform duration-200 hover:scale-[1.03]"
          style={{ background: 'linear-gradient(135deg, #6366f1, #8b5cf6)' }}
        >
          EXPLORE ARDHNARISHWAR
          <ArrowRight className="w-4 h-4 transition-transform duration-200 group-hover:translate-x-1" />
        </button>
        <button
          onClick={launchEmployeePortal}
          className="inline-flex items-center gap-2 px-7 py-3.5 rounded-full text-sm font-bold border backdrop-blur-xl transition-transform duration-200 hover:scale-[1.03]"
          style={{ color: theme.heading, borderColor: theme.hairline, background: theme.surface }}
        >
          GET STARTED
          <ArrowUpRight className="w-4 h-4" />
        </button>
      </div>
    </motion.section>
  );
}

function FooterMeta({ theme }) {
  const groups = LINK_GROUPS.filter((g) => g.links.length > 0);

  return (
    <div
      className="relative z-10 border-t"
      style={{ background: theme.base, borderColor: theme.hairline }}
    >
      <div className="max-w-[1536px] mx-auto px-6 sm:px-10 py-10 grid grid-cols-2 sm:grid-cols-4 gap-8">
        <div className="col-span-2 sm:col-span-1">
          <div className="flex items-center gap-2.5 mb-3">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-brand-orange to-orange-600 flex items-center justify-center text-white font-display font-extrabold text-sm">
              A
            </div>
            <span className="font-display font-bold text-sm" style={{ color: theme.heading }}>
              Ardhnarishwar
            </span>
          </div>
          <p className="text-xs leading-relaxed" style={{ color: theme.muted }}>
            © 2026 Ardhnarishwar HRMS
            <br />
            Unified Multi-Portal Platform
          </p>
        </div>

        {groups.map((group) => (
          <div key={group.title}>
            <h4 className="text-[11px] font-bold tracking-[0.15em] mb-3" style={{ color: theme.body }}>
              {group.title}
            </h4>
            <ul className="space-y-2">
              {group.links.map((link) => (
                <li key={link.label}>
                  <button
                    onClick={link.onClick}
                    className="text-xs text-left transition-opacity duration-200 opacity-80 hover:opacity-100"
                    style={{ color: theme.muted }}
                  >
                    {link.label}
                  </button>
                </li>
              ))}
            </ul>
          </div>
        ))}

        <div className="col-span-2 sm:col-span-2 sm:text-right">
          <h4 className="text-[11px] font-bold tracking-[0.15em] mb-3" style={{ color: theme.body }}>
            SHARED BACKEND
          </h4>
          <code
            className="inline-block px-2.5 py-1 rounded text-xs"
            style={{ background: theme.surface, color: theme.muted }}
          >
            https://ardhnarishwar-hrms-backend.recruweb.com
          </code>
        </div>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Root export                                                         */
/* ------------------------------------------------------------------ */

export default function Footer({ isDark = true }) {
  const reduceMotion = useReducedMotion();
  const isDesktop = useMediaQuery('(min-width: 1024px)');
  const theme = useFooterTheme(isDark);

  return (
    // Deliberately NOT `overflow-hidden`: that would clip-contain the sticky
    // cinematic viewport and kill the whole scroll sequence. Horizontal bleed
    // from the -50vw pull is handled by `overflow-x: clip` on <body>.
    <footer
      className="relative left-1/2 right-1/2 w-screen -ml-[50vw] -mr-[50vw] mt-20"
      style={{ background: theme.base, color: theme.heading }}
    >
      {reduceMotion ? (
        <EcosystemStatic theme={theme} />
      ) : isDesktop ? (
        <WorkforceEcosystemDesktop theme={theme} />
      ) : (
        <WorkforceEcosystemMobile theme={theme} />
      )}

      <FooterCTA theme={theme} reduceMotion={reduceMotion} />
      <FooterMeta theme={theme} />
    </footer>
  );
}