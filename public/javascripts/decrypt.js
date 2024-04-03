function getKeyFromUrl(){
  const hash = window.location.hash;
  const key = hash.match(/^[^#]*#(.*)/)[1];
  return key.split('&');
}

function base64ToBytes(base64) {
  let binary_string =  window.atob(base64);
  let len = binary_string.length;
  let bytes = new Uint8Array(len);
  for (var i = 0; i < len; i++) {
    bytes[i] = binary_string.charCodeAt(i);
  }
  return bytes;
}

async function getKeyfromB64(base64key) {
  const key = await window.crypto.subtle.importKey("raw", base64ToBytes(base64key), "AES-GCM", true, [
    "encrypt",
    "decrypt",
  ]);
  return key;
}

async function decryptMessage(key, ciphertext, iv) {
  let decrypted = await window.crypto.subtle.decrypt(
    {
      name: "AES-GCM",
      iv: iv
    },
    key,
    ciphertext
  );
  let dec = new TextDecoder();
  return dec.decode(decrypted);
}

async function decryptEvent() {
  const keyiv = getKeyFromUrl();
  const key = await getKeyfromB64(keyiv[0]);
  const iv = base64ToBytes(keyiv[1]);
  const message = document.getElementById('enc-key').innerText;
  document.getElementById('dec-msg').value= await decryptMessage(key, base64ToBytes(message), iv);
}
