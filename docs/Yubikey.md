# YubiKey Hardware Authentication

A YubiKey is a hardware-based authentication device that can securely store secret keys. When used in a web browser with two-factor authentication enabled, it provides a strong, convenient, and phishing-proof alternative to one-time passwords provided by applications or SMS. Much of the data on the key is protected from external access and modification, ensuring the secrets cannot be taken from the security key. 

Setting up a new YubiKey as a second factor is easy — your browser walks you through the entire process. However, setting up a YubiKey to sign commits and Secure Shell (SSH) authentication is a very different experience. 

This guide will walk you through how to generate GPG keys that are good for general use, including encryption and code signing with all keys generated and stored on YubiKey.

> [!WARNING] 
> These are my preferences and it might not suit your needs. Do your own research and pick the appropriate strategy for your specific requirements.

## Overview

- Install and Configure Necessary Software
- What Is OpenPGP?
- Why ED25519 Keys?
- Setting up YubiKey OpenPGP
   - Configure PIN/Admin PIN
   - Changing to Better Defaults
   - Key Creation
- Adding a New GPG Key to your GitHub Account
- Enable GPG Key for SSH
   - Using The Authentication Subkey
   - Set SSH_AUTH_SOCK
   - Take It For a Spin 
- Signing Commits & Tags

## Install and Configure Necessary Software

What you need depends on your operating system. As I am primarily a Mac user this guide is more focused on Mac.

Install the following packages via Homebrew:

