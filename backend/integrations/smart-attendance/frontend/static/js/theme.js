/**
 * Ardhnarishwar Global SaaS Theme Controller
 * Supports: midnight, nebula, oceanic, emerald, light
 */

const THEMES = {
  midnight: { name: 'Midnight Cyber', icon: '🌌', bg: '#070B14', accent: '#10B981' },
  nebula: { name: 'Deep Nebula', icon: '🔮', bg: '#0C081A', accent: '#8B5CF6' },
  oceanic: { name: 'Oceanic Abyss', icon: '🌊', bg: '#030F1F', accent: '#06B6D4' },
  emerald: { name: 'Matrix Emerald', icon: '🌲', bg: '#03140C', accent: '#10B981' },
  light: { name: 'Executive Light', icon: '☀️', bg: '#F8FAFC', accent: '#4F46E5' }
};

function getSavedTheme() {
  return localStorage.getItem('ardh_theme') || 'midnight';
}

function applyTheme(themeKey) {
  if (!THEMES[themeKey]) themeKey = 'midnight';
  document.documentElement.setAttribute('data-theme', themeKey);
  localStorage.setItem('ardh_theme', themeKey);

  // Update theme label in UI if present
  const labelEl = document.getElementById('current-theme-label');
  if (labelEl) {
    labelEl.innerHTML = `<span>${THEMES[themeKey].icon}</span> <span>${THEMES[themeKey].name}</span>`;
  }

  // Update active state in dropdown
  document.querySelectorAll('.theme-option-item').forEach(btn => {
    const isSelected = btn.getAttribute('data-theme-key') === themeKey;
    btn.classList.toggle('active', isSelected);
    const check = btn.querySelector('.theme-check-mark');
    if (check) check.textContent = isSelected ? '✓' : '';
  });
}

function toggleThemeMenu(e) {
  if (e) e.stopPropagation();
  const menu = document.getElementById('theme-dropdown-menu');
  if (menu) menu.classList.toggle('active');
}

function closeThemeMenu() {
  const menu = document.getElementById('theme-dropdown-menu');
  if (menu) menu.classList.remove('active');
}

// Global click listener to close menu
document.addEventListener('click', (e) => {
  const wrap = document.querySelector('.theme-selector-wrap');
  if (wrap && !wrap.contains(e.target)) {
    closeThemeMenu();
  }
});

// Auto-run on DOM loading
(function initTheme() {
  const initial = getSavedTheme();
  document.documentElement.setAttribute('data-theme', initial);
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => applyTheme(initial));
  } else {
    applyTheme(initial);
  }
})();
