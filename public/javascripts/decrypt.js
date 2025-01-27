function bytesToBase64(arr) {
  return btoa(Array.from(arr, (b) => String.fromCharCode(b)).join(""));
}

function bytesToString(bytes) {
  return new TextDecoder().decode(bytes);
}

function stringToBytes(str) {
  return new TextEncoder().encode(str);
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


function getKeyFromUrl(){
  const hash = window.location.hash;
  const key = hash.match(/^[^#]*#(.*)/)[1];
  let keyv = key.split('&');
  /* replace urlsafe b64, with normal b64 */
  keyv[0] = keyv[0].replace(/-/g, '+').replace(/_/g, '/');
  keyv[1] = keyv[1].replace(/-/g, '+').replace(/_/g, '/');
  return keyv;
}

function base64ToBytes(base64) {
  try{
	let binary_string =  window.atob(base64);
        let len = binary_string.length;
        let bytes = new Uint8Array(len);
        for (var i = 0; i < len; i++) {
          bytes[i] = binary_string.charCodeAt(i);
        }
        return bytes;
  } catch(err) {
	console.log(err);
  }
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

async function fetchEncrypted() {
  let binid = document.getElementById('bin-id').innerText;
  const authenticityToken = getAuthenticityToken();

  return await fetch(`/bins/${binid}/reveal?authenticity_token=${authenticityToken}`, {
    method: 'PATCH',
    headers: {
       'Content-type': 'application/json; charset=UTF-8',
    },
  }).then((response) => {
    return response.json()
  }).then((res) => {
    return decryptEvent(res.payload);
  }).catch((error) => {
    console.log(error)
  });

}

async function decryptWithPW(password, msg){
  var jdecmsg = JSON.parse(msg);
  const salt = base64ToBytes(jdecmsg.salt);
  const key = await getKey(password, salt);
  const iv = base64ToBytes(jdecmsg.iv);
  const cipher = base64ToBytes(jdecmsg.cipher);
  const contentBytes = new Uint8Array(
    await crypto.subtle.decrypt({ name: "AES-GCM", iv }, key, cipher)
  );
 return bytesToString(contentBytes);
}

async function decryptEvent(payload) {
  const keyiv = getKeyFromUrl();
  try{
        const key = await getKeyfromB64(keyiv[0]);
        const iv = base64ToBytes(keyiv[1]);
        const message = payload;
	const msg = await decryptMessage(key, base64ToBytes(message), iv);
        document.getElementById('dec-msg').value = msg;
	return msg;
  } catch(err) {
	console.log(err);
  }
}
