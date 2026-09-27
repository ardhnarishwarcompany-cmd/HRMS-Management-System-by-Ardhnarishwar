import React from 'react';
import { Search } from 'lucide-react';

export default function CategoryFilter({ currentFilter, setFilter, searchQuery, setSearchQuery, totalCount, isDark }) {
  const categories = [
    { id: 'all', label: `All Portals (${totalCount})` },
    { id: 'core', label: 'Core Operations' },
    { id: 'ai', label: 'AI & Automation' },
    { id: 'business', label: 'Client & Sales' }
  ];

  return (
    <div className="flex flex-col lg:flex-row items-stretch lg:items-center justify-between gap-4 mb-8">
      {/* Segmented Filter Tabs */}
      <div className={`inline-flex items-center gap-1.5 p-1.5 rounded-2xl backdrop-blur-xl border overflow-x-auto scrollbar-none shadow-lg ${
        isDark ? 'bg-slate-900/80 border-white/10' : 'bg-white/80 border-slate-200'
      }`}>
        {categories.map((cat) => {
          const isActive = currentFilter === cat.id;
          return (
            <button
              key={cat.id}
              onClick={() => setFilter(cat.id)}
              className={`px-5 py-2.5 rounded-xl text-xs font-bold tracking-wide whitespace-nowrap transition-all duration-200 ${
                isActive
                  ? 'bg-gradient-to-r from-indigo-600 to-purple-600 text-white shadow-md shadow-indigo-500/25 border border-indigo-400/30'
                  : isDark
                  ? 'text-slate-400 hover:text-slate-200 hover:bg-white/5 border border-transparent'
                  : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100 border border-transparent'
              }`}
            >
              {cat.label}
            </button>
          );
        })}
      </div>

      {/* Search Bar */}
      <div className="relative min-w-[280px]">
        <Search className={`absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 pointer-events-none ${
          isDark ? 'text-slate-400' : 'text-slate-500'
        }`} />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search portals or modules..."
          className={`w-full pl-11 pr-4 py-2.5 rounded-2xl border text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/25 backdrop-blur-xl transition-all shadow-lg ${
            isDark
              ? 'bg-slate-900/80 border-white/10 text-white placeholder-slate-500 focus:border-indigo-500'
              : 'bg-white/90 border-slate-200 text-slate-900 placeholder-slate-400 focus:border-indigo-500'
          }`}
        />
      </div>
    </div>
  );
}
