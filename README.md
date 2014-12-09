AcroBot
=======
AcroBot is an IRC bot that expands a provided acronym or abbreviation, if available. It supports context tags (@tag_name) to distinguish between various usages, and to differentiate between like acronyms.

Configuration
=============

Acrobot looks for the file named `acrobot_cfg.yml` first in $HOME, then where AcroBot.rb was installed

The configuration values available are:

- **nick**: The nickname AcroBot will use in-channel
- **realname**: Expanded realname (usually used for instructions on how to get help)
- **user**: The user AcroBot uses to connect to IRC
- **server**: The IRC server to use
- **channels**: List of channels to join. Format is `['#CHAN-1','#CHAN-2',...]`
- **prefix**: Prefix for AcroBot to pay attention to (usually `/^!/` )

Abbreviations File
==================

AcroBot uses a flat YAML file to store the abbreviations it has learned about.
That file resides at `#{install_dir}/abbrev.yml`.

AcroBot must have **RW** access to that file when running.

