### Hexlet tests and linter status:
[![Actions Status](https://github.com/VGrishutin/devops-for-programmers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/VGrishutin/devops-for-programmers-project-77/actions)

# Подготовка к деплою
## Подготовка к деплою Инфраструктуры
Перед развертыванием необходимо устрованить
- Ansible
- Terraform
### Секреты
Перед развертыванием необходимо указать следующие секреты и переменные. Значения можно хранить как в зашифрованном файле так и в виде переменных окружения с префиксом **TF_VAR_**

#### Ключи доступа к data-dog
файл ./secrets/decrypted/dd.secrets.auto.tfvars
```
datadog_api_key = "???"
datadog_app_key = "???"
```
#### Ключи доступа к yandex cloud
файл ./secrets/decrypted/yc.secrets.auto.tfvars
```
yc_token = "???"
```
#### Параметры yandex cloud
файл ./secrets/decrypted/yc.auto.tfvars
- yc_folder_id    = "???"
- yc_cloud_id     = "???"
- yc_zone         = "???"
- yc_org_id       = "???"

#### Параметры хранения состояния terraform
Нельзя хранить в виде переменных. Файл необходим.
файл ./secrets/decrypted/state.config
- access_key="???"
- secret_key="???"
- bucket = "???"

после того как файлы с переменными создан (или добавлены перменные окружения) необходимо зашифровать данные файлы: для этого можно воспользоваться командой 
```
make infra-secret-encrypt
```
при этом система будет расчитывать на нахождение в корне проекта файла ```vault.password``` с паролем от vault

### Создание окружения для хранения сотояния
Для создания окружения для хранения состояния можно воспользоваться командой
```
make infra-prepare
make infra-init-backend
make infra-create-backend
```
информация необходима для заполнения файла ```./secrets/decrypted/state.config``` будет выведена на экран, а так же доступна в хранилище секретов облака


## Подготовка к деплою Приложения
### Список используемого ПО
Перед развернтыванием необходимо установить 
- Ansible
- Дополнительные роли
    - geerlingguy.pip
    - geerlingguy.docker
    - DataDog.datadog
- Дополнительные коллекции
    - community.docker

### Переменные окружения
Для развертывания необходимо указать значения следующих переменных
Переменные отвечающие за подключение к вирутальным машинам через ssh
ansible_user: ansible_user
ansible_ssh_pass: ***

Переменные отвечающие за подключение Redmine к серверу БД
- REDMINE_DB_POSTGRES: postgres-db
- REDMINE_DB_PORT: "5432"
- REDMINE_DB_USERNAME: redmine-user
- REDMINE_DB_PASSWORD: ***
- REDMINE_DB_DATABASE: redmine-db

Уникальное случайное значение
- REDMINE_SECRET_KEY_BASE: "supersecretkey"

#### Часть переменных хранится в секретах
- ssh пороль к виртуальной машине: ansible_ssh_pass: ***
- ssh пароль к NAT серверу: NAT_SSH_PASSWORD: ***
- пороль к БД Redmine REDMINE_DB_PASSWORD: ***
- api key для DataDog: DATADOG_API_KEY: ***

# Развертывание
## Развертывание инфраструктуры
Для развертывания инфраструктуры необходимо выполнить следующие команды
```
make infra-prepare
make infra-init
make infra-deploy
```

## Развертывание приложения
Установка зависимостей
```
make app-deploy-prepare
```

Для развертывания необходимо выполнить следующую команду
```
make app-deploy
```

После развертывания сайт будет доступен по ссылке: http://hexlet-p2.mexaho.online/
