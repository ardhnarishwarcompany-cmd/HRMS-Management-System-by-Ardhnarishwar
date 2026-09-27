import React, { useState, useMemo, useEffect } from 'react';
import ThreeBackground from './components/ThreeBackground';
import Navbar from './components/Navbar';
import HeroSection from './components/HeroSection';
import CategoryFilter from './components/CategoryFilter';
import PortalGrid from './components/PortalGrid';
import Footer from './components/Footer';
import { PORTALS, resolveUrl } from './data/portals';

export default function App() {
  const [theme, setTheme] = useState(() => {
    return localStorage.getItem('portal_theme') || 'dark';
  });
  const [filter, setFilter] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');

  const isDark = theme === 'dark';

  const toggleTheme = () => {
    const nextTheme = theme === 'dark' ? 'light' : 'dark';
    setTheme(nextTheme);
    localStorage.setItem('portal_theme', nextTheme);
  };

  useEffect(() => {
    if (isDark) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [isDark]);

  const filteredPortals = useMemo(() => {
    return PORTALS.filter((p) => {
      const matchesCategory = filter === 'all' || p.category === filter;
      const query = searchQuery.trim().toLowerCase();
      const matchesSearch =
        query === '' ||
        p.name.toLowerCase().includes(query) ||
        p.desc.toLowerCase().includes(query);
      return matchesCategory && matchesSearch;
    });
  }, [filter, searchQuery]);

  return (
    <div className={`relative min-h-screen z-10 transition-colors duration-500 selection:bg-brand-orange selection:text-white ${
      isDark
        ? 'bg-[#070913] text-slate-100'
        : 'bg-gradient-to-b from-slate-50 via-indigo-50/40 to-slate-100 text-slate-900'
    }`}>
      {/* 3D Interactive Three.js Background */}
      <ThreeBackground isDark={isDark} />

      <div className="max-w-[1536px] mx-auto px-4 sm:px-6 lg:px-8 py-6 relative z-10">
        {/* Navigation Bar */}
        <Navbar theme={theme} toggleTheme={toggleTheme} />

        {/* Hero Section */}
        <HeroSection isDark={isDark} />

        {/* Category Filters & Search Bar */}
        <CategoryFilter
          currentFilter={filter}
          setFilter={setFilter}
          searchQuery={searchQuery}
          setSearchQuery={setSearchQuery}
          totalCount={PORTALS.length}
          isDark={isDark}
        />

        {/* Portal Grid */}
        <PortalGrid portals={filteredPortals} resolveUrl={resolveUrl} isDark={isDark} />

        {filteredPortals.length === 0 && (
          <div className="text-center py-20 text-slate-400">
            <h3 className={`font-display font-semibold text-lg mb-1 ${isDark ? 'text-white' : 'text-slate-800'}`}>
              No portals match "{searchQuery}"
            </h3>
            <p className="text-xs text-slate-500">
              Try adjusting your search term or switching filter categories.
            </p>
          </div>
        )}

        {/* Footer */}
        <Footer isDark={isDark} />
      </div>
    </div>
  );
}