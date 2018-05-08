# Predictable SSH authentication socket location.
SOCK="/tmp/ssh-agent-$USER"
if test $SSH_AUTH_SOCK && [ $SSH_AUTH_SOCK != $SOCK ]
then
    ln -sf $SSH_AUTH_SOCK $SOCK
fi
export SSH_AUTH_SOCK=$SOCK
