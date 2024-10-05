function showMessageContent() {
        const element = document.getElementById("reveal-content");
        element.remove();
        const element2 = document.getElementById("bin-content");
        const decryptheader = document.getElementById("decrypt-header");
        decryptheader.style.display = "none";
        element2.style.display = "block";
}

async function revealpw() {
	var msg = null;
	const pw = document.getElementById("passwd").value;

	/* do not fetch the bin if it was already fetched */
	if(document.getElementById("dec-msg").value)
	{
            msg = document.getElementById("dec-msg").value;
	}
	else {
            msg = await fetchEncrypted();
	}
	try {
            const decrypted = await decryptWithPW(pw, msg);
            showMessageContent();
            document.getElementById("dec-msg").value = decrypted;
	} catch(err) {
            console.log("DAMN! Decrypt did not work");
            console.log(err);
	}
}

async function reveal() {
  const msg = await fetchEncrypted();
  showMessageContent();
  return msg;
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
	if(document.getElementById("add-password").value.length == 0) {
            document.getElementById("create-secret").setAttribute("disabled", "disabled");
	}
	document.getElementById("additional-password-field").style.display = "block";
  } else {
	document.getElementById("create-secret").removeAttribute("disabled");
        document.getElementById("additional-password-field").style.display = "none";
  }
}

function changePassword() {
  if(document.getElementById("add-password").value.length > 0) {
      document.getElementById("create-secret").removeAttribute("disabled");
  } else {
      document.getElementById("create-secret").setAttribute("disabled", "disabled");
  }
}

function enterPassword() {
  if(document.getElementById("passwd").value.length > 0) {
      document.getElementById("revealpwbutton").removeAttribute("disabled");
  } else {
      document.getElementById("revealpwbutton").setAttribute("disabled", "disabled");
  }
}

document.getElementById("passwd")?.addEventListener("keydown", enterPassword);
document.getElementById("has_password")?.addEventListener("click", addPassword);
document.getElementById("add-password")?.addEventListener("keydown", changePassword);
document.getElementById("copy-button")?.addEventListener("click", copyToClip);
document.getElementById("copy-button")?.addEventListener("mouseout", showTooltip);
document.getElementById("revealbutton")?.addEventListener("click", reveal);
document.getElementById("revealpwbutton")?.addEventListener("click", revealpw);
