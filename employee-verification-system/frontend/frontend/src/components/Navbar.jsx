function Navbar() {
  const name = localStorage.getItem("name") || "Employee";
  const email = localStorage.getItem("email") || "";
  const onMenu = () => window.dispatchEvent(new CustomEvent("toggle-sidebar"));
  const logout = () => {
    localStorage.clear();
    window.location.href = "/";
  };

  return (
    <header className="navbar employee-navbar">
      <button className="menu-btn" onClick={onMenu} aria-label="Toggle navigation menu">☰</button>

      <div className="evs-top-title">
        <h2>Employee Verification Dashboard</h2>
        <span>Employee Verification Portal</span>
      </div>

      <div className="nav-right evs-top-actions">
        <button className="evs-icon-btn" type="button" aria-label="Theme">☼</button>
        <button className="evs-icon-btn" type="button" aria-label="Notifications">♧</button>
        <div className="nav-user employee-nav-user">
          <b>{name}</b>
          <span>{email}</span>
        </div>
        <button className="nav-profile-btn" onClick={() => { window.location.href = "/profile"; }} aria-label="My profile">◉</button>
        <button className="logout-btn" onClick={logout}>⇥&nbsp; Logout</button>
      </div>
    </header>
  );
}

export default Navbar;
