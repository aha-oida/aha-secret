function getKeyFromUrl(){
  const hash = window.location.hash;
  const key = hash.match(/^[^#]*#(.*)/)[1];
  console.log(key);
}

