# Employee Portal shared shell update

The Employee Portal now uses one shared `EmployeeLayout`/`EmployeeNavbar` for every protected route.
The production `dist` also includes a runtime compatibility shell that guarantees the same sidebar and topbar on pages built from an older bundle.
