# Tramplin Infra

Production-инфраструктура Tramplin в k3s: PostgreSQL/pgvector, Redis, RabbitMQ,
Piston, постоянные тома, сетевые политики и общие секреты. Только production.

- [Архитектура, настройки и эксплуатация](k8s/README.md)
- [Подготовка и порядок первого запуска](k8s/PREDEPLOY.md)
- [GitLab Agent и права доступа](bootstrap/gitlab-agent/README.md)
- [Piston и автоматическая установка языков](k8s/piston/README.md)

Приложения и их манифесты находятся в собственных репозиториях. Общие
контроллеры кластера, TLS и ingress принадлежат `cluster`. Мониторинг k3s
планируется отдельно; этот репозиторий его не разворачивает.

Проверка манифестов: `make validate`. Развёртывание выполняет manual-job
`deploy-production` в GitLab CI через агент `tramplin1/infra:tramplin`.
Секреты поступают из GitLab Variables через External Secrets Operator.
