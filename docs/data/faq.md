---

title: FAQ
permalink: /faq/
layout: default
---

# Frequently Asked Questions

1. >Do the keys appear in the access logs of the webserver?
   {: .fs-6 }

   ```
      No. The key-part of the generated weblinks are behind
      the '#' sign and therefor not sent by the browser to
      the backend.
   ```
   {: .fs-6 }

2. >After encryption no link is generated
   {: .fs-6 }

   ```
      Make sure that you are using HTTPS. The crypto-api
      of the browsers just work with encrypted connections.
      If encryption is active, make sure that your browser
      accepts cookies.
   ```
   {: .fs-6 }

3. >The site often returns status 422
   {: .fs-6 }

   ```
      Make sure that the reverse proxy hands over the real
      IP address of the host. If this is not the case, it
      might always request the aha-secret app with the same
      local IP and will therefor trigger the ratelimit.
   ```
   {: .fs-6 }

4. >Is the additional password just a custom password for encryption?
   {: .fs-6 }

   ```
      No, by setting an additional password, the secret is first
      encrypted using that password and then encrypted with a strong and
      random secret. This ensures that secrets with weak passwords can't
      be bruteforced on the server side.
   ```
   {: .fs-6 }

5. >Are the secrets stored forever?
   {: .fs-6 }

   ```
      No, after someone reveals a secret, it is automatically deleted on
      the server. If nobody reveals the secret, it is automatically deleted
      after a certain amount of time. Default: 7day
   ```
   {: .fs-6 }

6. >Are secrets deleted if someone clicks on the weblink but not on "reveal"?
   {: .fs-6 }

   ```
      No, only reveal fetches the secret from the server and triggers the deletion.
   ```
   {: .fs-6 }

----

[aha-secret]: https://github.com/aha-oida/aha-secret
