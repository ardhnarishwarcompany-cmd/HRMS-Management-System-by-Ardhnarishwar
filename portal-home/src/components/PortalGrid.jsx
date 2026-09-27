import React from 'react';
import { AnimatePresence } from 'framer-motion';
import PortalCard from './PortalCard';
import { PORTALS } from '../data/portals';
import { useScrollTriggerRefresh } from '../hooks/useCardMotion';

/**
 * Stable 01..08 numbering: taken from the canonical PORTALS order, not from
 * the filtered index, so a card keeps its number when filters change.
 */
const NUMBER_BY_KEY = PORTALS.reduce((acc, p, i) => {
  acc[p.key] = i + 1;
  return acc;
}, {});

export default function PortalGrid({ portals, resolveUrl, isDark }) {
  // The grid reflows when a filter or search removes cards; ScrollTrigger
  // caches element positions, so it has to re-measure afterwards.
  useScrollTriggerRefresh(portals.length);

  return (
    <div className="relative" id="portal-grid">
      {/* Unified-ecosystem spine: one thin line behind the grid, lg+ only. */}
      <span className="portal-connector" aria-hidden="true" />

      <main className="relative grid grid-cols-1 lg:grid-cols-2 gap-6">
        <AnimatePresence mode="popLayout">
          {portals.map((portal, index) => (
            <PortalCard
              key={portal.key}
              portal={portal}
              resolveUrl={resolveUrl}
              isDark={isDark}
              index={index}
              number={NUMBER_BY_KEY[portal.key] ?? index + 1}
            />
          ))}
        </AnimatePresence>
      </main>
    </div>
  );
}