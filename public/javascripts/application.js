async function revealpw() {
	const pw = document.getElementById("passwd").value;
	const msg = await reveal();
	console.log("message: " + msg);
	const decrypted = await decryptWithPW(pw, msg);
	document.getElementById("dec-msg").value = decrypted;
}

async function reveal() {
  const element = document.getElementById("reveal-content");
  element.remove();
  const element2 = document.getElementById("bin-content");
  const decryptheader = document.getElementById("decrypt-header");
  decryptheader.style.display = "none";
  element2.style.display = "block";
  return await fetchEncrypted();
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

function addPassword() {
  const haspw = document.getElementById("has_password");
  if(haspw.checked) {
	document.getElementById("additional-password-field").style.display = "block";
  } else {
        document.getElementById("additional-password-field").style.display = "none";
  }
}

document.getElementById("has_password")?.addEventListener("click", addPassword);
document.getElementById("copy-button")?.addEventListener("click", copyToClip);
document.getElementById("copy-button")?.addEventListener("mouseout", showTooltip);
document.getElementById("revealbutton")?.addEventListener("click", reveal);
document.getElementById("revealpwbutton")?.addEventListener("click", revealpw);
