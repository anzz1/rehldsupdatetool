# rehldsupdatetool
command-line tool to update [ReHLDS](https://github.com/rehlds/ReHLDS)

## Usage

### Linux
```sh
wget https://raw.githubusercontent.com/anzz1/rehldsupdatetool/master/rehldsupdatetool.sh
chmod +x rehldsupdatetool.sh
./rehldsupdatetool.sh <game> <directory>
```

### Windows (requires .NET 4.5+)
```bat
powershell -nol -noni -nop -ex bypass -c "(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/anzz1/rehldsupdatetool/master/rehldsupdatetool.cmd','rehldsupdatetool.cmd')"
rehldsupdatetool.cmd <game> <directory>
```

Valid games: cstrike, czero, dmc, dod, gearbox, ricochet, tfc, valve
