{
  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    tmux = {
      enable = true;
      clock24 = true;
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.etc = {
    "scripts/tmux.sh".text = ''
      #!/bin/sh
      if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
      /run/current-system/sw/bin/tmux attach-session -t ssh_tmux || /run/current-system/sw/bin/tmux new-session -s ssh_tmux
      fi
    '';
  };
}
