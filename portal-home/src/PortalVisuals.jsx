import React from 'react';

export default function PortalVisuals({ portalKey, isDark }) {
  let visual;

  switch (portalKey) {
    case 'employee':
      visual = (
        <div className="relative w-44 h-36 flex items-center justify-center pointer-events-none select-none">
          {/* 3D Circular Pedestal Stage */}
          <div className={`absolute bottom-0 w-36 h-9 rounded-[50%] blur-md opacity-70 ${isDark ? 'bg-blue-500/50 shadow-[0_0_20px_#3b82f6]' : 'bg-blue-400/40'}`} />
          <div className={`absolute bottom-1 w-32 h-7 rounded-[50%] border-2 ${isDark ? 'bg-gradient-to-r from-blue-900/60 to-slate-900/80 border-blue-400/80' : 'bg-blue-50 border-blue-300'}`} />

          {/* 3D Visual Group */}
          <div className="relative z-10 flex items-center gap-2 transform -translate-y-2">
            {/* 3D Avatar Person */}
            <div className="w-13 h-18 rounded-2xl bg-gradient-to-b from-blue-400 via-blue-500 to-blue-700 p-1.5 shadow-2xl shadow-blue-500/40 flex flex-col items-center justify-center transform -rotate-6 border border-white/40">
              <div className="w-7 h-7 rounded-full bg-blue-100 mb-1 border-2 border-white/60 shadow-inner" />
              <div className="w-10 h-8 rounded-t-xl bg-blue-200/90 shadow-inner" />
            </div>

            {/* 3D ID Document Card */}
            <div className={`w-18 h-22 rounded-2xl p-2.5 shadow-2xl border-2 flex flex-col justify-between transform rotate-3 ${
              isDark ? 'bg-gradient-to-b from-slate-800 to-slate-900 border-blue-400/50 shadow-blue-500/20' : 'bg-white border-blue-200 shadow-blue-200'
            }`}>
              <div className="flex items-center gap-2 mb-1">
                <div className="w-5 h-5 rounded-full bg-blue-500 flex items-center justify-center text-white text-[9px] font-bold">👤</div>
                <div className="w-9 h-2 rounded bg-blue-400/50" />
              </div>
              <div className="w-12 h-1.5 rounded bg-slate-400/30 mb-1" />
              <div className="w-10 h-1.5 rounded bg-slate-400/30 mb-1" />
              <div className="w-13 h-1.5 rounded bg-slate-400/30 mb-1" />
              <div className="w-5 h-5 rounded-full bg-emerald-500 flex items-center justify-center text-white text-xs font-bold self-end shadow-lg shadow-emerald-500/50">
                ✓
              </div>
            </div>
          </div>
        </div>
      );

    case 'hr':
      visual = (
        <div className="relative w-44 h-36 flex items-center justify-center pointer-events-none select-none">
          {/* 3D Pedestal Stage */}
          <div className={`absolute bottom-0 w-36 h-9 rounded-[50%] blur-md opacity-70 ${isDark ? 'bg-purple-500/50 shadow-[0_0_20px_#a855f7]' : 'bg-purple-400/40'}`} />
          <div className={`absolute bottom-1 w-32 h-7 rounded-[50%] border-2 ${isDark ? 'bg-gradient-to-r from-purple-900/60 to-slate-900/80 border-purple-400/80' : 'bg-purple-50 border-purple-300'}`} />

          <div className="relative z-10 flex items-center justify-center transform -translate-y-2">
            {/* 3D Clipboard */}
            <div className={`w-20 h-24 rounded-2xl p-3 shadow-2xl border-2 flex flex-col gap-2 transform -rotate-6 ${
              isDark ? 'bg-gradient-to-b from-slate-800 to-slate-900 border-purple-400/50 shadow-purple-500/20' : 'bg-white border-purple-200 shadow-purple-200'
            }`}>
              <div className="w-8 h-2.5 rounded-t-lg bg-purple-600 self-center -mt-4 shadow-md border-b border-purple-300" />
              <div className="flex items-center gap-2 mt-1">
                <div className="w-4 h-4 rounded-md bg-purple-500 flex items-center justify-center text-white text-[9px] font-bold shadow">✓</div>
                <div className="w-10 h-2 rounded bg-purple-300/60" />
              </div>
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 rounded-md bg-purple-500 flex items-center justify-center text-white text-[9px] font-bold shadow">✓</div>
                <div className="w-11 h-2 rounded bg-purple-300/60" />
              </div>
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 rounded-md bg-purple-400/30" />
                <div className="w-8 h-2 rounded bg-slate-400/30" />
              </div>
            </div>

            {/* 3D Group Users */}
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-purple-600 to-indigo-500 -ml-5 mt-6 shadow-xl shadow-purple-600/40 flex items-center justify-center text-white text-lg font-bold border-2 border-white/40 transform rotate-6">
              👥
            </div>
          </div>
        </div>
      );

    case 'it':
      visual = (
        <div className="relative w-44 h-36 flex items-center justify-center pointer-events-none select-none">
          {/* 3D Pedestal Stage */}
          <div className={`absolute bottom-0 w-36 h-9 rounded-[50%] blur-md opacity-70 ${isDark ? 'bg-cyan-500/50 shadow-[0_0_20px_#06b6d4]' : 'bg-cyan-400/40'}`} />
          <div className={`absolute bottom-1 w-32 h-7 rounded-[50%] border-2 ${isDark ? 'bg-gradient-to-r from-cyan-900/60 to-slate-900/80 border-cyan-400/80' : 'bg-cyan-50 border-cyan-300'}`} />

          <div className="relative z-10 flex flex-col items-center transform -translate-y-2">
            {/* 3D Cloud & Gear floating */}
            <div className="flex items-center gap-1 self-end -mr-1 -mb-3 z-20">
              <div className="w-9 h-6 rounded-full bg-gradient-to-r from-cyan-400 to-blue-500 shadow-lg shadow-cyan-400/50 border border-white/40 flex items-center justify-center text-white text-xs">
                ☁
              </div>
              <div className="w-7 h-7 rounded-full bg-gradient-to-tr from-cyan-500 to-teal-400 shadow-md flex items-center justify-center text-white text-xs animate-spin-slow">
                ⚙
              </div>
            </div>

            {/* 3D Laptop Screen */}
            <div className="w-24 h-16 rounded-t-2xl bg-gradient-to-tr from-slate-950 via-slate-900 to-cyan-950 p-2 border-2 border-cyan-400/70 shadow-2xl shadow-cyan-500/30 flex items-center justify-center">
              <span className="font-mono text-cyan-300 font-extrabold text-base tracking-widest drop-shadow-[0_0_8px_#06b6d4]">&lt;/&gt;</span>
            </div>
            {/* Laptop Base Keyboard */}
            <div className="w-28 h-3 rounded-b-xl bg-gradient-to-r from-slate-700 via-cyan-600 to-slate-700 shadow-xl border-t border-cyan-300/40" />
          </div>
        </div>
      );

    case 'sales':
      visual = (
        <div className="relative w-44 h-36 flex items-center justify-center pointer-events-none select-none">
          {/* 3D Pedestal Stage */}
          <div className={`absolute bottom-0 w-36 h-9 rounded-[50%] blur-md opacity-70 ${isDark ? 'bg-amber-500/50 shadow-[0_0_20px_#f59e0b]' : 'bg-amber-400/40'}`} />
          <div className={`absolute bottom-1 w-32 h-7 rounded-[50%] border-2 ${isDark ? 'bg-gradient-to-r from-amber-900/60 to-slate-900/80 border-amber-400/80' : 'bg-amber-50 border-amber-300'}`} />

          <div className="relative z-10 flex items-end gap-2 transform -translate-y-2">
            {/* 3D Target Board */}
            <div className="w-16 h-16 rounded-full bg-gradient-to-tr from-amber-500 via-orange-500 to-red-500 p-2 shadow-2xl shadow-amber-500/40 flex items-center justify-center border-2 border-white/50 transform -rotate-12">
              <div className="w-11 h-11 rounded-full bg-white flex items-center justify-center shadow-inner">
                <div className="w-7 h-7 rounded-full bg-amber-600 flex items-center justify-center shadow-inner">
                  <div className="w-3 h-3 rounded-full bg-white flex items-center justify-center">
                    <div className="w-1.5 h-1.5 rounded-full bg-amber-600" />
                  </div>
                </div>
              </div>
            </div>

            {/* 3D Growth Chart Bars & Arrow */}
            <div className="flex items-end gap-1.5 mb-1 bg-amber-900/20 p-2 rounded-xl border border-amber-500/30 backdrop-blur-md">
              <div className="w-3 h-6 rounded-t-md bg-gradient-to-t from-amber-600 to-amber-400 shadow-sm" />
              <div className="w-3 h-10 rounded-t-md bg-gradient-to-t from-amber-600 to-amber-400 shadow-sm" />
              <div className="w-3 h-14 rounded-t-md bg-gradient-to-t from-orange-600 to-amber-300 shadow-md" />
              <div className="text-amber-400 text-sm font-bold ml-0.5 -mt-3">↗</div>
            </div>
          </div>
        </div>
      );

    case 'client':
      visual = (
        <div className="relative w-44 h-36 flex items-center justify-center pointer-events-none select-none">
          {/* 3D Pedestal Stage */}
          <div className={`absolute bottom-0 w-36 h-9 rounded-[50%] blur-md opacity-70 ${isDark ? 'bg-emerald-500/50 shadow-[0_0_20px_#10b981]' : 'bg-emerald-400/40'}`} />
          <div className={`absolute bottom-1 w-32 h-7 rounded-[50%] border-2 ${isDark ? 'bg-gradient-to-r from-emerald-900/60 to-slate-900/80 border-emerald-400/80' : 'bg-emerald-50 border-emerald-300'}`} />

          <div className="relative z-10 flex flex-col items-center transform -translate-y-2">
            {/* 3D Shaking Hands Badge */}
            <div className="w-20 h-20 rounded-3xl bg-gradient-to-tr from-emerald-600 via-teal-500 to-emerald-400 p-3 shadow-2xl shadow-emerald-500/40 border-2 border-white/50 flex flex-col items-center justify-center text-3xl">
              🤝
            </div>
          </div>
        </div>
      );

    case 'aiRobotics':
      visual = (
        <div className="relative w-44 h-36 flex items-center justify-center pointer-events-none select-none">
          {/* 3D Pedestal Stage */}
          <div className={`absolute bottom-0 w-36 h-9 rounded-[50%] blur-md opacity-70 ${isDark ? 'bg-violet-500/50 shadow-[0_0_20px_#8b5cf6]' : 'bg-purple-400/40'}`} />
          <div className={`absolute bottom-1 w-32 h-7 rounded-[50%] border-2 ${isDark ? 'bg-gradient-to-r from-violet-900/60 to-slate-900/80 border-violet-400/80' : 'bg-purple-50 border-purple-300'}`} />

          <div className="relative z-10 flex items-center gap-2 transform -translate-y-2">
            {/* 3D Robot Mascot */}
            <div className="w-16 h-18 rounded-2xl bg-gradient-to-b from-violet-400 via-purple-600 to-indigo-700 p-2 shadow-2xl shadow-purple-500/50 border-2 border-white/50 flex flex-col items-center justify-center">
              <div className="flex gap-2 mb-1.5">
                <div className="w-3 h-3 rounded-full bg-cyan-300 animate-pulse shadow-[0_0_8px_#67e8f9]" />
                <div className="w-3 h-3 rounded-full bg-cyan-300 animate-pulse shadow-[0_0_8px_#67e8f9]" />
              </div>
              <div className="w-8 h-2 rounded-full bg-slate-900/80" />
            </div>

            {/* Video Player Card */}
            <div className={`w-14 h-16 rounded-2xl p-1.5 shadow-xl border-2 flex flex-col items-center justify-center transform rotate-6 ${
              isDark ? 'bg-slate-800/90 border-purple-400/40 shadow-purple-500/20' : 'bg-white border-purple-200 shadow-purple-200'
            }`}>
              <div className="w-8 h-8 rounded-full bg-gradient-to-r from-purple-600 to-indigo-600 flex items-center justify-center text-white text-xs pl-0.5 shadow-md">
                ▶
              </div>
            </div>
          </div>
        </div>
      );

    case 'smartAttendance':
      visual = (
        <div className="relative w-44 h-36 flex items-center justify-center pointer-events-none select-none">
          {/* 3D Pedestal Stage */}
          <div className={`absolute bottom-0 w-36 h-9 rounded-[50%] blur-md opacity-70 ${isDark ? 'bg-pink-500/50 shadow-[0_0_20px_#ec4899]' : 'bg-pink-400/40'}`} />
          <div className={`absolute bottom-1 w-32 h-7 rounded-[50%] border-2 ${isDark ? 'bg-gradient-to-r from-pink-900/60 to-slate-900/80 border-pink-400/80' : 'bg-pink-50 border-pink-300'}`} />

          <div className="relative z-10 flex items-center justify-center transform -translate-y-2">
            {/* 3D AI Chip */}
            <div className="w-20 h-20 rounded-3xl bg-gradient-to-tr from-pink-600 via-rose-500 to-purple-600 p-3 shadow-2xl shadow-pink-500/50 border-2 border-white/50 flex flex-col items-center justify-center">
              <span className="font-display font-extrabold text-white text-xl tracking-wider drop-shadow-[0_0_8px_rgba(255,255,255,0.8)]">AI</span>
              <span className="text-[10px] text-pink-200 font-bold uppercase tracking-widest mt-0.5">TOOL</span>
            </div>

            {/* Orbiting UI Nodes */}
            <div className="absolute -top-2 -right-2 w-7 h-7 rounded-lg bg-gradient-to-r from-purple-500 to-pink-500 shadow-lg flex items-center justify-center text-white text-[10px] border border-white/40">
              📊
            </div>
            <div className="absolute -bottom-2 -left-2 w-7 h-7 rounded-lg bg-gradient-to-r from-rose-500 to-pink-500 shadow-lg flex items-center justify-center text-white text-[10px] border border-white/40">
              🖼️
            </div>
          </div>
        </div>
      );

    case 'evs':
      visual = (
        <div className="relative w-44 h-36 flex items-center justify-center pointer-events-none select-none">
          {/* 3D Pedestal Stage */}
          <div className={`absolute bottom-0 w-36 h-9 rounded-[50%] blur-md opacity-70 ${isDark ? 'bg-blue-600/50 shadow-[0_0_20px_#2563eb]' : 'bg-blue-400/40'}`} />
          <div className={`absolute bottom-1 w-32 h-7 rounded-[50%] border-2 ${isDark ? 'bg-gradient-to-r from-blue-900/60 to-slate-900/80 border-blue-400/80' : 'bg-blue-50 border-blue-300'}`} />

          <div className="relative z-10 flex items-center justify-center transform -translate-y-2">
            {/* 3D Shield */}
            <div className="w-20 h-22 rounded-b-[40px] rounded-t-xl bg-gradient-to-b from-blue-400 via-blue-600 to-indigo-800 p-3 shadow-2xl shadow-blue-500/50 border-2 border-white/60 flex flex-col items-center justify-center">
              <div className="w-10 h-10 rounded-xl bg-white/20 backdrop-blur-md flex items-center justify-center text-xl shadow-inner border border-white/40">
                🔒
              </div>
            </div>
          </div>
        </div>
      );

    default:
      return null;
  }

  return (
    <div className="portal-visual-3d-scene" aria-hidden="true">
      <div className="portal-visual-3d-bounce">
        {visual}
      </div>
    </div>
  );
}
