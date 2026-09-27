import React, { useRef } from 'react';
import { motion, useReducedMotion } from 'framer-motion';
import {
  ArrowRight,
  ArrowUpRight,
  ShieldCheck,
  Cpu,
  Sparkles,
  Building2,
  User,
  Users,
  Briefcase,
  FileText,
} from 'lucide-react';
import PortalVisuals from './3D/PortalVisuals';
import {
  useCardScrollProgress,
  usePointerTilt,
  useMediaQuery,
} from '../hooks/useCardMotion';

const ICON_MAP = {
  admin: ShieldCheck,
  employee: User,
  hr: Users,
  it: Cpu,
  sales: Briefcase,
  client: Building2,
  aiRobotics: Sparkles,
  smartAttendance: Cpu,
  evs: FileText,
};

export default function PortalCard({ portal, resolveUrl, isDark, index = 0, number = 1 }) {
  const cardRef = useRef(null);
  const reduceMotion = useReducedMotion();

  // Tilt + the pointer indicator are desktop-with-a-real-pointer only.
  const canHover = useMediaQuery('(hover: hover) and (pointer: fine)');
  const isDesktop = useMediaQuery('(min-width: 1024px)');
  const enableTilt = canHover && isDesktop && !reduceMotion;

  useCardScrollProgress(cardRef, { enabled: !reduceMotion });
  usePointerTilt(cardRef, { enabled: enableTilt });

  const Icon = ICON_MAP[portal.key] || ShieldCheck;
  const targetUrl = resolveUrl(portal.key);
  const reversed = index % 2 === 1;

  // Existing behaviour, unchanged: portals are separate apps reached by URL.
  const launch = () => window.open(targetUrl, '_blank', 'noopener');

  return (
    <motion.article
      // Framer Motion here only handles grid enter/exit when the filter or
      // search changes -- AnimatePresence needs it. All scroll-linked motion
      // is GSAP-driven CSS variables, so the two systems never touch the same
      // property.
      layout={!reduceMotion}
      initial={reduceMotion ? false : { opacity: 0, scale: 0.97 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={reduceMotion ? undefined : { opacity: 0, scale: 0.95, transition: { duration: 0.15 } }}
      transition={{ duration: 0.25, ease: 'easeOut' }}
      className="solution-card-outer"
    >
      <div
        ref={cardRef}
        className={`solution-card group ${reversed ? 'is-reversed' : ''} ${
          isDark ? 'is-dark' : 'is-light'
        }`}
        style={{
          '--accent': portal.accentColor,
          '--card-shadow': isDark
            ? portal.shadowDark || 'rgba(99,102,241,0.3)'
            : portal.shadowLight || 'rgba(99,102,241,0.2)',
        }}
        onClick={launch}
      >
        {/* Layer 1 -- oversized outlined service number */}
        <span className="card-number" aria-hidden="true">
          {String(number).padStart(2, '0')}
        </span>

        {/* Layer 2 -- accent bloom that strengthens as the card activates */}
        <span className="card-glow" aria-hidden="true" />

        {/* Layer 3 -- content + visual, order flips on alternating cards */}
        <div className="card-body">
          <div className="card-content">
            <div className="card-head">
              <span className="card-icon" style={{ background: portal.gradient }}>
                <Icon className="w-5 h-5" aria-hidden="true" />
              </span>
              <span
                className={`card-category ${
                  isDark ? portal.badgeStyleDark : portal.badgeStyleLight
                }`}
              >
                {portal.badge}
              </span>
            </div>

            <div className="card-title-mask reveal" style={{ '--d': 0.12 }}>
              <h3 className="card-title">{portal.name}</h3>
            </div>

            <p className="card-desc reveal" style={{ '--d': 0.24 }}>
              {portal.desc}
            </p>

            <div className="card-foot reveal" style={{ '--d': 0.36 }}>
              <span className="card-status">
                <span className="card-status-dot" aria-hidden="true" />
                Operational
              </span>

              <button
                type="button"
                className="card-cta"
                style={{ background: portal.btnBg }}
                onClick={(e) => {
                  e.stopPropagation();
                  launch();
                }}
              >
                <span>Launch Portal</span>
                <ArrowRight className="card-cta-arrow w-3.5 h-3.5" aria-hidden="true" />
              </button>
            </div>
          </div>

          <div className="card-visual-slot">
            <PortalVisuals
              portalKey={portal.key}
              portalName={portal.name}
              accentColor={portal.accentColor}
              isDark={isDark}
            />
          </div>
        </div>

        {/* Layer 4 -- corner arrow + pointer-following indicator */}
        <span className="card-arrow" aria-hidden="true">
          <ArrowUpRight className="w-4 h-4" />
        </span>

        {enableTilt && (
          <span className="card-pointer-label" aria-hidden="true">
            EXPLORE
          </span>
        )}
      </div>
    </motion.article>
  );
}