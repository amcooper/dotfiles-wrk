#!/bin/bash

# autoreply.sh
#
# This script sends a canned email response to those who've errone-
# ously emailed me at <amcooper@gmail.com>. Once I've manually
# moved those emails into the `misdirected` folder, it iterates
# over those emails and responds.

set -euo pipefail

MISDIRECTED_DIR=/home/adam/Maildir/misdirected

if [[ -z "$(ls -A "$MISDIRECTED_DIR/cur")" ]] && [[ -z "$(ls -A "$MISDIRECTED_DIR/new")" ]]; then
  echo "[autoreply.sh] The misdirected folders are currently empty. Exiting..."
  exit 1
fi

# This weird feed-find-output-into-while-loop comes from
# https://github.com/koalaman/shellcheck/wiki/SC2044#correct-code
while IFS= read -r -d '' file ; do
  echo "[loop] Preparing the email..."

  # Make a temporary file
  temporary_file=$(mktemp /tmp/autoreplyXXXXX)

  # Pull sender (i.e. recipient of my email) and subject from email
  recipient="$(perl -lane 'print if /^From:/' "$file" | cut -d' ' -f2-)" ### "Frantz Fanon <ffanon@riseup.net>"
  subject="Re: $(perl -lane 'print if /^Subject:/' "$file" | cut -d' ' -f2-)" ### "Re: Lorem ipsum baby"

  # Copy canned message to temporary file
  cp /home/adam/dotfiles/arch/bin/autoreply/misdirected_email_autoreply.txt "$temporary_file"

  # Append email body to temporary file
  discard="0"
  while IFS= read -r line ; do
     if [[ $discard = "1" ]]; then
       echo "$line" >> "$temporary_file"
     else
       if [[ -z "$line" ]]; then
         discard="1"
       fi
     fi
  done < "$file"

  # Send the email!
  echo "[loop] Sending reply to $recipient ... "
  neomutt -s "$subject" -c amcooper@gmail.com "$recipient" < "$temporary_file"

  # Move the misdirected email into `INBOX/cur`
  echo "[loop] Moving the emails..."
  mv "$file" /home/adam/Maildir/INBOX/cur

  echo "[loop] Done."

done < <(find "$MISDIRECTED_DIR" -path "$MISDIRECTED_DIR/tmp" -prune -o -type f -print0)

echo "[autoreply.sh] All done!"
