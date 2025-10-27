---
title: Writing Documentation
parent: Development
nav_order: 2
layout: default
---

# Writing Documentation

The documentation is made with [Jekyll] and the [just-the-docs theme].

{: .note }
> For information on how to use [Jekyll] and the [just-the-docs theme] please have a look to the docs of these projects.

First download the docs-branch:

```bash
git clone -b docs git@github.com:aha-oida/aha-secret.git
```

Change into the docs-subdirectory:

```bash
cd aha-secret/docs
```

Next run bundler:

```bash
bundle install
```

Before we can run jekyll locally, we need to modify the `_config.yml`.
First comment out the lines:

```yaml
# baseurl: "/aha-secret"
# url: "https://aha-oida.github.io"
# remote_theme: just-the-docs/just-the-docs@v0.10.0
```

And add the following line instead of the remote_theme:

```yaml
theme: just-the-docs
```

Now run Jekyll and connect to `http://localhost:4000`:

```
bundle exec jekyll server
```

{: .warning }
> Please note that you have to undo the changes in _`_config.yml` before pushing
to the repository.

Instead of manually changing `_config.yml` and switching back, you can also run the script `bin/run_local`.

----
[Jekyll]: https://jekyllrb.com/docs/
[just-the-docs theme]: https://just-the-docs.github.io/just-the-docs/
