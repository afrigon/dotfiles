function sendto --description 'Sends a file to the download folder of a remote server'
    scp $argv[2] $argv[1]:~/Downloads
end
