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
  console.log(base64key);
  document.getElementById('enc-key').innerText = base64key;
  document.getElementById('enc-pane').style.display = 'block';
  document.getElementById('enc-form').style.display = 'none';
  return false;
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

  console.log(uint8Array(base64key));
  const key = await window.crypto.subtle.importKey("raw", uint8Array(base64key), "AES-GCM", true, [
    "encrypt",
    "decrypt",
  ]);
  console.log(key);
}

function getKey(){
  const hash = window.location.hash;
  const key = hash.match(/^[^#]*#(.*)/)[1];
  console.log(key);
}

