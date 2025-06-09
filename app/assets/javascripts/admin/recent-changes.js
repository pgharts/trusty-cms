document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".toggle-diff").forEach(function (link) {
        link.addEventListener("click", function (e) {
        e.preventDefault();
        const targetId = this.dataset.toggle;
        const row = document.getElementById(targetId);
        if (row) {
            row.style.display = row.style.display === "none" ? "table-row" : "none";
            this.textContent = row.style.display === "none" ? "Show Diff" : "Hide Diff";
        }
        });
    });
});
  