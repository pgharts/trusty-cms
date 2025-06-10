document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".toggle-diff").forEach(function (link) {
        link.addEventListener("click", function (e) {
            e.preventDefault();
            const targetId = this.dataset.toggle;
            const row = document.getElementById(targetId);
            if (row) {
                const isHidden = window.getComputedStyle(row).display === "none";
                row.style.display = isHidden ? "table-row" : "none";
                this.textContent = isHidden ? "Hide Diff" : "Show Diff";
                this.setAttribute("aria-expanded", isHidden ? "true" : "false");
            }
        });
    });
});
  