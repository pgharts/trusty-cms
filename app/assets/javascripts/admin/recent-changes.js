document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".toggle-diff").forEach(link => {
    link.addEventListener("click", event => {
      event.preventDefault();

      const targetId = link.dataset.toggle;
      const row = document.getElementById(targetId);
      if (!row) return;

      const isHidden = window.getComputedStyle(row).display === "none";
      row.style.display = isHidden ? "table-row" : "none";

      link.textContent = isHidden ? "Hide Diff" : "Show Diff";
      link.setAttribute("aria-expanded", isHidden.toString());
    });
  });
});
