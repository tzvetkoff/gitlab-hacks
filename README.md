# GitLab Hacks

My attempt to prevent tag deletion for specific projects in GitLab.

## But, but... Why?

Because tag deletion is something that must be eradicated for all development purposes.

Yes, yes, I know *sometimes* you might screw things up and really need to delete a tag.
That's why there's the configurable option to allow admins or specific membership classes to do so.

## What it does?

Since GitLab is written in Ruby, this allows us to easily extend it due to Ruby being probably the best programming language.
Ever.

We use Ruby's open classes and Rails' initializers to monkey-patch the ugly tag deletion service.

It consists of 2 parts - a monkey-patch for the UI, and a custom hook for `git push origin :tag_name`.

To install it for the Omnibus package, you can use the `install.sh` script, or do it manually as described below.

## Installation

Put the initializer and it's config in `/opt/gitlab/embedded/service/gitlab-rails/config/initializers`.

To disable tag deletion globally, put the `zzz_protected_tags.sh` hook in `/opt/gitlab/embedded/service/gitlab-shell/hooks/update.d`.
To disable it per project, put it in `/var/opt/gitlab/git-data/repositories/<namespace>/<repository-name>.git/custom_hooks`.
Then edit the hook and add SSH key IDs to allow specific people to delete tags.

## NB

GitLab's UI is ugly and doesn't display an error message if the delete tag service returns one.
Hopefully they'll fix it.
