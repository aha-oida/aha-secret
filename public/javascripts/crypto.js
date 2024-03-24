async function generateKeyb64(){
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

function getMessageEncoding() {
   const messageBox = document.getElementById('message');
   let message = messageBox.value;
   let enc = new TextEncoder();
   return enc.encode(message);
}

async function encryptMessage(key) {
  let encoded = getMessageEncoding();
  // The iv must never be reused with a given key.
  const iv = window.crypto.getRandomValues(new Uint8Array(12));
  const ciphertext = await window.crypto.subtle.encrypt(
    {
      name: "AES-GCM",
      iv: iv
    },
    key,
    encoded
  );

  const base64cipher = window.btoa(String.fromCharCode.apply(null, new Uint8Array(ciphertext)));
  const ciphertextValue = document.getElementById("ciphertext-value");
  ciphertextValue.textContent = base64cipher;
  return base64cipher;
}

function getKey(){
  const hash = window.location.hash;
  const key = hash.match(/^[^#]*#(.*)/)[1];
  console.log(key);
}

async function encryptEvent(){
  const key = await generateKeyb64();
  const cipher = await encryptMessage(key);
  console.log(cipher);
}
