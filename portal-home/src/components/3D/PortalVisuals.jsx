import React from 'react';

import employeeImg from '../../assets/portal-visuals/employee.jpg';
import hrImg from '../../assets/portal-visuals/hr.jpg';
import itImg from '../../assets/portal-visuals/it.jpg';
import salesImg from '../../assets/portal-visuals/sales.jpg';
import clientImg from '../../assets/portal-visuals/client.jpg';
import aiRoboticsImg from '../../assets/portal-visuals/aiRobotics.jpg';
import smartAttendanceImg from '../../assets/portal-visuals/smartAttendance.jpg';
import evsImg from '../../assets/portal-visuals/evs.jpg';

// Rendered hero art per portal, generated to match each card's accent color
// and the podium/glow style used across the dashboard.
const VISUALS = {
  employee: employeeImg,
  hr: hrImg,
  it: itImg,
  sales: salesImg,
  client: clientImg,
  aiRobotics: aiRoboticsImg,
  smartAttendance: smartAttendanceImg,
  evs: evsImg,
};

/**
 * Fallback for portals without artwork: an abstract accent-tinted composition
 * of concentric rings, so every card keeps the same visual weight.
 */
function AbstractVisual({ accentColor }) {
  return (
    <div
      className="w-full h-full rounded-3xl relative overflow-hidden"
      style={{
        background: `radial-gradient(circle at 35% 30%, ${accentColor}33, transparent 70%)`,
      }}
      aria-hidden="true"
    >
      {[0, 1, 2].map((i) => (
        <span
          key={i}
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 rounded-full"
          style={{
            width: `${40 + i * 24}%`,
            height: `${40 + i * 24}%`,
            border: `1px solid ${accentColor}`,
            opacity: 0.35 - i * 0.09,
          }}
        />
      ))}
      <span
        className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-3 h-3 rounded-full"
        style={{ background: accentColor, boxShadow: `0 0 18px 4px ${accentColor}` }}
      />
    </div>
  );
}

export default function PortalVisuals({ portalKey, portalName, accentColor, isDark }) {
  const src = VISUALS[portalKey];

  return (
    <div className="card-visual relative w-full aspect-square max-w-[190px] mx-auto pointer-events-none select-none">
      {/* Accent bloom sitting behind the artwork, strengthens with scroll. */}
      <div
        className="card-visual-glow absolute -inset-6 rounded-full blur-2xl"
        style={{ background: `radial-gradient(circle, ${accentColor}55, transparent 70%)` }}
        aria-hidden="true"
      />

      <div className="card-visual-float relative w-full h-full">
        <div
          className={`card-visual-inner relative w-full h-full rounded-3xl overflow-hidden shadow-2xl ${
            isDark ? 'ring-1 ring-white/10' : 'ring-1 ring-black/5'
          }`}
        >
          <span className="card-visual-depth" aria-hidden="true" />
          <span className="card-visual-shine" aria-hidden="true" />
          {src ? (
            <img
              src={src}
              alt={`${portalName} portal preview`}
              loading="lazy"
              decoding="async"
              draggable={false}
              className="card-visual-image w-full h-full object-cover"
            />
          ) : (
            <AbstractVisual accentColor={accentColor} />
          )}
        </div>
      </div>
    </div>
  );
}