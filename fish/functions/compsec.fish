function compsec --description 'alias compsec=sudo docker run -it --rm -v .:/workdir -w /workdir compsec'
  sudo docker run -it --rm -v .:/workdir -w /workdir compsec $argv
        
end
