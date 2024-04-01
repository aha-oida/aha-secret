
function reveal() {
  const element = document.getElementById("reveal-content");
  element.remove();
  const element2 = document.getElementById("bin-content");
  element2.style.display = "block";
  getKeyFromUrl();
}
