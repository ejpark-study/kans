$cmd = $args[0]

# config
if ($cmd -match "config")
{
    Write-Host "Set CONFIG=$args[1]"

    Set-Item -Path Env:CONFIG -Value $args[1]
    Get-Item -Path Env:CONFIG
    exit 0
}

$config_list = $args[0].Split(",")
$cmd = $args[1]

foreach ($cfg in $config_list)
{
    Write-Host "Config: $cfg.yaml"
    Write-Host "Commands: $cmd"

    Set-Item -Path Env:CONFIG -Value "$cfg.yaml"
    Get-Item -Path Env:CONFIG

    vagrant $cmd
}
