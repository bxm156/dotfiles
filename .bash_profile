[[ -r ~/.bashrc ]] && . ~/.bashrc
# Predictable SSH authentication socket location.
# Keeping the symlink in $HOME allows pam_ssh_agent_auth to work
SOCK="$HOME/.agent-sshmosh-$USER.sock"
if test $SSH_AUTH_SOCK && [ $SSH_AUTH_SOCK != $SOCK ]
then
    ln -sf $SSH_AUTH_SOCK $SOCK
fi
export SSH_AUTH_SOCK=$SOCK
