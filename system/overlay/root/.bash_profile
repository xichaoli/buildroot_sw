# .bash_profile

export PATH=\
/bin:\
/sbin:\
/usr/bin:\
/usr/sbin:\
/usr/local/bin \
/usr/local/sbin

umask 022

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

