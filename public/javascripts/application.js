function setAlert(msg, lookup=true) {
	const messages = document.getElementById("error-messages");
	const alertbox = document.getElementById("alertbox");
	const alertspan = document.getElementById("alert");
	var alertmsg = "";
	if(lookup) {
	  alertmsg = messages.dataset[msg];
	} else {
          alertmsg = msg;
	}
	alertspan.textContent = alertmsg;
	alertbox.style.display = "flex";
}

function resetAlert(){
	const alertbox = document.getElementById("alertbox");
	const alertspan = document.getElementById("alert");
	alertspan.textContent = "";
	alertbox.style.display = "none";
}

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

	resetAlert();

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
	    setAlert("decryptionError")
	}
}

async function reveal() {
  const msg = await fetchEncrypted();
  showMessageContent();
  return msg;
}

function copyToClip() {
  const cpText = document.getElementById("secret-url");
  cpText.select();
  cpText.setSelectionRange(0, 99999);
  navigator.clipboard.writeText(cpText.value);

  var tooltip = document.getElementById("myTooltip");
  tooltip.innerHTML = tooltip.dataset.copied;
}

function copyMsgToClip() {
  const cpText = document.getElementById("message");
  cpText.select();
  cpText.setSelectionRange(0, 99999);
  navigator.clipboard.writeText(cpText.value);

  var tooltip = document.getElementById("myMsgTooltip");
  tooltip.innerHTML = tooltip.dataset.copied;
}

function showTooltip() {
  var tooltip = document.getElementById("myTooltip");
  tooltip.innerHTML = tooltip.dataset.text;
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

function showRandomSettings() {
  const pwsettings = document.getElementById("random_settings");
  if(pwsettings.checked) {
	document.getElementById("randomSettings").style.display = "block";
  } else {
	document.getElementById("randomSettings").style.display = "none";
  }
}


function generateSecret(length, charset) {
	 const array = new Uint8Array(length);
  	 window.crypto.getRandomValues(array);
         return [...array].map(x => charset[x % charset.length]).join('');
}

function getRandSettings() {
	var charset = "";
	var rand_length = 15;
	var rand_symbols = true;
	var rand_numbers = true;
	var rand_capitals = true;
	var rand_lowers = true;
	const rand_settings = document.getElementById("random_settings").checked;

        if(rand_settings) {
	    rand_length = document.getElementById("random_length").value;
	    rand_symbols = document.getElementById("random_symbol").checked;
	    rand_numbers = document.getElementById("random_numbers").checked;
	    rand_capitals = document.getElementById("random_capital").checked;
	    rand_lowers = document.getElementById("random_lower").checked;
	} else {

    	    rand_length = document.getElementById("random-config").dataset.length;
    	    rand_symbols = document.getElementById("random-config").dataset.symbols;
    	    rand_numbers = document.getElementById("random-config").dataset.numbers;
    	    rand_capitals = document.getElementById("random-config").dataset.capitals;
    	    rand_lowers = document.getElementById("random-config").dataset.lowers;
	}

    	if(rand_lowers) {
    	    charset += "abcdefghijklmnopqrstuvwxyz";
    	}

    	if(rand_capitals) {
    	    charset += "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    	}

    	if(rand_numbers) {
    	    charset += "0123456789";
    	}

    	if(rand_symbols) {
    	    charset += "!@#$%^&*()";
    	}

        return [charset, rand_length];
}

function generateSecretCallback() {
	const msgarea = document.getElementById('message');
	const [charset, rand_length] = getRandSettings();
	const secret = generateSecret(rand_length, charset);

	msgarea.value += secret + "\n";
	updateLenghtdisplay();
}

function entropyCallback() {
        const [charset, secret_len] = getRandSettings();
	const entropy = calcEntropy(charset.length, secret_len);
	const random_strength = document.getElementById("random_strength");
	const random_entropy = document.getElementById("random_entropy");
	const random_meter = document.getElementById("random_meter");
	random_entropy.textContent = parseFloat(entropy).toFixed(2) + "bit";

	random_meter.value = entropy;
}

function calcEntropy(charset_len, secret_len) {
	ret = Math.log2(Math.pow(charset_len, secret_len))

	if( !isFinite(ret) ) {
		ret = 0;
	}

	return ret;
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

document.getElementById("passwd")?.addEventListener("click", resetAlert);
document.getElementById("passwd")?.addEventListener("keydown", enterPassword);
document.getElementById("random-button")?.addEventListener("click", generateSecretCallback);
document.getElementById("passwd")?.addEventListener("keyup", function(event){
	event.preventDefault();
	if (event.keyCode === 13) {
		document.getElementById("revealpwbutton").click();
	}
});
document.getElementById("has_password")?.addEventListener("click", addPassword);
document.getElementById("random_settings")?.addEventListener("click", showRandomSettings);
document.getElementById("random_settings")?.addEventListener("click", entropyCallback);
document.getElementById("random_length")?.addEventListener("change", entropyCallback);
document.getElementById("random_symbol")?.addEventListener("change", entropyCallback);
document.getElementById("random_numbers")?.addEventListener("change", entropyCallback);
document.getElementById("random_capital")?.addEventListener("change", entropyCallback);
document.getElementById("random_lower")?.addEventListener("change", entropyCallback);
document.getElementById("add-password")?.addEventListener("keydown", changePassword);
document.getElementById("copy-button")?.addEventListener("click", copyToClip);
document.getElementById("copy-button-msg")?.addEventListener("click", copyMsgToClip);
document.getElementById("copy-button")?.addEventListener("mouseout", showTooltip);
document.getElementById("revealbutton")?.addEventListener("click", reveal);
document.getElementById("revealpwbutton")?.addEventListener("click", revealpw);
document.getElementById("message")?.addEventListener("focus", resetAlert);

document.addEventListener("DOMContentLoaded", () => {
  let passwordField = document.getElementById("passwd");
  if (!passwordField) {
    passwordField = document.getElementById("add-password");
  } else {
    console.log("passwd found, SHOW");
  }
  const togglePasswordButton = document.getElementById("togglePassword");

  if (togglePasswordButton && passwordField) {
    togglePasswordButton.addEventListener("click", () => {
      // Toggle the type attribute between 'password' and 'text'
      const isPasswordVisible = passwordField.type === "text";
      passwordField.type = isPasswordVisible ? "password" : "text";
      document.getElementById("eyeopen").classList.toggle("hidden");
      document.getElementById("eyeclosed").classList.toggle("hidden");
    });
  }

  const textarea = document.getElementById("message");

  if (textarea) {
    textarea.addEventListener('paste', (event) => {
      const maxLength = parseInt(textarea.getAttribute('maxlength'), 10);
      const clipboardData = event.clipboardData.getData('text');

      if (clipboardData.length > maxLength) {
        event.preventDefault();
        setAlert("pasteLimitExceeded");
        return;
      }
    });
  }
});
