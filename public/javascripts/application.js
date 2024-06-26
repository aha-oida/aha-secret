
async function reveal() {
  const element = document.getElementById("reveal-content");
  element.remove();
  const element2 = document.getElementById("bin-content");
  element2.style.display = "block";
  await fetchEncrypted();
}

function copyToClip(){
  const cpText = document.getElementById("secret-url");
  cpText.select();
  cpText.setSelectionRange(0, 99999);
  navigator.clipboard.writeText(cpText.value);

  var tooltip = document.getElementById("myTooltip");
  tooltip.innerHTML = "Copied: " + cpText.value;
}

function showTooltip() {
  var tooltip = document.getElementById("myTooltip");
  tooltip.innerHTML = "Copy to clipboard";
}

function getAuthenticityToken() {
  return document.querySelector("meta[name='authenticity_token']")?.content;
}

document.getElementById("copy-button")?.addEventListener("click", copyToClip);
document.getElementById("copy-button")?.addEventListener("mouseout", showTooltip);
document.getElementById("revealbutton")?.addEventListener("click", reveal);
