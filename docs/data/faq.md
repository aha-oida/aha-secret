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
      No. By default a secret is deleted after its first reveal. A sender can
      opt into repeated reveals for a retention time of at most one hour.
      Reusable and unrevealed one-time secrets are removed by scheduled cleanup
      after their retention time. The default for one-time secrets is 7 days.
   ```
   {: .fs-6 }

6. >Are secrets deleted if someone clicks on the weblink but not on "reveal"?
   {: .fs-6 }

   ```
      No. Opening the link only displays the reveal page. Reveal fetches the
      encrypted secret and deletes it when it is one-time. Reusable secrets
      remain available until scheduled expiry cleanup.
   ```
   {: .fs-6 }


----

[aha-secret]: https://github.com/aha-oida/aha-secret
