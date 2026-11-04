# Tramplin Infra

Production-инфраструктура Tramplin в k3s: PostgreSQL/pgvector, Redis, RabbitMQ,
Piston, постоянные тома, сетевые политики и общие секреты. Только production.

- [Production-манифесты](k8s/)
- [Проверки и порядок деплоя](.gitlab-ci.yml)
- [GitLab Agent и права доступа](bootstrap/gitlab-agent/)
- [Piston и автоматическая установка языков](k8s/piston/)

Приложения и их манифесты находятся в собственных репозиториях. Общие
контроллеры кластера, TLS и ingress принадлежат `cluster`. Мониторинг k3s
планируется отдельно; этот репозиторий его не разворачивает.

Проверка манифестов: `make validate`. Развёртывание выполняет manual-job
`deploy-production` в GitLab CI через агент `tramplin1/infra:tramplin`.
Секреты поступают из GitLab Variables через External Secrets Operator.
