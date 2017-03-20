AcroBot
=======
AcroBot is an IRC bot that expands a provided acronym or abbreviation, if available. It supports context tags (@tag_name) to distinguish between various usages, and to differentiate between like acronyms.

This is the upstream source of the original bot, conceived and written by mfojtik@redhat.com and upon which all variations have been based.

Configuration
=============

Acrobot looks for the file named `acrobot.yaml` first in $HOME, then where AcroBot.rb was installed

The configuration values available are:

- **nick**: The nickname AcroBot will use in-channel
- **realname**: Expanded realname (usually used for instructions on how to get help)
- **user**: The user AcroBot uses to connect to IRC
- **server**: The IRC server to use
- **channels**: List of channels to join. Format is `['#CHAN-1','#CHAN-2',...]`
- **prefix**: Prefix for AcroBot to pay attention to (usually `/^!/` )

Abbreviations File
==================

AcroBot uses several flat YAML files to store the abbreviations it has learned about.
These files live in `#{install_dir}/`.
Abbreviations are initially saved to `draft.yaml`. They are later reviewed and either verified, updated, or discarded.

AcroBot must have **RW** access to `draft.yaml` and **R** access to all other dictionary files when running.

