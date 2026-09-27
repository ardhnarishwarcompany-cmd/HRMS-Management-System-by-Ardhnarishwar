import React from 'react';

/**
 * GlowBorderCard - CSS-only animated glowing border wrapper.
 * Defaults to width 100% and height auto so it works inside a responsive grid.
 */

const colorPresets = {
  nature: ['#669900', '#88bb22', '#99cc33', '#aaddaa', '#ccee66', '#006699', '#228888', '#3399cc', '#55aacc', '#669900'],
  ocean: ['#006699', '#1177aa', '#2288bb', '#3399cc', '#44aadd', '#55bbee', '#66ccff', '#44bbee', '#2299cc', '#006699'],
  sunset: ['#ff6600', '#ff7711', '#ff8822', '#ff9900', '#ffaa22', '#ffbb44', '#ffcc00', '#ff9933', '#ff7722', '#ff6600'],
  aurora: ['#00ff87', '#22ffaa', '#44ffcc', '#60efff', '#88ddff', '#bb99ff', '#dd77ee', '#ff68f0', '#ff55cc', '#00ff87'],
  custom: ['#669900', '#99cc33', '#ccee66', '#006699', '#3399cc', '#990066', '#cc3399', '#ff6600', '#ff9900', '#ffcc00'],
};

function cx(...classes) {
  return classes.filter(Boolean).join(' ');
}

function GlowBorderCard({
  children,
  className,
  width = '100%',
  height = 'auto',
  borderRadius = '28px',
  animationDuration = 4,
  gradientColors,
  borderWidth = '0.6em',
  blurAmount = '0.9em',
  inset = '-0.5em',
  colorPreset = 'custom',
  paused = false,
  style,
  ...props
}) {
  const colors = gradientColors || colorPresets[colorPreset] || colorPresets.custom;

  const colorVars = {};
  for (let i = 0; i < 10; i++) {
    colorVars[`--glow-color-${i + 1}`] = colors[i % colors.length];
  }

  return (
    <div
      className={cx('relative isolate', className)}
      style={{
        width,
        height,
        borderRadius,
        '--glow-animation-duration': `${animationDuration}s`,
        ...colorVars,
        ...style,
      }}
      {...props}
    >
      <div
        className={cx('absolute -z-10 rounded-[inherit] glow-conic', paused && 'glow-paused')}
        style={{ inset, borderWidth, filter: `blur(${blurAmount})` }}
      />
      <div className="relative z-10 w-full h-auto">{children}</div>
    </div>
  );
}

export default GlowBorderCard;