function bytesToString(bytes) {
  return new TextDecoder().decode(bytes);
}

function stringToBytes(str) {
  return new TextEncoder().encode(str);
}

function bytesToBase64(arr) {
  return btoa(Array.from(arr, (b) => String.fromCharCode(b)).join(""));
}

async function generateKeyb64() {
  const key = await window.crypto.subtle.generateKey(
    {
      name: "AES-GCM",
      length: 256,
    },
    true,
    ["encrypt", "decrypt"]
  );

  const arrbuf = await window.crypto.subtle.exportKey("raw", key);
  const base64key = window.btoa(String.fromCharCode.apply(null, new Uint8Array(arrbuf)));

  document.getElementById('enc-key').innerText = base64key;
  document.getElementById('enc-pane').style.display = 'block';
  document.getElementById('enc-form').style.display = 'none';
  return key;
}

function storeIV(iv) {
  const iv64 = window.btoa(String.fromCharCode(...iv));
  document.getElementById('enc-iv').innerText = iv64;
}

async function getKeyfromB64(base64key) {
  const uint8Array = (base64key) => {
    const string = window.atob(base64key)
    const buffer = new ArrayBuffer(string.length)
    const bufferView = new Uint8Array(buffer)
    for (let i = 0; i < string.length; i++) {
      bufferView[i] = string.charCodeAt(i)
    }
    return buffer
  }

  const key = await window.crypto.subtle.importKey("raw", uint8Array(base64key), "AES-GCM", true, [
    "encrypt",
    "decrypt",
  ]);
}

function getEncodedMessage() {
  const messageBox = document.getElementById('message');
  let message = messageBox.value;
  let enc = new TextEncoder();
  return enc.encode(message);
}

async function encryptMessage(key) {
  let encoded = getEncodedMessage();
  // The iv must never be reused with a given key.
  const iv = window.crypto.getRandomValues(new Uint8Array(12));
  storeIV(iv);
  const ciphertext = await window.crypto.subtle.encrypt(
    {
      name: "AES-GCM",
      iv: iv
    },
    key,
    encoded
  );

  const base64cipher = window.btoa(String.fromCharCode.apply(null, new Uint8Array(ciphertext)));
  return base64cipher;
}

function createLink(id) {
  /* replace normal b64, with urlsafe b64. we keep the '=' */
  const b64Key = document.getElementById('enc-key').innerText.replace(/\+/g, '-').replace(/\//g, '_');
  const b64Iv = document.getElementById('enc-iv').innerText.replace(/\+/g, '-').replace(/\//g, '_');
  const url = window.location.href + "bins/" + id + '#' + b64Key + '&' + b64Iv;
  const secret_element = document.getElementById("secret-url");
  secret_element.value = url;
  // make the element visible
  secret_element.style.display = "block";
}

async function getKey(password, salt) {
  const passwordBytes = stringToBytes(password);

  const initialKey = await crypto.subtle.importKey(
    "raw",
    passwordBytes,
    { name: "PBKDF2" },
    false,
    ["deriveKey"]
  );

  return crypto.subtle.deriveKey(
    { name: "PBKDF2", salt, iterations: 100000, hash: "SHA-256" },
    initialKey,
    { name: "AES-GCM", length: 256 },
    false,
    ["encrypt", "decrypt"]
  );
}

async function customEncryptEvent() {
  var message = document.getElementById("message");
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const addpass = document.getElementById("add-password").value;
  const key = await getKey(addpass, salt);
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const contentBytes = stringToBytes(message.value);
  const cipher = new Uint8Array(
    await crypto.subtle.encrypt({ name: "AES-GCM", iv }, key, contentBytes)
  );
  var result = {
	  salt: bytesToBase64(salt),
	  iv: bytesToBase64(iv),
	  cipher: bytesToBase64(cipher)
  };
  message.value = JSON.stringify(result);
}

async function encryptEvent() {
  const hasPassword = document.getElementById("has_password").checked;
  if(hasPassword) {
    await customEncryptEvent();
  }
  const key = await generateKeyb64();
  const cipher = await encryptMessage(key);
  const retention = document.getElementById("retention").value;
  const authenticityToken = getAuthenticityToken();

  await fetch("/", {
    method: 'post',
    body: `bin[payload]=${encodeURIComponent(cipher)}&retention=${retention}&authenticity_token=${authenticityToken}&bin[has_password]=${hasPassword}`,
    headers: {
      "Content-Type": "application/x-www-form-urlencoded"
    }
  }).then((response) => {
    if(response.ok) {
      return response.json()
    }
    return Promise.reject(response);
  }).then((res) => {
    createLink(res.id);
  }).catch((error) => {
       error.json().then( err => {
	 setAlert(err.msg, false);
         console.log(err.msg)
       }).catch(() => {
	       console.log("Unknown error")
       })
       document.getElementById('enc-pane').style.display = 'none';
       document.getElementById('enc-form').style.display = 'block';
  });
}

const messageEle = document.getElementById('message');
const counterEle = document.getElementById('msg-counter');

messageEle.addEventListener('input', function (e) {
  const target = e.target;

  // Get the `maxlength` attribute
  const maxLength = target.getAttribute('maxlength');

  // Count the current number of characters
  const currentLength = target.value.length;

  counterEle.innerHTML = `${currentLength}/${maxLength}`;
});

const encryptionForm = document.querySelector("#enc-form form");

encryptionForm?.addEventListener("submit", async function (e) {
  e.preventDefault()
  await encryptEvent();
})
