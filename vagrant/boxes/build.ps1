$cmd = $args[0]

# delete box
if ( $cmd -match "delete-box" ) {
    rm kans-*.box

    ls *.box
    exit 0
}

# remove box
if ( $cmd -match "remove-box" ) {
    vagrant box remove kans/docker -f
    vagrant box remove kans/worker -f
    vagrant box remove kans/master -f

    vagrant box list
    exit 0
}

# global status
if ( $cmd -match "status" ) {
    vagrant global-status
    exit 0
}

# plugin
if ( $cmd -match "plugin" ) {
    vagrant plugin install --local vagrant-disksize
    exit 0
}

# config
if ( $cmd -match "config" ) {
    Write-Host "Set CONFIG=$args[1]"

    Set-Item -Path Env:CONFIG -Value $args[1]
    Get-Item -Path Env:CONFIG
    exit 0
}

# clean
if ( $cmd -match "clean" ) {
    $batch_list = "docker,worker,master".Split(",")

    foreach ($item in $batch_list)
    {
        Write-Host "$item.yaml"
        Set-Item -Path Env:CONFIG -Value "$item.yaml"
        vagrant destroy -f
    }

    exit 0
}

# batch list
$batch_list = $args[0].Split(",")

Write-Host "Batch List: $batch_list"

foreach ($item in $batch_list)
{
    Write-Host "$item.yaml"

    Set-Item -Path Env:CONFIG -Value "$item.yaml"
    Get-Item -Path Env:CONFIG

    vagrant up
    vagrant package --output "$item.box"
#    vagrant destroy -f
}

# --vagrantfile Vagrantfile : 욥션을 넣으면 에러남.
# --info --config : 옵션은 에러남.
#    vagrant package --vagrantfile Vagrantfile --output "$item.box"
# vagrant package --vagrantfile Vagrantfile --output ./kans-docker.box

# .\build.ps1 delete-box
# .\build.ps1 config kans-docker.yaml
# .\build.ps1 remove-box
# .\build.ps1 clean
# .\build.ps1 docker,worker,master
# .\build.ps1 clean

# vagrant box add kans/master master.json
# vagrant box list

