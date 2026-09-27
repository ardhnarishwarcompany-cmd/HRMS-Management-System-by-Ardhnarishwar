import React, { useEffect, useRef } from 'react';

export default function HeroSection({ isDark }) {
  const typingRef = useRef(null);

  useEffect(() => {
    const words = [
      "Workforce Operations",
      "HR & Talent Recruitment",
      "IT & Engineering Teams",
      "Sales & Client Growth",
      "AI Verification & Attendance"
    ];
    let wordIdx = 0;
    let charIdx = 0;
    let isDeleting = false;
    let timeoutId;

    function typeEffect() {
      const currentWord = words[wordIdx];
      if (typingRef.current) {
        if (isDeleting) {
          typingRef.current.textContent = currentWord.substring(0, charIdx - 1);
          charIdx--;
        } else {
          typingRef.current.textContent = currentWord.substring(0, charIdx + 1);
          charIdx++;
        }
      }

      let speed = isDeleting ? 40 : 80;

      if (!isDeleting && charIdx === currentWord.length) {
        speed = 2200;
        isDeleting = true;
      } else if (isDeleting && charIdx === 0) {
        isDeleting = false;
        wordIdx = (wordIdx + 1) % words.length;
        speed = 500;
      }

      timeoutId = setTimeout(typeEffect, speed);
    }

    typeEffect();
    return () => clearTimeout(timeoutId);
  }, []);

  return (
    <section className="text-center max-w-3xl mx-auto mb-10">
      <div className={`inline-flex items-center gap-2 px-4 py-1.5 rounded-full border text-xs font-semibold mb-5 ${
        isDark
          ? 'bg-purple-500/15 border-purple-500/30 text-purple-300'
          : 'bg-purple-100 border-purple-200 text-purple-700'
      }`}>
        <span>⚡ Unified Enterprise Platform</span>
      </div>

      <h2 className={`font-display text-3xl sm:text-5xl font-extrabold tracking-tight leading-tight mb-4 ${
        isDark ? 'text-white' : 'text-slate-900'
      }`}>
        Enterprise Management for<br />
        <span
          ref={typingRef}
          className="bg-gradient-to-r from-indigo-500 via-purple-500 to-brand-orange bg-clip-text text-transparent border-r-2 border-brand-orange pr-1"
        />
      </h2>

      <p className={`text-base sm:text-lg leading-relaxed max-w-2xl mx-auto ${
        isDark ? 'text-slate-400' : 'text-slate-600'
      }`}>
        Select a workspace below to launch your dedicated portal. Powered by a single unified backend and shared authentication engine.
      </p>
    </section>
  );
}
