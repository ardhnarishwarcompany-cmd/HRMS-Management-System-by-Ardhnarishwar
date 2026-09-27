import React, { useState, useEffect } from 'react';
import portalLogo from '../assets/brand/portal-logo.png';
import { Clock, Sun, Moon } from 'lucide-react';

export default function Navbar({ theme, toggleTheme }) {
  const [timeStr, setTimeStr] = useState('--:-- --');

  useEffect(() => {
    const updateTime = () => {
      const d = new Date();
      let h = d.getHours();
      const m = String(d.getMinutes()).padStart(2, '0');
      const ampm = h >= 12 ? 'PM' : 'AM';
      h = h % 12 || 12;
      setTimeStr(`${String(h).padStart(2, '0')}:${m} ${ampm}`);
    };
    updateTime();
    const interval = setInterval(updateTime, 10000);
    return () => clearInterval(interval);
  }, []);

  const isDark = theme === 'dark';

  return (
    <header className={`flex items-center justify-between p-4 sm:p-5 rounded-2xl backdrop-blur-xl border mb-10 shadow-2xl transition-colors duration-300 ${
      isDark ? 'bg-slate-900/70 border-white/10' : 'bg-white/80 border-slate-200/80 shadow-slate-200/50'
    }`}>
      {/* Brand Identification */}
      <div className="flex items-center gap-3.5">
        <div className="navbar-logo-wrap" aria-label="Ardhnarishwar HRMS">
          <span className="navbar-logo-glow" aria-hidden="true" />
          <span className="navbar-logo-ring navbar-logo-ring-a" aria-hidden="true" />
          <span className="navbar-logo-ring navbar-logo-ring-b" aria-hidden="true" />
          <div className="navbar-logo-3d">
            <img
              src={portalLogo}
              alt=""
              className="navbar-logo-image"
              draggable={false}
            />
          </div>
        </div>
        <div>
          <h1 className={`font-display font-bold text-lg leading-tight ${isDark ? 'text-white' : 'text-slate-900'}`}>
            Ardhnarishwar <span className="text-brand-orange">HRMS</span>
          </h1>
          <p className={`text-xs font-medium ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>Central Enterprise Hub</p>
        </div>
      </div>

      {/* Right Controls: Operational Badge, Live Clock & Theme Toggle */}
      <div className="flex items-center gap-3">
        <div className="hidden sm:flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-emerald-500 text-xs font-semibold">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse shadow-[0_0_8px_#10b981]" />
          <span>All 8 Sub-Portals Online</span>
        </div>

        <div className={`hidden md:flex items-center gap-2 px-3.5 py-1.5 rounded-full border text-xs font-semibold ${
          isDark ? 'bg-white/5 border-white/10 text-slate-300' : 'bg-slate-100 border-slate-200 text-slate-700'
        }`}>
          <Clock className="w-3.5 h-3.5 text-slate-400" />
          <span>{timeStr}</span>
        </div>

        {/* Light / Dark Mode Toggle */}
        <button
          onClick={toggleTheme}
          title={`Switch to ${isDark ? 'Light' : 'Dark'} Theme`}
          className={`flex items-center gap-2 px-3.5 py-2 rounded-xl border text-xs font-bold transition-all duration-300 ${
            isDark
              ? 'bg-slate-800/80 border-slate-700 text-amber-300 hover:bg-slate-700/80'
              : 'bg-slate-100 border-slate-200 text-slate-800 hover:bg-slate-200'
          }`}
        >
          {isDark ? (
            <>
              <Sun className="w-4 h-4 text-amber-400" />
              <span className="hidden sm:inline">Light Mode</span>
            </>
          ) : (
            <>
              <Moon className="w-4 h-4 text-indigo-600" />
              <span className="hidden sm:inline">Dark Mode</span>
            </>
          )}
        </button>
      </div>
    </header>
  );
}
