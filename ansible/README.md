# Подготовка к деплою
## Список используемого ПО
Перед развернтыванием необходимо установить 
- Ansible
- Дополнительные роли
    - geerlingguy.pip
    - geerlingguy.docker
    - DataDog.datadog
- Дополнительные коллекции
    - community.docker

## Переменные окружения
Для развертывания необходимо указать значения следующих переменныхЖ
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

### Часть переменных хранится в секретах
- ssh пороль к виртуальной машине: ansible_ssh_pass: ***
- ssh пароль к NAT серверу: NAT_SSH_PASSWORD: ***
- пороль к БД Redmine REDMINE_DB_PASSWORD: ***
- api key для DataDog: DATADOG_API_KEY: ***
# Развертывание
Установка зависимостей
```
make prepare
```

Для развертывания необходимо выполнить следующую команду
```
make deploy
```

После развертывания сайт будет доступен по ссылке: http://hexlet-p2.mexaho.online/
