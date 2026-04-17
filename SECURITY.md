# Security Notes

## English

DriverVault is designed to work offline with drivers already present on the local Windows installation.

- It does not download drivers from the internet.
- It does not contact a remote server.
- It does not include telemetry.
- It uses Windows tools such as `pnputil` and DISM.
- Backup metadata may contain hardware identifiers, device names, manufacturer/model information and driver names.

Do not publish real backup folders from your own computer unless you are comfortable sharing that hardware information.

If you find a security issue, please open a GitHub issue with a clear description and avoid posting private driver backups or personal logs.

## Русский

DriverVault рассчитан на офлайн-работу с драйверами, которые уже есть в текущей установке Windows.

- Программа не скачивает драйверы из интернета.
- Программа не подключается к удаленному серверу.
- В программе нет телеметрии.
- Используются штатные инструменты Windows: `pnputil` и DISM.
- Метаданные резервной копии могут содержать идентификаторы оборудования, названия устройств, сведения о производителе/модели и названия драйверов.

Не публикуйте реальные папки резервных копий со своего компьютера, если не хотите раскрывать такую информацию о железе.

Если вы нашли проблему безопасности, создайте GitHub issue с понятным описанием и не прикладывайте приватные резервные копии или личные журналы.