- GnuPG
- pinentry
- [YubiKey Manager CLI](https://developers.yubico.com/yubikey-manager/)

```bash
brew install gnupg pinentry ykman
```

## What Is OpenPGP?

OpenPGP is a specification ([RFC-4880](https://datatracker.ietf.org/doc/html/rfc4880)), which describes a protocol for using public-key cryptography for encryption, signing, and key exchange, based on the original [Phil Zimmermann](https://www.philzimmermann.com/EN/background/index.html) work of Pretty Good Privacy (PGP). 

There is often confusion between PGP and Gnu Privacy Guard (GnuPG or GPG), probably because of the inverted acronym. Sometimes these terms are used interchangeably, but GPG is an implementation of the OpenPGP specification (and arguably the most popular one). In OpenPGP an individual has an "OpenPGP key", which is actually a set of public-private key pairs grouped together under a _master key_. Other key pairs are known as _subkeys_, and any sub-key belonging to the "OpenPGP key" will be signed by the _master key_. In addition to the master key, it is common to have 3 sub-keys with different usage:

- **Authentication key** - Used to authenticate things like an SSH session.
- **Encryption key** - Used to encrypt/decrypt stuff like files or e-mails so that only you can see them.
- **Signature key** - Used for signing git commits, files, e-mails, etc. to prove that they came from you.

## Why ED25519 Keys?

Historically RSA has been more widely used than ECC ([Elliptic Curve Cryptography](https://blog.cloudflare.com/a-relatively-easy-to-understand-primer-on-elliptic-curve-cryptography/)) with TLS and PGP both make heavy use of it. However, Elliptic Curve Cryptography has been increasingly used more, becoming the digital signature scheme of choice for new cryptographic non-web applications. In Apple’s [white paper on iOS security](http://images.apple.com/ipad/business/docs/iOS_Security_Feb14.pdf), they relayed how they use ECDSA extensively in the Apple ecosystem. [Github](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and [Gitlab](https://docs.gitlab.com/ee/user/ssh.html) also recommend it for SSH keys. 

Furthermore, ECC keys are smaller and their operations run faster and use less power on most hardware. Lastly, all the curves available on the YubiKey are at least as strong or stronger than RSA-2048 against classical-computing attacks. 

For more information, see [ECDSA: The digital signature algorithm of a better internet](https://blog.cloudflare.com/ecdsa-the-digital-signature-algorithm-of-a-better-internet/) by Nick Sullivan.

It's enough background, let's get it started!

## Setting up YubiKey OpenPGP

Open up a terminal and run `gpg --card-status`, to display information about your device.

```bash
Reader ...........: Yubico YubiKey OTP FIDO CCID
Application ID ...: D2760001240100000006120416640000
Application type .: OpenPGP
Version ..........: 3.4
Manufacturer .....: Yubico
Serial number ....: 12345678
Name of cardholder: [not set]
Language prefs ...: [not set]
Salutation .......:
URL of public key : [not set]
Login data .......: [not set]
Signature PIN ....: not forced
Key attributes ...: rsa2048 rsa2048 rsa2048
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 0 3
Signature counter : 0
KDF setting ......: off
Signature key ....: [none]
Encryption key....: [none]
Authentication key: [none]
General key info..: [none]
```

To configure the device with your settings, run:

```bash
gpg --card-edit
```

This command will open an interactive session; type `admin` to enable setting properties on the devices.

### Configure PIN/Admin PIN

The OpenPGP app has 3 PINs: the **Admin PIN**, the **User PIN**, and the **Reset Code** (aka PUK, PIN Unblock Key). The **User PIN** is the one we use for day-to-day access to our OpenPGP private keys; and the **Admin PIN** is used to change the settings of the OpenPGP app itself (and to unblock or change the **User PIN** if you forget it or enter it incorrectly too many times in a row).

You need to change the various default PINs on the YubiKey. Pick something unique and consider using a password manager such as [Bitwarden](https://bitwarden.com/) for storing them.

> [!NOTE]  
> We don't need and won’t set a **Reset Code**. 

```bash
gpg/card> passwd
gpg: OpenPGP card no. D2760001240102010006078005150000 detected

1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit
```

Enter `1` at the prompt for the `passwd` command, and then enter `123456` which is the default PIN. Next, enter the new **User PIN** (you’ll be prompted for it twice). Do not use a numbers — instead use a simple passphrase that’s at least 6 characters long and easy to type (you’ll need to type it frequently, probably at least several times a day).

> [!CAUTION]
> Make sure it’s different than any other PIN or passphrase you’ve ever used before.

For the **Admin PIN** enter `12345678`, which is the default PIN, and use a simple passphrase with at least 8 characters long. It doesn’t need to be any stronger than the **User PIN**, just different (enough so that an adversary wouldn’t be able to guess the **Admin PIN** if she finds out your user PIN).

### Changing to Better Defaults

We want to make sure we're using the strongest key types that are available for GPG. For our purposes, we gonna use [Ed25519](https://ed25519.cr.yp.to/) signing key for signing messages, an [X25519](https://cr.yp.to/ecdh.html) decryption key for decrypting messages, and an [Ed25519](https://ed25519.cr.yp.to/) authentication key for signature-based authentication (such as for SSH).

So, use the `key-attr` command so that when you generate your keys, it will generate Curve 25519 keys instead of RSA keys:

```bash
gpg/card> key-attr
Changing card key attribute for: Signature key
Please select what kind of key you want:
   (1) RSA
   (2) ECC
Your selection? 2
Please select which elliptic curve you want:
   (1) Curve 25519
   (4) NIST P-384
   (6) Brainpool P-256
Your selection? 1
The card will now be re-configured to generate a key of type: ed25519
Note: There is no guarantee that the card supports the requested size.
      If the key generation does not succeed, please check the
      documentation of your card to see what sizes are allowed.
Changing card key attribute for: Encryption key
Please select what kind of key you want:
   (1) RSA
   (2) ECC
Your selection? 2
Please select which elliptic curve you want:
   (1) Curve 25519
   (4) NIST P-384
   (6) Brainpool P-256
Your selection? 1
The card will now be re-configured to generate a key of type: cv25519
Changing card key attribute for: Authentication key
Please select what kind of key you want:
   (1) RSA
   (2) ECC
Your selection? 2
Please select which elliptic curve you want:
   (1) Curve 25519
   (4) NIST P-384
   (6) Brainpool P-256
Your selection? 1
The card will now be re-configured to generate a key of type: ed25519
```

### Key Creation

Now we’re ready to generate a new set of OpenPGP keys on the YubiKey, using the `generate` command:

```bash
gpg/card> generate
Make off-card backup of encryption key? (Y/n)
```

Enter `n` to ensure that the private keys never leave the YubiKey, and enter the admin PIN when prompted:

```bash
Make off-card backup of encryption key? (Y/n) n

Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0)
Key does not expire at all
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: Your Name
Email address: you@example.com
Comment: Master Key
You selected this USER-ID:
    "Your Name (Master Key) <you@example.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
```

When prompted for your real name, email address, and comment, use the “real name” field for the display name or alias you want associated with the OpenPGP key, the “email address” field for the email account associated with the key (to keep your email private use your GitHub-provided no-reply email address) and the “comment” field for a word or phrase that will distinguish this key from other keys you have used or will use in the future with the same name and email. 

> [!NOTE]
> Note that we can later add more UIDs to an OpenPGP key via the `gpg --edit-key` command. We can also delete existing UIDs from a key the same way — but deleting UIDs can be difficult to get completely right and correctly propagated to all copies of the key.

## Adding a New GPG Key to your GitHub Account

Github supports several GPG key algorithms. By adding your public key to your GitHub account you enable GitHub to verify that your signatures are in fact yours.

Begin by listing your GPG key with the `LONG` key format:

```bash
> gpg --list-secret-keys --keyid-format LONG <youremail@example.com>

/Users/youruser/Library/Preferences/gnupg/pubring.kbx
-----------------------------------------------
sec>  ed25519/36264D8005D951D8 2023-10-23 [SC]
      12341C42734692704224266256EDCD8005D9ABD3
      Card serial no. = 0006 12345678
uid                 [ultimate] RealName <youremail@example.com>
ssb>  ed25519/AC59547D0CCB5ACE 2023-10-23 [A]
ssb>  cv25519/2B5F29BB2DCA942D 2023-10-23 [E] 
```

Determine the key ID for your signing key. This is the hexadecimal number on the line designated [SC] above `36264D8005D951D8`.

Log in to GitHub and go to Settings → [Add new GPG key](https://github.com/settings/gpg/new) page. Copy the output from `gpg --armor --export {your-key-id}` and add a new GPG key.

Copy the entire text block, including the `-----BEGIN PGP PUBLIC KEY BLOCK-----` and `-----END PGP PUBLIC KEY BLOCK-----`. 

Give the key a name and save it.

> [!TIP]
> On macOS, you can pipe the output directly to your clipboard using pbcopy, for example, `gpg --armor --export {your-key-id} | pbcopy`.

## Enable GPG Key for SSH

There are a few moving parts needed to expose your new GPG key in a way that your SSH client will use them. The SSH client reads the `SSH_AUTH_SOCK` environment variable which contains the location of a Unix socket managed by an agent. A `gpg-agent` running in the background controls this socket and allows your GPG key to be used for authentication. Also, the `gpg-agent` can be configured via `pinentry-program` stanza to use a particular pinentry user interface when prompting the user for a passphrase.

Enable SSH support using standard sockets by updating the `~/.gnupg/gpg-agent.conf` file:

```
# Enable SSH Support
# The OpenSSH Agent protocol is always enabled, but gpg-agent will only set the 
# SSH_AUTH_SOCK variable if this flag is given. In this mode of operation, the agent does not
# only implement the gpg-agent protocol, but also the agent protocol used by OpenSSH.
# https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html  
enable-ssh-support

# Connects gpg-agent to the OSX keychain via the brew-installed pinentry program from GPGtools. 
# This is the OSX 'magic sauce', allowing the gpg key's passphrase to be stored in the login
# keychain, enabling automatic key signing.
pinentry-program "$(which pinentry)"
```

### Using The Authentication Subkey

To tell the agent that the authentication subkey can be used with SSH, extract the _keygrip_ of the subkey:

```bash
> gpg --list-secret-keys --with-keygrip <youremail@example.com>

/Users/youruser/Library/Preferences/gnupg/pubring.kbx
-----------------------------------------------
sec>  ed25519/36264D8005D951D8 2023-10-23 [SC]
      12341C42734692704224266256EDCD8005D9ABD3
      Keygrip = 78BCD171C2DD44E5D6054F0EC98B8C5D2A37D076
      Card serial no. = 0006 12345678
uid                 [ultimate] RealName <youremail@example.com>
ssb>  ed25519/AC59547D0CCB5ACE 2023-10-23 [A]
      Keygrip = 28E05AC1DCFCB0C23EFD89A86C627B0959758813
ssb>  cv25519/2B5F29BB2DCA942D 2023-10-23 [E]                      
      Keygrip = 48B8049057AE142926CADB23A816DFF57DC85098
```

Update `~/.gnupg/sshcontrol` with the authentication _keygrip_; this allows the `gpg-agent` to use this key with SSH. 

```
# List of allowed ssh keys.  Only keys present in this file are used
# in the SSH protocol.  The ssh-add tool may add new entries to this
# file to enable them; you may also add them manually.  Comment
# lines, like this one, as well as empty lines are ignored.  Lines do
# have a certain length limit but this is not serious limitation as
# the format of the entries is fixed and checked by gpg-agent. A
# non-comment line starts with optional white spaces, followed by the
# keygrip of the key given as 40 hex digits, optionally followed by a
# caching TTL in seconds, and another optional field for arbitrary
# flags.   Prepend the keygrip with an '!' mark to disable it.

28E05AC1DCFCB0C23EFD89A86C627B0959758813
```

> [!IMPORTANT] 
> Do not confuse the Key ID with the Keygrip which is the hexadecimal number right below the line designated [A]: `28E05AC1DCFCB0C23EFD89A86C627B0959758813`.

### Set SSH_AUTH_SOCK

Edit the `~/.zshrc` file (or similar shell startup file) to include the following variables that enable the communication with `gpg-agent` instead of the default `ssh-agent`. 

```bash
unset SSH_AGENT_PID

if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

export GPG_TTY=$(tty)
```

> 🧪 The test involving `gnupg_SSH_AUTH_SOCK_by` variable is for the case where the agent is started as `gpg-agent --daemon /bin/sh` in which case the shell inherits the `SSH_AUTH_SOCK` variable from the parent, `gpg-agent`.

After changing the configuration, reload the agent using `gpg-connect-agent`.

```bash
gpg-connect-agent reloadagent /bye
```

The command should print `OK`.

### Take It For a Spin

It's finally time to take the whole setup out for a spin. You should have keys in your `gpg-agent` via the YubiKey and in your SSH agent as well. Testing SSH access is straight forward. We'll capture SSH public key on the YubiKey and add it to GitHub.

First, capture the SSH public key on the YubiKey.

```bash
ssh-add -L | grep -iF 'cardno' | pbcopy
```

Log in to GitHub and go to Settings → [Add new SSH](https://github.com/settings/ssh/new) page.

Then, execute: 

```bash
ssh -T git@github.com
```

Enter your PIN when prompted in the GUI. You should authenticate successfully to GitHub:

```
Hi ariellourenco! You've successfully authenticated, but GitHub does not provide shell access.
```

## Signing Commits & Tags

From a security standpoint, by default, Git does not provide any assurance of authorship. Although every Git _"blob"_ is hashed using SHA-1, this is only useful as an integrity check, i.e., to guarantee that the files and the commits that you are working with, are the exact same things they were when they were first created.

However, Git does provide the ability to sign your work. This allows users to verify that data is coming from a trusted source. By using the `-S` switch you instruct Git to sign your commits and tags using the configured signing key.

```bash
git commit -S -m 'Test my first signed commit.'
```

The command shown above uses the capital `S` letter (the extended form would be `--gpg-sign`). Using the lowercase letter `s` will only include the text `Signed-off-by: Committer Name <committer@example.com>` in your commit message and **NOT** actually sign the commit.

Configure Git to sign commits and tags automatically takes a few global properties.

```bash
git config --global commit.gpgsign true
git config --global tag.gpgSign true
git config --global user.signingkey {your-key-id}
```

The first two commands turns auto signing on for both commits and tags. Otherwise, you will need to specify `-S` as an extra command line argument to git commit/tag.

The next commit/tag will be signed, and you can double-check this by running `git log --show-signature`:

```bash
commit 85e0174d961f44666d8ffc7000e81df22eea13c6
gpg: Signature made Tue Jun  8 12:19:14 2021 EDT
gpg:                using EDDSA key 12341C42734692704224266256EDCD8005D9ABD3
gpg: Good signature from "RealName <youremail@example.com>" [ultimate]
Author: Real Name <youremail@example.com>
Date:   Tue Jun 8 12:19:13 2021 -0400

    Testing commit signing
```

GitHub also marks a commit or tag as "Verified" or "Partially Verified" if a commit or tag has a GPG, SSH, or S/MIME signature that is cryptographically verifiable.

![Screenshot of a verified commit](../assets/commit.png)

## References

- [Sign Git commits with YubiKey](https://github.com/YubicoLabs/sign-git-commits-yubikey)
- [Developers Guide to GPG and YubiKey](https://developer.okta.com/blog/2021/07/07/developers-guide-to-gpg)
- [An Opinionated YubiKey Setup Guide](https://www.procustodibus.com/blog/2023/04/how-to-set-up-a-yubikey/)
- [GNU PG](https://wiki.archlinux.org/title/GnuPG#SSH_agent)
