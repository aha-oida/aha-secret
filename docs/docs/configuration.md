---
layout: default
title: Configuration
permalink: /configuration/
nav_order: 4
---

# Configuration

It is possible to configure [aha-secret] by setting environment variables.

## Environment Variables 

The following environment variables can be set to configure the application:

| Variable       | Description | Default |
|----------------|-------------|---------|
| URL            | Add url as origin | base-url |
| SESSION_SECRET | Set custom session-secret | random |
| MEMCACHE       | Set a memcache-server and enable rack-attack | empty(disable rack-attack) |
| APP_LOCALE     | Set the locale for the application | empty (default is en) |
| PLAYWRIGHT_HEADLESS | Run e2e tests with playwright headless |

## Custom Style

The application can be customized by changing the following files:

- 'config/config.yml' - set 'custom_stylesheet' to true
- 'public/custom.css' - add your custom css to this file

See the file 'public/application.css' for defined css classes you could simply overwrite.

You can even add your own logo by copying a logo to the 'public' folder and setting a background image in the 'public/custom.css' file.

Example:

```css
div#logo {
  width: 200px;
  height: 40px;
  background-image: url('logo.png');
  position: fixed;
  left:5px;
  top:5px;
  max-width:100%;
  background-repeat: no-repeat;
}
```
----

[aha-secret]: https://github.com/aha-oida/aha-secret
